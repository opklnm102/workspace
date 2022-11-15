#!/usr/bin/env bash

for file in $(find $1 -name *.yaml); do
  echo ${file}
done
