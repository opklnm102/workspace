#!/usr/bin/env bash

# Show certificate expire at
# ./shell <dir>

set -e

err() {
  (>&2 echo "${1} Exiting...")
  exit 1
}

if [ -z "${1}" ]; then
  err "input plz certificate path"
fi

certificate_path=${1}
certificates=$(find "${certificate_path}" -name '*.pem' -o -name '*.crt')
for certificate in ${certificates}; do
  echo "${certificate}"
  openssl x509 -in "${certificate}" -noout -dates
done
