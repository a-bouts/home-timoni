package main

values: {
	git_repo_spec_default: {
		interval: "60m"
	}
	oci_repo_spec_default: {
		interval: "60m"
	}
	sources: {
		home: {
			kind: "GitRepository"
			spec: {
				url: "https://github.com/a-bouts/home-timoni"
				ref: branch: "main"
				interval: "5m"
			}
		}
	}
	helm_repo_spec_default: interval: "60m0s"
	unit_kustomization_spec_default: {
  		force: false
  		prune: true
  		interval: "15m"
  		retryInterval: "1m"
  		timeout: "30s"
	}
	unit_helmrelease_spec_default: {
		interval: "15m"
		install: remediation: {
			retries: 2
			remediateLastFailure: false
		}
	}
	unit_helmrelease_kustomization_spec_default: {
		path: "./kustomize-units/helmrelease-generic"
		sourceRef: {
			kind: "GitRepository"
			name: "home"
		}
		wait: true
	}
	units: {
		"flux-system": {
			repo: "home"
			kustomization_spec: {
				path: "./kustomize-units/flux-system/base"
				targetNamespace: "flux-system"
				wait: true
				// prevent Flux from uninstalling itself
				prune: false
			}
		}
		"cert-manager": {
			helm_repo_url: "https://charts.jetstack.io"
			helmrelease_spec: {
				chart: {
					spec: {
						chart: "cert-manager"
						version: "v1.13.1"
					}
				}
				targetNamespace: "cert-manager-system"
				install: createNamespace: true
				values: installCRDs: true
			}
		}
	}
}
