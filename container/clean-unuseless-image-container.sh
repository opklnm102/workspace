#!/usr/bin/env bash

# Usage
# ./remote-xxx

docker rm $(docker ps -qa --no-trunc --filter 'status=exited')
docker volume rm $(docker volume ls -qf dangling=true)
docker rmi $(docker images --filter 'dangling=true' -q --no-trunc)
docker rmi $(docker images | grep 'none' | awk '/ / { print $3 }')
