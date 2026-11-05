"""Bzlmod extension for pinned templ compiler toolchains.

Modules may request the default toolchain named templ. The highest requested
version is selected. Only the root module may request additional named
toolchains. Consumers explicitly use_repo and register the desired toolchains.
"""

load(":repositories.bzl", "templ_register_toolchains")

_DEFAULT_NAME = "templ"

_toolchain = tag_class(attrs = {
    "name": attr.string(
        doc = "Base repository name. Only the root module may use a non-default name.",
        default = _DEFAULT_NAME,
    ),
    "templ_version": attr.string(doc = "Pinned templ version without the v prefix.", mandatory = True),
})

def _version_key(version):
    return tuple([int(part) for part in version.split(".")])

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("Only the root module may use a non-default templ toolchain name.")
            previous = registrations.get(toolchain.name)
            if previous == None or _version_key(toolchain.templ_version) > _version_key(previous):
                registrations[toolchain.name] = toolchain.templ_version
    for name, version in registrations.items():
        templ_register_toolchains(name = name, templ_version = version, register = False)

templ = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": _toolchain},
)
