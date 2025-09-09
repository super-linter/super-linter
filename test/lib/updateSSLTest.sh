#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/updateSSL.sh"

InstallCaCertTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local SSL_CERT_SECRET
  # shellcheck disable=SC2034
  SSL_CERT_SECRET="$(cat "${TEST_ROOT_CA_CERT_FILE_PATH}")"

  local CERT_DEST_FILE_PATH="/usr/local/share/ca-certificates/cert.crt"

  InstallCaCert

  if [ ! -e "${CERT_DEST_FILE_PATH}" ]; then
    fatal "CERT_DEST_FILE_PATH (${CERT_DEST_FILE_PATH}) does not exist and it should"
  fi

  if ! diff "${TEST_ROOT_CA_CERT_FILE_PATH}" "${CERT_DEST_FILE_PATH}"; then
    fatal "CERT_DEST_FILE_PATH (${CERT_DEST_FILE_PATH}) does not have the expected contents"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InstallCaCertTest
