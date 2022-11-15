#!/usr/bin/env bash

domains=(
google.com
naver.com
)

## length
len=${#domains[*]}
for ((i=0; i<len; i++)); do
  dig +short ${domains[$i]}
done

## for-in
for domain in ${domains[@]}; do
  dig +short ${domain}
done
