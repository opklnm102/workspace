#!/usr/bin/env bash
#
# Dependencies:
#   brew install curl
#
# Setup:
#   chmod 700 ./this-shell

set -o errexit
set -o nounset
set -o pipefail

# PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}")/.." && pwd )"  # TOOD: modify?

fail() {
  echo "ERROR: ${*}"
  exit 0
}

usage() {
  cat <<-EOM
Usage: ${0##*/} [elasticsearch cluster name]
e.g. ${0##*/} test-es
EOM
  exit 0
}

# Validate the number of command line arguments
if [[ $# -lt 1 ]]; then
  usage
fi

# Validate that this workstation has access to the required executables
command -v jq >/dev/null || fail "jq is not installed!"
command -v curl >/dev/null || fail "curl is not installed!"

# shellcheck source=./k8s.env
# source "${PROJECT_ROOT}"/k8s.env

# Sets the cluster.routing.allocation.enable settings to "none".
# Prevents shards from being migrated from an upgrading Data Node to another active Data Node.
disable_shard_allocation() {
  echo "Disable shard allocation..."
  curl -X PUT http://localhost:9200/_cluster/settings \
       -H "Content-Type: application/json" \
       -d '{"persistent":{"cluster.routing.allocation.enable":"none"}}'
  echo ""
}

# Disable cluster processes as recommended by the Elasticsearch documentation
prep_for_update() {
  disable_shard_allocation

  echo "Stop non-essential indexing and perform a sync flush..."
  curl -X POST http://localhost:9200/_flush/synced
  echo ""
}

# sets the cluster.routing.allocation.enable to the default value ("all")
enable_shard_allocation() {
  echo ""
  curl -X PUT http://localhost:9200/_cluster/settings \
       -H "Content-Type: application/json" \
       -d '{"persistent":{"cluster.routing.allocation.enable":"all"}}'
  echo ""
}

# Checks cluster health in a loop waiting for unassigned to return to 0
wait_for_allocations() {
  echo "Checking shard allocations"
  while true; do
    UNASSIGNED=$(curl http://localhost:9200/_cluster/health 2>/dev/null \
                 | jq -r '.unassigned_shards')
    if [[ "${UNASSIGNED}" == "0" ]]; then
      echo "All shards-reallocated"
      return 0
    else
      echo "Number of unassigned shards: ${UNASSIGNED}"
      sleep 3s
    fi
  done
}

# checks the cluster health endpoint and looks for a 'green' status response in a loop
# Usage:
# wait_for_green <data-nodes>
# Where:
# <data-nodes> is the number of replicas defined in the Data Node StatefulSet
wait_for_green() {
  DATA_NODES=$1
  echo "Checking cluster status"
  # First, wait for the new data node to join the cluster, wait and loop
  while true; do
    NODES=$(curl http://localhost:9200/_cluster/health 2>/dev/null \
             | jq -r '.number_of_data_nodes')
    if [[ ${NODES} == "${DATA_NODES}" ]]; then
      # Now that the data node is back, we can re-enable shard allocations
      echo "Elasticsearch cluster status has stabilized"
      enable_shard_allocation

      # Wait for the shards to re-initialize
      wait_for_allocations
      break
    fi
    echo "Data nodes available: ${NODES}, waiting..."
    sleep 20s
  done

  # Now that the data node is joined, wait for its shards to complete initialization
  while true; do
    STATUS=$(curl http://localhost:9200/_cluster/health 2>/dev/null \
             | jq -r '.status')
    if [[ "${STATUS}" == "green" ]]; then
      echo "Cluster health is now ${STATUS}, continuing upgrade...."
      disable_shard_allocation
      return 0
    fi
    echo "Cluster status: ${STATUS}"
    sleep 5s
  done
}

# Update a Statefulset's image tag then upgrade one pod at a time, waiting for the cluster health to return to 'green' before proceeding to the next pod
# Usage:
# restart_statefulset <name> <version>
# Where:
# <name> - the name of the statefulset
# <version> - the tag version to update to
restart_statefulset() {
  NAME_SPACE=${1}
  CLUSTER_NAME=${2}
  
  echo "Restarting the ${CLUSTER_NAME} Statefulset to Elasticsearch"

  # For a statefulset with 3 replicas, this will loop three times wth the 'ORDINAL' values 2, 1, and 0
  REPLICAS=$(kubectl --namespace ${NAME_SPACE} get statefulset "${CLUSTER_NAME}" -o jsonpath='{.spec.replicas}')
  MAX_ORDINAL=$(( ${REPLICAS} - 1 ))
  for ORDINAL in $(seq "${MAX_ORDINAL}" 0); do
    CURRENT_POD="${NAME}-${ORDINAL}"
    echo "Restarting ${CURRENT_POD}"

    kubectl --namespace ${NAME_SPACE} delete pod "${CURRENT_POD}"

    # Give some time for the es java process to terminate and the cluster state to turn 'yellow'
    sleep 3s

    # Now wait for the cluster health to return to 'green'
    wait_for_green "${REPLICAS}"
  done
}

# Re-enable any services disabled prior to the upgrade
post_update_cleanup() {
  enable_shard_allocation
}

# Run port forwarding to Elasticsearch cluster
run_port_forwarding() {
  NAME_SPACE=${1}
  CLUSTER_NAME=${2}

  kubectl --namespace ${NAME_SPACE} port-forward svc/${CLUSTER_NAME} 9200 1>&2 >/dev/null &
  # the port-forward is non-blocking, so wait a few seconds
  sleep 5s
}

# The restart procedure
restart() {
  # Make sure kubectl is configured with the correct context
  # kubectl config set-context "${ON_PREM_GKE_CONTEXT}"  TODO: change kubeconfig
  
  CLUSTER_NAME=${1}
  NAME_SPACE=$(kubectl get statefulset ${CLUSTER_NAME} -o 'custom-columns=namespace:metadata.namespace' | grep -v 'namespace')
  echo "name ${CLUSTER_NAME}"

  echo "Setting up the port forward to Elasticsearch client..."
  run_port_forwarding "${NAME_SPACE}" "${CLUSTER_NAME}"

  prep_for_update

  restart_statefulset "${CLUSTER_NAME}"

  # Terminate the port-forward process because it will fail when the clients are updated
  pkill -P $$

  # Post update cleanup
  echo "Re-extablish port-forward"
  run_port_forwarding "${NAME_SPACE}" "${CLUSTER_NAME}"

  post_update_cleanup

  pkill -P $$

  echo "Restart complete!"
}

# There is only one task, perform the update
restart "${1}"
