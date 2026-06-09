#!/usr/bin/env bash

set -euo pipefail

KTLINT_VERSION="$(
  set -euo pipefail
  awk -F "[:']" '/ktlint/ {print $4}' "ktlint/build.gradle"
)"
echo "Installing Ktlint: ${KTLINT_VERSION}"

ktlint_tags=$(
  set -euo pipefail
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    "https://api.github.com/repos/ktlint/ktlint/releases/tags/${KTLINT_VERSION}"
)

echo "ktlint tags: ${ktlint_tags}"

url=$(
  set -euo pipefail
  jq -r '.assets | .[] | select(.name=="ktlint") | .url' <<<"${ktlint_tags}"
)
echo "ktlint asset URL: ${url}"

curl --retry 5 --retry-delay 5 -sL -o "/usr/bin/ktlint" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
chmod a+x /usr/bin/ktlint
