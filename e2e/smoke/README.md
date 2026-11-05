# templ end-to-end example

This standalone Bazel module consumes `rules_templ` through a local override,
just as an external project would. The example combines an individual template
and a directory filegroup, feeds the generated files directly into `go_library`,
and renders the compiled component from a Go binary.

From this directory:

```sh
bazel test //...
bazel run //:render
```

The binary prints:

```html
<h1>Hello, Bazel!</h1><footer>Built with templ and Bazel.</footer>
```

`components_test` also checks HTML escaping, cross-template component calls, and
templates with matching basenames in different directories.
`generate_again` verifies two generation targets can share an input without
conflicting outputs. No generated Go files need to be checked into the source tree.
