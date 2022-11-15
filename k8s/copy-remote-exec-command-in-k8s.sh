#!/usr/bin/env bash

# Usage
# ./this-shell.sh <script> <pod name>
# e.g. ./this-shell.sh script.sh pod-name

set -e

err() {
    (>&2 echo "${1} Exiting...")
    exit 1
}

if [[ -z "${1}" ]]; then
  err "input plz script"
fi

if [[ -z "${2}" ]]; then
  err "input plz pod name"
fi

SCRIPT_PATH=${1}
POD_NAME=${2}
SCRIPT_NAME=$(basename ${SCRIPT_PATH})
SCRIPT_ABSOLUTE_PATH="$(cd $(dirname ${SCRIPT_PATH}); pwd -P)/$(basename ${SCRIPT_PATH})"

if [[ ! -f ${SRC_SHELL_ABSOLUTE_PATH} ]]; then
  err "does not exist"
fi

# NAMESPACE=$(kubectl get pods ${POD_NAME} -o custom-columns=NAMESPACE:.metadata.namespace | grep -v "NAMESPACE")
NAMESPACE=$(kubectl get pods --all-namespaces | grep "${POD_NAME}" | awk '{print $1}')

echo "namespace ${NAMESPACE}"
echo "SCRIPT_PATH ${SCRIPT_PATH}"
echo "POD_NAME ${POD_NAME}"
echo "SCRIPT_NAME ${SCRIPT_NAME}"
echo "SRC_SHELL_ABSOLUTE_PATH ${SCRIPT_ABSOLUTE_PATH}"

function exec_remote_command(){
  echo "copy command to remote"
  kubectl -n ${NAMESPACE} cp ${SCRIPT_ABSOLUTE_PATH} ${NAMESPACE}/${POD_NAME}:./

  echo "run command to remote"
  kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -- ./${SCRIPT_NAME}

  echo "remove command from remote"
  kubectl -n ${NAMESPACE} exec -it ${POD_NAME} -- rm ./${SCRIPT_NAME}
}

exec_remote_command
