#!/usr/bin/env bash

# replace-with-sed: use sed for text replace
#
# Usage: ./replace-with-sed.sh <source> <old text> <new text>


if [ -z "${1}" ]; then
  echo "input plz source"
  return;
fi

if [ -z "${2}" ]; then
  echo "input plz find word"
  return;
fi

if [ -z "${3}" ]; then
  echo "input plz replace word"
  return;
fi

source=${1}
old_text=${2}
new_text=${3}

for file in $(find ${source} -name "*.yaml"); do
  echo ${file}

  if [ "$(uname -s)" = "Darwin" ]; then
    sed -i "" "s/${old_text}/${new_text}/g" ${file}
  else
    sed -i "s/${old_text}/${new_text}/g" ${file}
  fi
done

