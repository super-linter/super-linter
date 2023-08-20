#!/usr/bin/env bash

set -euo pipefail

case $TARGETARCH in
amd64)
  target=x64
  ;;
arm64)
  target=arm64
  ;;
*)
  echo "$TARGETARCH is not supported"
  exit 1
  ;;
esac

url=$(curl -s \
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

curl --retry 5 --retry-delay 5 -sO "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-${target}-release.zip"
unzip -q dartsdk-linux-${target}-release.zip
chmod +x dart-sdk/bin/dart* && mv dart-sdk/bin/* /usr/bin/ && mv dart-sdk/lib/* /usr/lib/ && mv dart-sdk/include/* /usr/include/
rm -r dart-sdk/ dartsdk-linux-${target}-release.zip
