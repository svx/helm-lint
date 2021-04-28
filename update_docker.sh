#!/usr/bin/env bash

# Each helm version supports 4 minor versions of k8s (N, N-1, N-2, N-3):
#   https://helm.sh/docs/topics/version_skew/
# Using a helm version compiled against the most recent prod deployment version:
#   https://grafana.ops.flywheel.io/d/8si-2YFGz/cluster-version
replace HELM=.* HELM="$(latest_version git helm/helm v3.3)"
replace HELM_DOCS=.* HELM_DOCS="$(latest_version git norwoodj/helm-docs '^v')"
replace KUBEVAL=.* KUBEVAL="$(latest_version git instrumenta/kubeval)"
