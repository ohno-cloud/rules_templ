"""Generate Go source files from templ templates."""

def _templ_generate_impl(ctx):
    toolchain = ctx.toolchains["//templ:toolchain_type"]
    sources = depset(ctx.files.srcs).to_list()
    if not sources:
        fail("srcs must contain at least one .templ file")

    outputs = []
    for source in sources:
        if not source.basename.endswith(".templ"):
            fail("srcs must contain only .templ files, got %s" % source.short_path)

        # Isolate each target's outputs and preserve paths to avoid basename collisions.
        relative_path = source.short_path
        if relative_path.startswith("../"):
            relative_path = "external/" + relative_path[3:]
        elif ctx.label.package and relative_path.startswith(ctx.label.package + "/"):
            relative_path = relative_path[len(ctx.label.package) + 1:]
        staged = ctx.actions.declare_file(ctx.label.name + "/" + relative_path)
        output = ctx.actions.declare_file(ctx.label.name + "/" + relative_path[:-len(".templ")] + "_templ.go")

        # templ writes beside its input. Stage the input in bazel-out rather than
        # allowing the compiler to write into the source tree. No shell is needed.
        ctx.actions.symlink(output = staged, target_file = source)
        args = ctx.actions.args()
        args.add("generate")
        args.add("-f", staged)
        args.add("-path", staged.dirname)
        args.add("-include-timestamp=false")
        args.add("-log-level=error")
        ctx.actions.run(
            mnemonic = "TemplGenerateGo",
            progress_message = "Generating Go from %s" % source.short_path,
            executable = toolchain.templinfo.tool,
            arguments = [args],
            inputs = [staged, source],
            outputs = [output],
        )
        outputs.append(output)

    generated = depset(outputs)
    return [
        DefaultInfo(files = generated),
        OutputGroupInfo(go_generated_srcs = generated),
    ]

templ_generate = rule(
    implementation = _templ_generate_impl,
    attrs = {
        "srcs": attr.label_list(
            doc = "Template files or filegroups containing .templ files. All files must belong to the Go package being compiled.",
            allow_files = [".templ"],
            mandatory = True,
        ),
    },
    toolchains = ["//templ:toolchain_type"],
    doc = """Generates one `_templ.go` file per `.templ` source.

Use this target directly in `go_library.srcs`. The Go package name comes from
the templates, and runtime dependencies must be supplied on the Go library.
Outputs are isolated under a directory named after this target; source files
are never modified. Generation does not include timestamps or use watch mode.
""",
)
