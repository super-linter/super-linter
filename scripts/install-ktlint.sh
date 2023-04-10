#!/usr/bin/env bash

set -euo pipefail

##################
# Install ktlint #
##################
url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "https://api.github.com/repos/pinterest/ktlint/releases/tags/${KTLINT_VERSION}" |
  jq -r '.assets | .[] | select(.name=="ktlint") | .url')
curl --retry 5 --retry-delay 5 -sL -o "/usr/bin/ktlint" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
chmod a+x /usr/bin/ktlint
terrascan init
cd ~ && touch .chktexrc

####################
# Install dart-sdk #
####################
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

curl --retry 5 --retry-delay 5 -sO "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip"
unzip -q dartsdk-linux-x64-release.zip
chmod +x dart-sdk/bin/dart* && mv dart-sdk/bin/* /usr/bin/ && mv dart-sdk/lib/* /usr/lib/ && mv dart-sdk/include/* /usr/include/
rm -r dart-sdk/ dartsdk-linux-x64-release.zip

################################
# Create and install Bash-Exec #
################################
# shellcheck disable=SC2016
printf '#!/bin/bash\nif [[ -x "$1" ]]; then exit 0; else echo "Error: File:[$1] is not executable"; exit 1; fi' >/usr/bin/bash-exec
chmod +x /usr/bin/bash-exec
