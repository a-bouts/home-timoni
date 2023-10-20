package templates

import (
	scv1beta2 "github.com/fluxcd/source-controller/api/v1beta2"
)

#HelmRepository: scv1beta2.#HelmRepository & {
	_config:    #Source
	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       "HelmRepository"
	metadata: {
		name:      _config.name
		namespace: _config.namespace
	}
	spec: scv1beta2.#HelmRepositorySpec & _config.spec
}
