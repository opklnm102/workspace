#!/usr/bin/env bash

CLEAR='\033[0m'
RED='\033[0;31m'

function show_help() {
  if [[ -n "$1" ]]; then
    echo -e "${RED}👉 $1${CLEAR}\n";
  fi

  echo "Usage: $0 [-o --output] [-v --verbose]"
  echo " -o --output       Output file"
  echo " -v --verbose      Enable verbose mode"
  echo ""
  echo "Example: $0 --output result.log --verbose"
}

VERBOSE=0

while [[ "$#" -gt 0 ]]; do case $1 in
  -o|--output) OUTPUT="$2"; shift;;
  -v|--verbose) VERBOSE=1; shift;;
  *) show_help "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

## verify params
if [[ -z "$OUTPUT" ]]; then show_help "output is not set"; fi;
