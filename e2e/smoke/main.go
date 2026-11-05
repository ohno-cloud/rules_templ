package main

import (
	"context"
	"log"
	"os"

	"github.com/ohno-cloud/rules_templ/e2e/smoke/components"
)

func main() {
	if err := components.Hello("Bazel").Render(context.Background(), os.Stdout); err != nil {
		log.Fatal(err)
	}
}
