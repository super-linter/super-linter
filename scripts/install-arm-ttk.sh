#!/usr/bin/env bash

set -euo pipefail

# Depends on PowerShell
# Reference https://github.com/Azure/arm-ttk
# Reference https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit

url=$(
  set -euo pipefail
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    https://api.github.com/repos/Azure/arm-ttk/releases/latest | jq -r '.tarball_url'
)
mkdir -p /usr/lib/microsoft
curl --retry 5 --retry-delay 5 -sL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}" | tar -xz -C /usr/lib/microsoft
mv /usr/lib/microsoft/Azure-arm-ttk-*/arm-ttk /usr/lib/microsoft/arm-ttk
rm -rf /usr/lib/microsoft/Azure-arm-ttk-*
chmod a+x /usr/lib/microsoft/arm-ttk/arm-ttk.psd1
ln -sTf /usr/lib/microsoft/arm-ttk/arm-ttk.psd1 /usr/bin/arm-ttk
