#!/usr/bin/env bash

set -euo pipefail

# Install Bicep CLI
# Requires curl and sudo
# Reference https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/linter

INSTALL_DIR="/usr/local/bin"
EXECUTABLE_PATH="${INSTALL_DIR}/bicep"

info() {
  echo -e "\e[32m[INFO] \e[0m$*\e[0m"
}

warning() {
  echo -e "\e[33m[WARN] \e[0m$*\e[0m"
}

error() {
  echo -e "\e[31m[ERROR] \e[0m$*\e[0m"
  exit 1
}

info "Starting Bicep CLI installation..."

download_url="https://github.com/Azure/bicep/releases/latest/download/bicep-linux-musl-x64"

info "Downloading Bicep CLI from: ${download_url}"
curl -sSL -o ./bicep "${download_url}"

info "Setting execute permission for the Bicep binary..."
chmod +x ./bicep

info "Moving Bicep CLI to ${EXECUTABLE_PATH}..."
if command -v sudo >/dev/null 2>&1; then
  sudo mv ./bicep "${EXECUTABLE_PATH}"
else
  mv ./bicep "${EXECUTABLE_PATH}"
fi

info "Verifying the installation..."
bicep_cli_version=$("${EXECUTABLE_PATH}" --version)

info "Bicep CLI installed successfully!"
info "Version: ${bicep_cli_version}"
