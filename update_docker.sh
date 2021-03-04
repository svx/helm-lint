#!/usr/bin/env bash

replace HELM=.* HELM="$(get_version git helm/helm)"
replace HELM_DOCS=.* HELM_DOCS="$(get_version git norwoodj/helm-docs '^v')"
replace KUBEVAL=.* KUBEVAL="$(get_version git instrumenta/kubeval)"
