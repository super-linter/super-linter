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
source "test/testUtils.sh"

# The sqlfluff command needs this, but we don't want to make this test
# dependent on other files
# shellcheck disable=SC2034
SQLFLUFF_LINTER_RULES="SQLFLUFF_LINTER_RULES"

# shellcheck source=/dev/null
source "lib/globals/linterCommandsOptions.sh"

LanguagesWithFixModeTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  for LANGUAGE in "${LANGUAGES_WITH_FIX_MODE[@]}"; do
    local FIX_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_FIX_MODE_OPTIONS"
    local CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_CHECK_ONLY_MODE_OPTIONS"
    if [[ -v "${FIX_MODE_OPTIONS_VARIABLE_NAME}" ]] ||
      [[ -v "${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}" ]]; then
      debug "${LANGUAGE} has check-only mode or fix mode options as expected"
    else
      fatal "${LANGUAGE} is in the list of languages that support fix mode, but neither check-only mode, nor fix mode options were found"
    fi
  done

  notice "${FUNCTION_NAME} PASS"
}

LanguagesWithFixModeTest
