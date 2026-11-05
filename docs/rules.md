<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="templ_generate"></a>

## templ_generate

<pre>
load("@rules_templ//templ:defs.bzl", "templ_generate")

templ_generate(<a href="#templ_generate-name">name</a>, <a href="#templ_generate-srcs">srcs</a>)
</pre>

Generates one `_templ.go` file per `.templ` source.

Use this target directly in `go_library.srcs`. The Go package name comes from
the templates, and runtime dependencies must be supplied on the Go library.
Outputs are isolated under a directory named after this target; source files
are never modified. Generation does not include timestamps or use watch mode.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="templ_generate-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="templ_generate-srcs"></a>srcs |  Template files or filegroups containing .templ files. All files must belong to the Go package being compiled.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |


