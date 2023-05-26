#!/usr/bin/env bash

set -euo pipefail

url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "https://api.github.com/repos/checkstyle/checkstyle/releases/tags/checkstyle-${CHECKSTYLE_VERSION}" |
  jq --arg name "checkstyle-${CHECKSTYLE_VERSION}-all.jar" -r '.assets | .[] | select(.name==$name) | .url')
curl --retry 5 --retry-delay 5 -sL -o /usr/bin/checkstyle \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
chmod a+x /usr/bin/checkstyle
