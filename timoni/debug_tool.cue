package main

import (
	"tool/cli"
	"encoding/yaml"
	"text/tabwriter"
)

// The build command generates the Kubernetes manifests and prints the multi-docs YAML to stdout.
// Example 'cue cmd -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 build'.
command: build: {
	task: print: cli.Print & {
		text: yaml.Marshal(timoni.apply.helm_repositories[0].spec)
	}
}

// The ls command prints a table with the Kubernetes resources kind, namespace, name and version.
// Example 'cue cmd -t name=test -t namespace=test -t mv=1.0.0 -t kv=1.28.0 ls'.
command: ls: {
	task: print: cli.Print & {
		text: tabwriter.Write([
			"RESOURCE \tAPI VERSION",
			for r in timoni.apply.all {
				if r.metadata.namespace == _|_ {
					"\(r.kind)/\(r.metadata.name) \t\(r.apiVersion)"
				}
				if r.metadata.namespace != _|_ {
					"\(r.kind)/\(r.metadata.namespace)/\(r.metadata.name)  \t\(r.apiVersion)"
				}
			},
		])
	}
}