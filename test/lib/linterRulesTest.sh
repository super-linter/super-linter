#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

# shellcheck source=/dev/null
source "lib/globals/linterRules.sh"

TEST_LANGUAGE_NAME="TEST_LANGUAGE"
TEST_LANGUAGE_NAME_WITHOUT_RULES="TEST_LANGUAGE_WITHOUT_RULES"
LANGUAGE_ARRAY=("${TEST_LANGUAGE_NAME}" "${TEST_LANGUAGE_NAME_WITHOUT_RULES}")

# shellcheck source=/dev/null
source "lib/functions/linterRules.sh"

# shellcheck disable=SC2034
GITHUB_WORKSPACE="$(pwd)"

function GetLinterRulesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  LinterRulesLocation

  DEFAULT_RULES_LOCATION="${DEFAULT_RULES_LOCATION:-"TEMPLATES"}"
  # Use an existing configuration file. Can be anything inside
  # DEFAULT_RULES_LOCATION
  TEST_LANGUAGE_FILE_NAME="${TEST_LANGUAGE_FILE_NAME:-".eslintrc.yml"}"
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    debug "Loading rules for ${LANGUAGE}..."
    GetLinterRules "${LANGUAGE}" "${DEFAULT_RULES_LOCATION}"
  done

  local EXPECTED_TEST_LANGUAGE_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${TEST_LANGUAGE_FILE_NAME}"
  if [[ "${TEST_LANGUAGE_LINTER_RULES}" == "${EXPECTED_TEST_LANGUAGE_LINTER_RULES}" ]]; then
    debug "TEST_LANGUAGE_LINTER_RULES (${TEST_LANGUAGE_LINTER_RULES}) matches the expected value (${EXPECTED_TEST_LANGUAGE_LINTER_RULES})"
  else
    fatal "TEST_LANGUAGE_LINTER_RULES (${TEST_LANGUAGE_LINTER_RULES}) doesn't match the expected value (${EXPECTED_TEST_LANGUAGE_LINTER_RULES})"
  fi
  if [[ -z "${TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES:-}" ]]; then
    debug "TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES is not set as expected"
  else
    fatal "TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES shouldn't be set"
  fi
  unset TEST_LANGUAGE_LINTER_RULES
  unset TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES
  unset EXPECTED_TEST_LANGUAGE_LINTER_RULES

  notice "${FUNCTION_NAME} PASS"
}

function GetLinterRulesEmptyDotRulesPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LINTER_RULES_PATH="."
  TEST_LANGUAGE_FILE_NAME="README.md"
  DEFAULT_RULES_LOCATION="$(pwd)"
  GetLinterRulesTest

  unset LINTER_RULES_PATH
  unset TEST_LANGUAGE_FILE_NAME

  notice "${FUNCTION_NAME} PASS"
}

function GetLinterRulesEmptyRootRulesPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LINTER_RULES_PATH="."
  TEST_LANGUAGE_FILE_NAME="README.md"
  DEFAULT_RULES_LOCATION="$(pwd)"
  GetLinterRulesTest

  unset LINTER_RULES_PATH
  unset TEST_LANGUAGE_FILE_NAME

  notice "${FUNCTION_NAME} PASS"
}

function LinterRulesVariablesExportTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  DEFAULT_RULES_LOCATION="TEMPLATES"
  TEST_LANGUAGE_FILE_NAME=".eslintrc.yml"

  # shellcheck source=/dev/null
  source "lib/globals/linterRules.sh"

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    debug "Loading rules for ${LANGUAGE}..."
    GetLinterRules "${LANGUAGE}" "${DEFAULT_RULES_LOCATION}"
  done

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    debug "Verify that ${LANGUAGE} configuration file variable is exported"
    if [[ "${LANGUAGE}" == "${TEST_LANGUAGE_NAME_WITHOUT_RULES}" ]]; then
      debug "${LANGUAGE} doesn't have linter configuration file variable. Skipping export test."
      continue
    fi

    local LANGUAGE_LINTER_RULES_VARIABLE_NAME="${LANGUAGE}_LINTER_RULES"
    if [[ ! -v "${LANGUAGE_LINTER_RULES_VARIABLE_NAME}" ]]; then
      fatal "${LANGUAGE_LINTER_RULES_VARIABLE_NAME} is not defined"
    fi
    local -n LANGUAGE_LINTER_RULES
    LANGUAGE_LINTER_RULES="${LANGUAGE_LINTER_RULES_VARIABLE_NAME}"

    debug "LANGUAGE_LINTER_RULES (${LANGUAGE}) variable attributes: ${LANGUAGE_LINTER_RULES@a}"
    if [[ "${LANGUAGE_LINTER_RULES@a}" == *x* ]]; then
      info "LANGUAGE_LINTER_RULES for ${LANGUAGE} is exported as expected"
    else
      fatal "LANGUAGE_LINTER_RULES for ${LANGUAGE} should have been exported"
    fi
    unset -n LANGUAGE_LINTER_RULES
  done

  notice "${FUNCTION_NAME} PASS"
}

GetLinterRulesTest
GetLinterRulesEmptyDotRulesPathTest
GetLinterRulesEmptyRootRulesPathTest
LinterRulesVariablesExportTest
