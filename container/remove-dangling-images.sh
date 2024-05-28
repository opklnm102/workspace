#!/usr/bin/env bash

# Usage
# ./remote-xxx

set -e

docker image rm $(docker image ls -f "dangling=true" -q)
