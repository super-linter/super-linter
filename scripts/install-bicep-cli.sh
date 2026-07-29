#!/usr/bin/env bash

set -euo pipefail

# Install Bicep CLI
# Requires curl and sudo
# Reference https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/linter

INSTALL_DIR="/usr/local/bin"
EXECUTABLE_PATH="${INSTALL_DIR}/bicep"

echo "Starting Bicep CLI installation..."

download_url="https://github.com/Azure/bicep/releases/latest/download/bicep-linux-musl-x64"

echo "Downloading Bicep CLI from: ${download_url}"
curl -sSL -o ./bicep "${download_url}"

echo "Setting execute permission for the Bicep binary..."
chmod +x ./bicep

echo "Moving Bicep CLI to ${EXECUTABLE_PATH}..."
if command -v sudo >/dev/null 2>&1; then
  sudo mv ./bicep "${EXECUTABLE_PATH}"
else
  mv ./bicep "${EXECUTABLE_PATH}"
fi

echo "Verifying the installation..."
bicep_cli_version=$("${EXECUTABLE_PATH}" --version)

echo "Bicep CLI installed successfully!"
echo "Version: ${bicep_cli_version}"
