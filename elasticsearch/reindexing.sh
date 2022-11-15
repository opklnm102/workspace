#!/usr/bin/env bash
#
# Dependencies:
#   brew install curl
#
# Setup:
#   chmod 700 ./this-shell

# FIXME: indices
indices=(
logstash-2022.11.14
logstash-2022.11.15
logstash-2022.11.16
)

# FIXME: endpoint
ENDPOINT="<endpoint>"

for index in ${indices[@]}; do
  curl -H "Content-Type:application/json" -X POST $ENDPOINT/_reindex?wait_for_completion=false -d'{
    "source": {
      "index": "'$index'"
    },
    "dest": {
      "index": "'$index'-reindexed"
    }
  }'
done
