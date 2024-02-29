#!/usr/bin/env bash

set -euo pipefail

url=$(
  set -euo pipefail
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    "https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/tags/${GLIBC_VERSION}" |
    jq --arg name "glibc-${GLIBC_VERSION}.apk" -r '.assets | .[] | select(.name | contains($name)) | .url'
)
curl --retry 5 --retry-delay 5 -sL -o "glibc-${GLIBC_VERSION}.apk" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
apk add --no-cache --force-overwrite "glibc-${GLIBC_VERSION}.apk"
rm "glibc-${GLIBC_VERSION}.apk"

# Install zlib
apk add --no-cache --virtual .glibc-build-deps \
  tar \
  zlib \
  zstd

apk del --no-network --purge .glibc-build-deps
