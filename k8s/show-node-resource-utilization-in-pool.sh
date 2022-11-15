#!/usr/bin/env bash
#
# Dependencies:
#   brew install kubectl
# 
# Setup:
#   chmod 700 ./this-shell

set -o errexit
set -o pipefail

usage() {
  cat <<-EOM
USAGE: ${0##*/} [node group name] ([availability zone])
e.g. ${0##*/} default ap-northeast-2c
EOM
  exit 1
}

err() {
  (>&2 echo "${1} Exiting...")
  exit 1
}

show_one_az() {
  node_group="${1}"
  az="${2}"

  echo "show one az"

  for node in $(kubectl get nodes -l "node-group=${node_group},failure-domain.beta.kubernetes.io/zone=${az}" | grep node | awk '{print $1}'); do
    echo "${node}"
    kubectl describe node ${node} | awk '/Namespace/,/Events/'
    echo "--------------------------------------------------------------------------"
  done
}

show_all_az() {
  node_group="${1}"

  echo "show all az"

  for node in $(kubectl get nodes -l "node-group=${node_group}" | grep "ip" | awk '{print $1}'); do
    echo "${node}"
    kubectl describe node ${node} | awk '/Namespace/,/Events/'
    echo "--------------------------------------------------------------------------"
  done
}

if [[ $# -lt 2 ]]; then
  usage
fi

if [[ -z "${1}" ]]; then
  err "input plz node group"
fi

node_group=${1}
az=${2}

if [[ -z "${AZ}" ]]; then
  show_all_az "${node_group}"
  exit 0 
fi

show_one_az "${node_group}" "${az}"
