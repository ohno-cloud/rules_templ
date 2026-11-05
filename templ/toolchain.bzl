"""Toolchain for the templ compiler on the execution platform."""

TemplInfo = provider(
    doc = "Information about the templ compiler executable.",
    fields = {
        "tool": "Executable File used by generation actions.",
        "tool_files": "Files required to run the compiler.",
    },
)

def _templ_toolchain_impl(ctx):
    tool = ctx.executable.target_tool
    tool_files = ctx.attr.target_tool.files
    template_variables = platform_common.TemplateVariableInfo({"TEMPL_BIN": tool.path})
    default = DefaultInfo(
        files = tool_files,
        runfiles = ctx.runfiles(transitive_files = tool_files),
    )
    info = TemplInfo(tool = tool, tool_files = tool_files)
    return [
        default,
        template_variables,
        platform_common.ToolchainInfo(
            templinfo = info,
            template_variables = template_variables,
            default = default,
        ),
    ]

templ_toolchain = rule(
    implementation = _templ_toolchain_impl,
    attrs = {
        "target_tool": attr.label(
            doc = "Hermetically downloaded templ executable for the execution platform.",
            mandatory = True,
            allow_single_file = True,
            cfg = "exec",
            executable = True,
        ),
    },
    doc = "Defines a templ compiler toolchain.",
)
