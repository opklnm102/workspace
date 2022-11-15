#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

usage() {
  cat <<-EOM
Usage: ${0##*/} [maintenance mode]
e.g. ${0##*/} (restart or shutdown)
EOM
  exit 1
}

if [[ $# != 1 ]]; then
  usage
fi

echo -n "Are you really run? (yes or no): "
read -r CONFIRM

if [ ! "${CONFIRM}" == "yes" ]; then
  echo "Exit..."
  exit 0
fi

maintenance_mode=${1}

if [ "${maintenance_mode}" = "restart" ]; then
  kubectl rollout restart deployment -l maintenance=db
fi

if [ "${maintenance_mode}" = "shutdown" ]; then
  for deployment in $(kubectl get deployment -l maintenance=db -o name); do
    kubectl scale --replicas=0 "${deployment}"
  done
fi

echo "Done..."
