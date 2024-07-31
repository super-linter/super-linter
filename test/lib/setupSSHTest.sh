#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

GITHUB_DOMAIN="github.com"
# shellcheck disable=SC2034
GITHUB_META_URL="https://api.${GITHUB_DOMAIN}/meta"

# shellcheck source=/dev/null
source "lib/functions/setupSSH.sh"

function GetGitHubSshRsaKeyFingerprintTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local SSH_RSA_KEY_FINGERPRINT
  SSH_RSA_KEY_FINGERPRINT=$(GetGitHubSshRsaKeyFingerprint)

  debug "SSH_RSA_KEY_FINGERPRINT: ${SSH_RSA_KEY_FINGERPRINT}"
  local EXPECTED_GITHUB_RSA_KEY_FINGERPRINT
  EXPECTED_GITHUB_RSA_KEY_FINGERPRINT="$(ssh-keygen -lf /dev/stdin <<<"$(ssh-keyscan -t rsa github.com)" | cut -d ' ' -f2)"
  debug "Expected output: ${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}"

  if [ "${SSH_RSA_KEY_FINGERPRINT}" != "${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}" ]; then
    fatal "SSH_RSA_KEY_FINGERPRINT is not equal to ${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}: ${SSH_RSA_KEY_FINGERPRINT}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function SetupGithubComSshKeysTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  SSH_KEY="test_ssh_key" SSH_INSECURE_NO_VERIFY_GITHUB_KEY="false" SetupGithubComSshKeys

  notice "${FUNCTION_NAME} PASS"
}

GetGitHubSshRsaKeyFingerprintTest
SetupGithubComSshKeysTest
