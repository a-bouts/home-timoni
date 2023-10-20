package templates

import (
	scv1beta2 "github.com/fluxcd/source-controller/api/v1beta2"
)

#OCIRepository: scv1beta2.#OCIRepository & {
	_name:    	string
	_namespace:	string
	_default:   _
	_config:    #Source
	apiVersion: "source.toolkit.fluxcd.io/v1beta2"
	kind:       scv1beta2.#OCIRepositoryKind
	metadata: {
		name:      _name
		namespace: _namespace
	}
	spec: scv1beta2.#OCIRepositorySpec & {
		for k, v in _default if _config.spec[k] == _|_ {"\(k)": v}
		_config.spec
	}
}
