#!/usr/bin/env bash

set -euo pipefail

case $TARGETARCH in
amd64)
  target=x86_64
  ;;
arm64)
  target=arm64
  ;;
*)
  echo "$TARGETARCH is not supported"
  exit 1
  ;;
esac

url=$(set -euo pipefail; curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/tags/${GLIBC_VERSION}" |
  jq --arg name "glibc-${GLIBC_VERSION}.apk" -r '.assets | .[] | select(.name | contains($name)) | .url')
curl --retry 5 --retry-delay 5 -sL -o "glibc-${GLIBC_VERSION}.apk" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
apk add --no-cache --force-overwrite "glibc-${GLIBC_VERSION}.apk"
rm "glibc-${GLIBC_VERSION}.apk"

# Install zlib
mkdir /tmp/libz
curl --retry 5 --retry-delay 5 -sL https://www.archlinux.org/packages/core/${target}/zlib/download | tar -x --zstd -C /tmp/libz
mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib
rm -rf /tmp/libz
