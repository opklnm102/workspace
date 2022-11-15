#!/usr/bin/env bash
#
# Dependencies:
#   brew install jq
#
# Setup:
#   chmod 700 ./this-shell

set -e

# read AWS Route53 hosted zone id
for hosted_zone_id in $(aws route53 list-hosted-zones | jq -r '.HostedZones | .[].Id'); do
  echo "----------------------------------------------------------------"
  echo "hosted zone id: ${hosted_zone_id}"
  aws route53 list-resource-record-sets --hosted-zone-id ${hosted_zone_id}
done
