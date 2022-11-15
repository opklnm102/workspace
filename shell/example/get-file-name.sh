#!/usr/bin/env bash

FILE_NAME="$(basename ${0})"
echo "${FILE_NAME}"

FILE_NAME_WITH_EXT="$(basename ${0})"
FILE_NAME_WITHOUT_EXT="${FILE_NAME_WITH_EXT%.*}"
echo "FILE_NAME_WITH_EXT"
echo "$FILE_NAME_WITHOUT_EXT"

EXT="${FILE_NAME_WITH_EXT##*.}"
echo "$EXT"


DIR_NAME="$(basename "$(cd $(dirname "${0}"); pwd -P)")"
echo "$DIR_NAME"
