package templates

import (
	"text/template"

	timoniv1 "timoni.sh/core/v1alpha1"
)

// Config defines the schema and defaults for the Instance values.
#Config: {
	// Runtime version info
	moduleVersion!: string
	kubeVersion!:   string

	// Metadata (common to all resources)
	metadata: timoniv1.#Metadata
	metadata: version: moduleVersion

	git_repo_spec_default: _
	oci_repo_spec_default: _

	sources: [string]: #Source


	helm_repo_spec_default: _
	unit_kustomization_spec_default: _
	unit_helmrelease_spec_default: _
	unit_helmrelease_kustomization_spec_default: _

	units: [string]: #UnitConfig
}

#Source: {
	kind: "GitRepository" | "OCIRepository"
	spec: _
	auth?: string
} | {
	kind: "GitRepository" | "OCIRepository"
	existing_source: {
		name: string
		namespace?: string
	}
	auth?: string
}

#UnitConfig: {
	enabled: string | bool | *false
	depends_on: [string]: string
	repo: string
	labels: [string]: string
	ref_override?: [string]: string
	kustomization_spec: _
} | {
	enabled: string | bool | *false
	depends_on: [string]: string
	repo?: string
	helm_repo_url?: string
	labels: [string]: string
	ref_override?: [string]: string
	helm_chart_artifact_name?: string
	helmrelease_spec: _
}

// Instance takes the config values and outputs the Kubernetes objects.
#Instance: {
	config: #Config

	git_repositories: objects: [ for name, source in config.sources if source.kind == "GitRepository" { #GitRepository & {_name: name, _namespace: config.metadata.namespace, _default: config.git_repo_spec_default, _config: source}} ]
	oci_repositories: objects: [ for name, source in config.sources if source.kind == "OCIRepository" { #OCIRepository & {_name: name, _namespace: config.metadata.namespace, _default: config.oci_repo_spec_default, _config: source}} ]

	_units: [ for name, unit in config.units {
		_name: name
		unit
		_enabled: template.Execute("\(unit.enabled)", config) == "true"
	}]

	units: objects: [ for unit in _units if unit._enabled { #Unit & {
		_sources: config.sources
		_name: unit._name
		_namespace: config.metadata.namespace
		_helm_repo_spec_default: config.helm_repo_spec_default
		_default: config.unit_kustomization_spec_default
		_helm_default: config.unit_helmrelease_spec_default
		_unit_helmrelease_kustomization_spec_default: config.unit_helmrelease_kustomization_spec_default
		_config: #UnitConfig & unit
	}} ]
}
