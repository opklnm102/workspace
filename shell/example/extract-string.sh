#!/usr/bin/env bash

AAA=abcd-96655dd89-zgsqv
BBB=abcd-1629826800-m9pfj

AAA_TEMP=${AAA: -16}
BBB_TEMP=${BBB: -16}

echo "${AAA_TEMP}"
echo "${BBB_TEMP}"

echo "${AAA: -16}" | sed 's/^-//'
echo "${BBB: -16} "| sed 's/^-//'

# https://github.com/pinpoint-apm/pinpoint/issues/7171
