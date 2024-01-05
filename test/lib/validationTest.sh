#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

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

# shellcheck disable=SC2034
CREATE_LOG_FILE=false

# shellcheck source=/dev/null
source "lib/functions/validation.sh"

function IsUnsignedIntegerSuccessTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

  if ! IsUnsignedInteger 1; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function IsUnsignedIntegerFailureTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

  if IsUnsignedInteger "test"; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

IsUnsignedIntegerSuccessTest
IsUnsignedIntegerFailureTest
