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

LanguageArrayNotEmptyTest
