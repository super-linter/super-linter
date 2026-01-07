#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

DebugVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local -a LOG_LEVEL_DEBUG_VARIABLE_NAMES=(
    "ACTIONS_RUNNER_DEBUG"
    "ACTIONS_STEPS_DEBUG"
    "RUNNER_DEBUG"
  )

  local EXPECTED_LOG_LEVEL="DEBUG"

  for variable_name in "${LOG_LEVEL_DEBUG_VARIABLE_NAMES[@]}"; do
    debug "Testing ${variable_name}"
    declare -n LOG_LEVEL_VARIABLE="${variable_name}"
    if [[ "${variable_name}" != "RUNNER_DEBUG" ]]; then
      LOG_LEVEL_VARIABLE="true"
    else
      LOG_LEVEL_VARIABLE=1
    fi

    # Set LOG_LEVEL to a value that allows to emit all messages (as DEBUG), but
    # that's not DEBUG. This is useful to check that LOG_LEVEL will be set to
    # DEBUG as expected after sourcing log.sh
    LOG_LEVEL="TRACE"
    # shellcheck source=/dev/null
    source "lib/functions/log.sh"

    if [[ "${LOG_LEVEL}" != "${EXPECTED_LOG_LEVEL}" ]]; then
      fatal "Variable name: ${variable_name}. Value: ${LOG_LEVEL_VARIABLE}. LOG_LEVEL (${LOG_LEVEL}) doesn't match the expected value: ${EXPECTED_LOG_LEVEL}"
    fi

    # Setting back to the default
    if [[ "${variable_name}" != "RUNNER_DEBUG" ]]; then
      LOG_LEVEL_VARIABLE="false"
    else
      LOG_LEVEL_VARIABLE=0
    fi
    unset -n LOG_LEVEL_VARIABLE
  done

  # Source log again to reset state
  # shellcheck source=/dev/null
  source "test/testUtils.sh"

  notice "${FUNCTION_NAME} PASS"
}

DebugVariablesTest
