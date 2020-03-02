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

URL=$1
COUNT=$2
TOTAL_TIME=0

let i=$COUNT-1
while [ $i -ge 0 ]; do
  RESPONSE=$(curl -w "$i: %{time_total}\n" -o /dev/null -s "${URL}")\
  RESPONSE_TIME=$(echo "${RESPONSE}" | cut -f2 -d ' ')
  TOTAL_TIME=$(echo "scale=3; ${TOTAL_TIME}+${RESPONSE_TIME}" | bc)

  let i=i-1
done

AVERAGE_TIME=$(echo "scale=3; ${TOTAL_TIME}/${COUNT}" | bc)
echo "--------------------------------"
echo "Average: ${TOTAL_TIME} / ${COUNT} = ${AVERAGE_TIME}"

ELAPSED_TIME=$(($SECONDS - $START_TIME))
echo "elapsed time: ${ELAPSED_TIME}"
