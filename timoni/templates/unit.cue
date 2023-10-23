package templates

import (
	"encoding/yaml"
	"strings"

	kcv1 "github.com/fluxcd/kustomize-controller/api/v1"
	scv1beta2 "github.com/fluxcd/source-controller/api/v1beta2"
)

#Unit: {
	_sources: 		[string]: #Source
	_name:    		string
	_namespace:		string
	_helm_repo_spec_default: _
	_default:		_
	_helm_default:	_
	_unit_helmrelease_kustomization_spec_default: _
	_config:    	#UnitConfig

	_labels: {
		if len(_config.labels) > 0 {
			labels:    _config.labels
		}
	}

	_helmrelease_spec_overrides: {}

	if _config.helm_repo_url != _|_ {
		helm_repository: {
			apiVersion: "source.toolkit.fluxcd.io/v1beta2"
			kind:       scv1beta2.#HelmRepositoryKind
			metadata: {
				name:      "unit-\( _name )"
				namespace: _namespace
				labels:    _labels
			}
			spec: scv1beta2.#HelmRepositorySpec & {
				Merge & {_a: _helm_repo_spec_default, {url: _config.helm_repo_url}}
			}
		}

		_helmrelease_spec_overrides: {
			chart: spec: sourceRef: {
				kind: "HelmRepository"
				name: "unit-\( _name )"
			}
		}
	}

	_kustomization_spec_overrides: {}

	if _config.helm_repo_url == _|_ {
		_repo_def: _sources["home"]
		_sourceRef: {
			if _repo_def.existing_source != _|_ {
				kind: _repo_def.kind
				name: _repo_def.existing_source.name
				namespace: _repo_def.existing_source.namespace
			}
			if _repo_def.existing_source == _|_ {
				name: _config.repo
				kind: _repo_def.kind
			}
		}

		_helmrelease_spec_overrides: {
			chart: spec: {
				sourceRef: _sourceRef
			}
		}

		_kustomization_spec_overrides: {
			sourceRef: _sourceRef
		}
	}
	if _config.helm_repo_url != _|_ {
		_kustomization_spec_overrides: {
			_unit_helmrelease_kustomization_spec_default
		}
	}

	_patches: [
		if _config.helmrelease_spec != _|_ {
			{
				_helmrelease_spec: {
					releaseName: _name
					Merge & {_a: _helm_default, _b: _config.helmrelease_spec}
					_helmrelease_spec_overrides
				}
				target: kind: "HelmRelease"
				patch: """
- op: replace
  path: /metadata
  value:
    namespace: default
    name: \( _name )
    labels: \( yaml.Marshal(_labels) )
- op: replace
  path: /spec
  value:
    \( strings.Replace(yaml.Marshal(_helmrelease_spec), "\n", "\n    ", -1) )
"""
			}
		}
	]

	_kustomization_spec: {
		Merge & {_a: _default, _b: {
			if _config.kustomization_spec != _|_ {
				_config.kustomization_spec
			}
			//_dependsOn
			_kustomization_spec_overrides
			if len(_patches) > 0 {
				patches: _patches
			}
		}}
	}

	kustomization: kcv1.#Kustomization & {
		apiVersion: "kustomize.toolkit.fluxcd.io/v1"
		kind:       kcv1.#KustomizationKind
		metadata: {
			name:      _name
			namespace: _namespace
			if len(_config.labels) > 0 {
				labels:    _config.labels
			}
		}
		spec: kcv1.#KustomizationSpec & _kustomization_spec
	}
}
