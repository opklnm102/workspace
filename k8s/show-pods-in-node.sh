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

usage() {
  cat <<-EOM
USAGE: ${0##*/} [node group name]
e.g. ${0##*/} default
EOM
  exit 0
}

err() {
  (>&2 echo "${1} Exiting...")
  exit 0
}

if [[ $# -lt 1 ]]; then
  usage
fi

if [[ -z "${1}" ]]; then
  err "input plz worker node group"
fi

node_group="${1}"

for node in $(kubectl get nodes -l node-group="${node_group}" -o jsonpath='{.items..metadata.name}'); do
  echo "${node}"
  echo "--------------------------------------------------------------------------"
  kubectl get pods -o wide --all-namespaces | grep ${node}
  echo "--------------------------------------------------------------------------"
done
