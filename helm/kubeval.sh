#!/usr/bin/env bash
test -z "$TRACE" || set -x
set -euo pipefail
USAGE="Usage:
  $0 [CHART]...

Validate one or more helm charts against the k8s schema using kubeval.
Checks all helm/ subdirs with a Chart.yaml file if no args are specified.
Files matching test*.yaml and test*/*.yaml will be used as values files.
"


main() {
    echo "$*" | grep -Eqvw -- "-h|--help|help" || { echo "$USAGE"; exit; }
    test $# -gt 0 || set -- helm/*/Chart.yaml
    STATUS=0
    for CHART in "$@"; do
        validate_chart "${CHART/\/Chart.yaml/}" || STATUS=1
    done
    exit "$STATUS"
}


validate_chart() {(
    log "Validating chart $1..."
    cd "$1" || die "Cannot cd into $1"
    check_dependencies
    TEST_VALUES=$(echo test*.yaml test*/*.yaml)
    if [ -z "$TEST_VALUES" ]; then
        validate_schema
    else
        for VALUES in $TEST_VALUES; do
            validate_schema --values "$VALUES"
        done
    fi
)}


check_dependencies() {
    log "Checking dependencies"
    if helm dependency list | grep -iq missing; then
        log "Missing dependency found - updating"
        helm dependency update .
    fi
}


validate_schema() {
    log "Running kubeval (templating ${*:-without values})"
    helm template "$@" . | kubeval -v "$KUBERNETES" --strict --force-color
}


# logging and formatting utilities
log() { printf "\e[32mINFO\e[0m %s\n" "$*" >&2; }
err() { printf "\e[31mERRO\e[0m %s\n" "$*" >&2; }
die() { err "$@"; exit 1; }


main "$@"
