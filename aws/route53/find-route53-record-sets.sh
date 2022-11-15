#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

fail() {
  echo "ERROR: ${*}"
  exit 2
}

usage() {
  cat <<-EOM
USAGE: ${0##*/} [root domain]
e.g. ${0##*/} example.com
EOM
  exit 1
}

if [[ $# -lt 1]]; then
  usage
fi

# 원하는 도메인의 record sets을 추출
hosted_zone_name=${1}

## read hosted-zones
# 여기서 hosted-zones ID를 얻어서
hosted_zone_id=$(aws route53 list-hosted-zones --output text | grep ${hosted_zone_name} | awk '{print $3}')

# 여기서 hosted-zone의 record-set을 조회한다
for record_set in $(aws route53 list-resource-record-sets --hosted-zone-id ${hosted_zone_id} --output text)
do
  echo "${record_set}"
done
