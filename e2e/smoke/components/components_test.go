package components

import (
	"bytes"
	"context"
	"testing"
)

func TestHello(t *testing.T) {
	var output bytes.Buffer
	if err := Hello("<Bazel>").Render(context.Background(), &output); err != nil {
		t.Fatal(err)
	}
	want := "<h1>Hello, &lt;Bazel&gt;!</h1><footer>Built with templ and Bazel.</footer>"
	if got := output.String(); got != want {
		t.Fatalf("rendered HTML = %q, want %q", got, want)
	}
}

func TestNestedFooter(t *testing.T) {
	var output bytes.Buffer
	if err := NestedFooter().Render(context.Background(), &output); err != nil {
		t.Fatal(err)
	}
	want := "<footer>Nested template.</footer>"
	if got := output.String(); got != want {
		t.Fatalf("rendered HTML = %q, want %q", got, want)
	}
}
