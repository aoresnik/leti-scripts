#! /bin/bash

# Based on:
# - https://www.docker.com/blog/checking-your-current-docker-pull-rate-limits-and-status/
# - https://stackoverflow.com/a/64738108

TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
DOCKER_RESULT="$(curl -s -I -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1)"

RATELIMIT_REMAINING=$(echo "${DOCKER_RESULT}" | grep "^ratelimit-remaining: " | sed -e "s/^ratelimit-remaining: \(.*\);w.*$/\1/g")
RATELIMIT_TOTAL=$(echo "${DOCKER_RESULT}" | grep "^ratelimit-limit: " | sed -e "s/^ratelimit-limit: \(.*\);w.*$/\1/g")
RATELIMIT_SOURCE=$(echo "${DOCKER_RESULT}" | grep "^docker-ratelimit-source: " | sed -e "s/^docker-ratelimit-source: \(.*\)\r$/\1/g")

echo "Docker hub limit for this outgoing IP (${RATELIMIT_SOURCE}): remaining ${RATELIMIT_REMAINING} of total ${RATELIMIT_TOTAL}"

if [ "${RATELIMIT_REMAINING}" -le 0 ]; then
    exit 1
else
    exit 0
fi

