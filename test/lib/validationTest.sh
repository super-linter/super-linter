#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
CREATE_LOG_FILE=false
# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

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

# In the current implementation, there is no return value to assert
function ValidateDeprecatedVariablesTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

  ERROR_ON_MISSING_EXEC_BIT="true" \
    ValidateDeprecatedVariables
  EXPERIMENTAL_BATCH_WORKER="true" \
    ValidateDeprecatedVariables
  LOG_LEVEL="TRACE" \
    ValidateDeprecatedVariables
  LOG_LEVEL="VERBOSE" \
    ValidateDeprecatedVariables
  VALIDATE_JSCPD_ALL_CODEBASE="true" \
    ValidateDeprecatedVariables
  VALIDATE_KOTLIN_ANDROID="true" \
    ValidateDeprecatedVariables

  notice "${FUNCTION_NAME} PASS"
}

IsUnsignedIntegerSuccessTest
IsUnsignedIntegerFailureTest
ValidateDeprecatedVariablesTest
