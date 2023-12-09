#!/usr/bin/env bash

# Reference: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7
# Slightly modified to always retrieve latest stable Powershell version
# If changing PWSH_VERSION='latest' to a specific version, use format PWSH_VERSION='tags/v7.0.2'

case $TARGETARCH in
amd64)
  target=x64
  ;;
*)
  echo "$TARGETARCH is not supported"
  exit 1
  ;;
esac

mkdir -p "${PWSH_DIRECTORY}"
url=$(set -euo pipefail;
  curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "https://api.github.com/repos/powershell/powershell/releases/${PWSH_VERSION}" |
  jq --arg target "${target}" -r '.assets | .[] | select(.name | contains("linux-musl-" + $target)) | .url')
curl --retry 5 --retry-delay 5 -sL \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}" | tar -xz -C "${PWSH_DIRECTORY}"
chmod +x "${PWSH_DIRECTORY}/pwsh"
ln -sf "${PWSH_DIRECTORY}/pwsh" /usr/bin/pwsh
pwsh -c "Install-Module -Name PSScriptAnalyzer -RequiredVersion ${PSSA_VERSION} -Scope AllUsers -Force"
