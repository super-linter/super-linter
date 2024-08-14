#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/globals/languages.sh"

function LanguageArrayNotEmptyTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  if [ ${#LANGUAGE_ARRAY[@]} -gt 0 ]; then
    debug "Language array is not empty as expected"
  else
    fatal "Language array is empty"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function LanguageTestPresenceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local -l LOWERCASE_LANGUAGE="${LANGUAGE}"
    # shellcheck disable=SC2153
    local LINTER_TEST_CASE_DIRECTORY="${LINTERS_TEST_CASE_DIRECTORY}/${LOWERCASE_LANGUAGE}"

    if [[ ! -d "${LINTER_TEST_CASE_DIRECTORY}" ]]; then
      fatal "Test case directory for ${LANGUAGE} (${LINTER_TEST_CASE_DIRECTORY}) doesn't exist or is not readable."
    fi

    if [ -z "$(ls -A "${LINTER_TEST_CASE_DIRECTORY}")" ]; then
      fatal "Test case directory for ${LANGUAGE} (${LINTER_TEST_CASE_DIRECTORY}) is empty, and it should contain test cases for ${LANGUAGE}."
    fi
  done

  notice "${FUNCTION_NAME} PASS"
}

LanguageArrayNotEmptyTest
LanguageTestPresenceTest
