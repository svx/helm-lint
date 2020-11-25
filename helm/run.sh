#!/usr/bin/env bash
test -z "$TRACE" || set -x
set -euo pipefail
USAGE="Usage:
  $0 [CHART]...

Check helm chart(s) - run helm lint, helm dep up, helm-docs and kubeval.
Looks at all helm/ subdirs with a Chart.yaml file if no args are specified.
Files matching test*.yaml and test*/*.yaml will be used as values files.
"


main() {
    echo "$*" | grep -Eqvw -- "-h|--help|help" || { echo "$USAGE"; exit; }
    test $# -gt 0 || set -- helm/*/Chart.yaml
    HASH=$(get_hash)
    VERSION=$(get_version)
    STATUS=0
    for CHART in "$@"; do
        check_chart "${CHART/\/Chart.yaml/}" || STATUS=1
    done
    test "$STATUS" = 0 || die "Helm check failed"
    if [ "$(get_hash)" != "$HASH" ]; then
        log "Helm files updated"
        exit 1
    fi
}


get_hash() { find helm -type f -exec md5sum {} \; | sort -k2 | md5sum; }
get_version() {
    grep -E "^version = " pyproject.toml 2>/dev/null | sed -E 's/.*"(.*)"/\1/' ||
    cat VERSION 2>/dev/null ||
    git describe --abbrev=0 --tags ||
    echo 0.1.0
}

check_chart() {(
    log "Checking chart $1..."
    cd "$1" || die "Cannot cd into $1"
    log "Running helm lint"
    helm lint --strict .
    log "Running helm dependency update"
    helm dependency list | grep -iqv missing || helm dependency update .
    log "Updating chart version and image tag to $VERSION"
    sed -Ei "s/version:.*/version: '$VERSION'/" Chart.yaml
    sed -Ei "s/tag:.*/tag: '$VERSION'/" values.yaml
    log "Running helm-docs"
    helm-docs --sort-values-order file
    TEST_VALUES=$(find . -name '*.yaml' | sed -E "s|^\.||" | grep -E "^test")
    if [ -z "$TEST_VALUES" ]; then
        validate_schema
    else
        for VALUES in $TEST_VALUES; do
            validate_schema --values "$VALUES"
        done
    fi
)}

validate_schema() {
    log "Running kubeval (templating ${*:-without values})"
    helm template flywheel . "$@" | kubeval -v "$KUBERNETES" --strict --force-color
}


# logging and formatting utilities
log() { printf "\e[32mINFO\e[0m %s\n" "$*" >&2; }
err() { printf "\e[31mERRO\e[0m %s\n" "$*" >&2; }
die() { err "$@"; exit 1; }


main "$@"
