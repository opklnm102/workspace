#!/usr/bin/env bash
#
# Dependencies:
#   brew install curl
#
# Setup:
#   chmod 700 ./this-shell


function usage() {
  echo "Usage: $0 url count"
  echo "Example: $0 example.com 10"
}

if [ $# -ne 2 ]; then
  usage;
  exit;
fi

START_TIME=$SECONDS

export URL=$1
COUNT=$2
TOTAL_TIME=0

for RESPONSE_TIME in $(seq 1 ${COUNT} | xargs -n1 -P3 bash -c 'curl -o /dev/null -s -w "%{time_total}\n" ${URL}'); do
  TOTAL_TIME=$(echo "scale=3; ${TOTAL_TIME} + ${RESPONSE_TIME}" | bc)
done

AVERAGE_TIME=$(echo "scale=3; ${TOTAL_TIME}/${COUNT}" | bc)
echo "--------------------------------"
echo "Average: ${TOTAL_TIME} / ${COUNT} = ${AVERAGE_TIME}"

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "elapsed time: ${ELAPSED_TIME}"
