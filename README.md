# Bazel rules for [templ](https://github.com/a-h/templ)

Generate Go code from `.templ` files with a hermetic Bazel toolchain, then use the
generated target directly in `go_library.srcs`.

The bundled compiler is **templ v0.3.1100**. Toolchains support macOS and Linux
(amd64/arm64), and Windows (amd64). Bazel 9 or newer is required; CI tests Bazel 9.x. See the
[templ guide](https://templ.guide/) for template syntax and runtime usage.

## Installation (Bzlmod)

This repository currently uses development version `0.0.0`. Until a release is
available in the Bazel Central Registry, use a local checkout:

```starlark
# MODULE.bazel
bazel_dep(name = "rules_templ", version = "0.0.0")
local_path_override(
    module_name = "rules_templ",
    path = "../rules_templ",  # Path to your checkout.
)

bazel_dep(name = "rules_go", version = "0.63.0")
bazel_dep(name = "gazelle", version = "0.54.0")

go_sdk = use_extension("@rules_go//go:extensions.bzl", "go_sdk")
go_sdk.download(version = "1.27.1")

templ = use_extension("@rules_templ//templ:extensions.bzl", "templ")
templ.toolchain(templ_version = "0.3.1100")
use_repo(templ, "templ_toolchains")
register_toolchains("@templ_toolchains//:all")

go_deps = use_extension("@gazelle//:extensions.bzl", "go_deps")
go_deps.from_file(go_mod = "//:go.mod")
use_repo(go_deps, "com_github_a_h_templ")
```

Add `github.com/a-h/templ v0.3.1100` to your `go.mod` (for example with
`go get github.com/a-h/templ@v0.3.1100`). Keep the Go runtime version aligned with
the compiler version. This templ runtime requires Go 1.26 or newer; the example
pins Go 1.27.1 because the default `rules_go` SDK may be older.
The compiler binary is downloaded separately; it does not
need to be installed locally or built with your project's Go toolchain.

## Usage

Create a template, such as `hello.templ`:

```templ
package components

templ Hello(name string) {
    <h1>Hello, { name }!</h1>
}
```

Generate and compile it in `BUILD.bazel`:

```starlark
load("@rules_go//go:def.bzl", "go_library")
load("@rules_templ//templ:defs.bzl", "templ_generate")

templ_generate(
    name = "generate",
    srcs = ["hello.templ"],
)

go_library(
    name = "components",
    srcs = [":generate"],  # Ordinary .go sources may be included here too.
    importpath = "example.com/project/components",
    visibility = ["//visibility:public"],
    deps = [
        "@com_github_a_h_templ//:templ",
        "@com_github_a_h_templ//runtime",
    ],
)
```

Call `components.Hello("Bazel").Render(ctx, writer)` from your Go application.
Add any packages imported by your templates to the library's `deps`, just as for
handwritten Go code. A generation target returns Go files, not a compiled Go
provider, so use it in `srcs`, not `deps`.

### Multiple files and filegroups

`srcs` accepts individual `.templ` files, `glob` results, and filegroups:

```starlark
filegroup(
    name = "partials",
    srcs = glob(["partials/*.templ"]),
)

templ_generate(
    name = "generate",
    srcs = ["hello.templ", ":partials"],
)
```

All templates compiled into a single `go_library` must declare the same Go
package. Templates can call one another's components; they are generated
independently and compiled together by `rules_go`.

Each input produces a `_templ.go` output beneath a target-specific directory in
`bazel-out`. Relative input paths are preserved, so repeated basenames in nested
directories and multiple targets using the same source do not collide. Source
files are never modified. Timestamp generation, watch mode, and source-map
visualisations are not enabled. The `go_generated_srcs` output group exposes the
same generated sources as the default outputs.

## Example and tests

See [`e2e/smoke`](e2e/smoke) for a complete standalone module with templates, a
`go_library`, a rendering binary, and an HTML-escaping test.

```sh
# Rule tests and generated documentation checks:
bazel test //...

# From e2e/smoke:
bazel test //...
bazel run //:render
```

The public rule reference is in [`docs/rules.md`](docs/rules.md).
