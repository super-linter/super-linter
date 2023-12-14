#!/usr/bin/env bash

set -euo pipefail

GOOGLE_JAVA_FORMAT_VERSION="$(
  set -euo pipefail
  grep <"google-java-format/build.gradle" "google-java-format" | awk -F ':' '{print $3}' | tr -d "'"
)"
echo "Installing Google Java Format: ${GOOGLE_JAVA_FORMAT_VERSION}"

url=$(
  set -euo pipefail
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    "https://api.github.com/repos/google/google-java-format/releases/tags/v${GOOGLE_JAVA_FORMAT_VERSION}" |
    jq --arg name "google-java-format-${GOOGLE_JAVA_FORMAT_VERSION}-all-deps.jar" -r '.assets | .[] | select(.name==$name) | .url'
)
curl --retry 5 --retry-delay 5 -sL -o /usr/bin/google-java-format \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
chmod a+x /usr/bin/google-java-format
