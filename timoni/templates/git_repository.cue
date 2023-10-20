package templates

import (
	scv1 "github.com/fluxcd/source-controller/api/v1"
)

#GitRepository: scv1.#GitRepository & {
	_name:    	string
	_namespace:	string
	_default:   _
	_config:    #Source
	apiVersion: "source.toolkit.fluxcd.io/v1"
	kind:       scv1.#GitRepositoryKind
	metadata: {
		name:      _name
		namespace: _namespace
	}
	spec: scv1.#GitRepositorySpec & {
		for k, v in _default if _config.spec[k] == _|_ {"\(k)": v}
		_config.spec
	}
}
