#!/usr/bin/env bash

### 1. bash space-separated(e.g. --option argument)
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case ${key} in
    -e|--extension)
      EXTENSION="$2"
      shift  # past argument
      shift  # past value
      ;;
    -s|--searchpath)
      SEARCH_PATH="$2"
      shift  # past argument
      shift  # past value
      ;;
    *)
      POSITIONAL+=("$1")  # save it in an array for later
      shift  # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}"  # restore positional parameters

#### 2. bash equals-separated(e.g. --option=argument)
for key in "$@"; do
  case ${key} in
    -e=*|--extension=*)
      EXTENSION="${key#*=}"
      shift  # past argument=value
      ;;
    -s=*|--searchpath)
      SEARCH_PATH="${key#*=}"
      shift  # past argument=value
      ;;
    *)
       # unknown option
    ;;
  esac
done

echo "FILE EXTENSION = ${EXTENSION}"
echo "SEARCH PATH = ${SEARCH_PATH}"
echo "Number files in SEARCH PATH with EXTENSION:" $(ls -l ${SEARCH_PATH}/*.${EXTENSION} | wc -l)

if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:"
  tail -1 "$1"
fi
