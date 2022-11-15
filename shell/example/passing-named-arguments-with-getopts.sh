#!/usr/bin/env bash

OPTIND=1  # reset in case getopts has been used previously in the shell

output_file=""
verbose=0

function show_help() {
  echo "Usage: $0 [-o --output] [-v --verbose]"
  echo " -o --output       Output file"
  echo " -v --verbose      Enable verbose mode"
  echo ""
  echo "Example: $0 --output result.log --verbose"
}

while getopts "h?vo:" opt; do
  case "${opt}" in
  h|\?)
    show_help
    exit 0
    ;;
  v)
    verbose=1
    ;;
  o)
    output_file=${OPTARG}
    ;;
  esac
done

shift $((OPTIND-1))

[[ "${1:-}" = "--" ]] && shift

echo "verbose=$verbose, output_file=$output_file, Leftovers: $@"
