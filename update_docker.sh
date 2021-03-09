#!/usr/bin/env bash

replace HELM=.* HELM="$(latest_version git helm/helm)"
replace HELM_DOCS=.* HELM_DOCS="$(latest_version git norwoodj/helm-docs '^v')"
replace KUBEVAL=.* KUBEVAL="$(latest_version git instrumenta/kubeval)"
