#!/usr/bin/env bash
#
# Dependencies:
#   brew install kubectl
#
# Setup:
#   chmod 700 ./this-shell

set -o errexit
set -o nounset
set -o pipefail

fail() {
  echo "ERROR: ${*}"
  exit 2
}

usage() {
  cat <<-EOM
Usage: ${0##*/} [deployment name] [before version]
EOM
  exit 1
}

if [[ $# -lt 2 ]]; then
  usage
fi



rollback_deployment() {
  deployments="${1}"
  before_version="${2}"
  revision_position=$(( 14 - "${before_version}" ))
  revision=$(kubectl rollout history deployment/"${deployments}" | head -"${revision_position}" | tail -1 | awk '{print $1}')

  echo "revision ${revision}"

  kubectl rollout undo deployment/"${deployments}" --to-revision="${revision}"

  kubectl rollout status -w deployment/"${deployments}"
}

rollback_deployment "${1}" "${2}"
