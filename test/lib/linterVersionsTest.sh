#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

VersionsFileSortTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  if sort --check "${VERSION_FILE}"; then
    fatal "Linters version file (${LINTERS_VERSION_FILE_LINES_COUNT}) is not sorted"
  fi

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileLengthTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local LINTERS_VERSION_FILE_LINES_COUNT
  LINTERS_VERSION_FILE_LINES_COUNT=$(wc --lines "${VERSION_FILE}" | awk '{print $1}')
  debug "Linters version file lines count: ${LINTERS_VERSION_FILE_LINES_COUNT}"

  if [[ ${LINTERS_VERSION_FILE_LINES_COUNT} -ne ${#LANGUAGE_ARRAY[@]} ]]; then
    fatal "Linters version file lines count (${LINTERS_VERSION_FILE_LINES_COUNT}) doesn't match the length of the languages array (${#LANGUAGE_ARRAY[@]}). Is a version descriptor missing from the versions file, or does a version string span more than one line?"
  fi

  fatal "Not yet implemented"

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileSortTest
VersionsFileLengthTest
