#!/usr/bin/env bash

# Usage
# ./remote-xxx

docker rm $(docker ps -a | grep 'Exited' | awk '{print $1}')
