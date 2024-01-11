#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
CREATE_LOG_FILE=false
# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"
# shellcheck disable=SC2034
LOG_TRACE="true"
# shellcheck disable=SC2034
LOG_DEBUG="true"
# shellcheck disable=SC2034
LOG_VERBOSE="true"
# shellcheck disable=SC2034
LOG_NOTICE="true"
# shellcheck disable=SC2034
LOG_WARN="true"
# shellcheck disable=SC2034
LOG_ERROR="true"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

GITHUB_DOMAIN="github.com"
# shellcheck disable=SC2034
GITHUB_META_URL="https://api.${GITHUB_DOMAIN}/meta"

# shellcheck source=/dev/null
source "lib/functions/setupSSH.sh"

function GetGitHubSshRsaKeyFingerprintTest() {
  local SSH_RSA_KEY_FINGERPRINT
  SSH_RSA_KEY_FINGERPRINT=$(GetGitHubSshRsaKeyFingerprint)

  debug "SSH_RSA_KEY_FINGERPRINT: ${SSH_RSA_KEY_FINGERPRINT}"
  local EXPECTED_GITHUB_RSA_KEY_FINGERPRINT
  EXPECTED_GITHUB_RSA_KEY_FINGERPRINT="$(ssh-keygen -lf /dev/stdin <<<"$(ssh-keyscan -t rsa github.com)" | cut -d ' ' -f2)"
  debug "Expected output: ${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}"

  if [ "${SSH_RSA_KEY_FINGERPRINT}" != "${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}" ]; then
    fatal "SSH_RSA_KEY_FINGERPRINT is not equal to ${EXPECTED_GITHUB_RSA_KEY_FINGERPRINT}: ${SSH_RSA_KEY_FINGERPRINT}"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

function SetupGithubComSshKeysTest() {
  SSH_KEY="test_ssh_key" SSH_INSECURE_NO_VERIFY_GITHUB_KEY="false" SetupGithubComSshKeys

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

GetGitHubSshRsaKeyFingerprintTest
SetupGithubComSshKeysTest
