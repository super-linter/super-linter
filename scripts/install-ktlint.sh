#!/usr/bin/env bash

url=$(set -euo pipefail;
  curl -s \
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
