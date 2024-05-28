#!/usr/bin/env bash
#
# Dependencies:
#   brew install docker
#
# Setup:
#   chmod 700 ./this-shell

set -e

usage() {
  cat <<-EOM
1 argument (FIND IMAGE_NAME: more than 2 charater) needed

Usage: ${0##*/} [image name] ([-f|--force])
EOM
  exit 0
}

while [[ $# -gt 1 ]]; do
  key="${1}"
  force=false

  case "${key}" in
    -f|--force)
      force=true
    ;;
    *)
      # unknown option
    ;;
  esac
  shift
done

if [ -z "${1}" ] || [ ${#1} -lt 3 ]; then
  usage
fi

image_name=${1}
images=$(docker image ls | grep "${image_name}" | awk '{print $3}')

if [ -z "${images}" ]; then
  echo "Matching images not found. ${image_name}"
  exit 0
elif [ "${force}" ]; then
  docker image rm -f "${images}"
else
  docker image rm "${images}"
fi

echo "======================================="
echo "Current Docker Images"
echo "======================================="

docker image ls
