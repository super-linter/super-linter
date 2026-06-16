#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

echo -e "Versions file (${VERSION_FILE}) contents:\n$(cat "${VERSION_FILE}")"

VersionsFileSortTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  if ! sort --check "${VERSION_FILE}"; then
    fatal "Linters version file (${VERSION_FILE}) is not sorted"
  fi

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileCompletenessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local LINTERS_VERSION_FILE_LINES_COUNT
  LINTERS_VERSION_FILE_LINES_COUNT=$(wc --lines "${VERSION_FILE}" | awk '{print $1}')
  debug "Linters version file lines count: ${LINTERS_VERSION_FILE_LINES_COUNT}"

  local EXPECTED_LANGUAGE_COUNT=${#LANGUAGE_ARRAY[@]}

  if ! IsStandardImage; then
    EXPECTED_LANGUAGE_COUNT=$((EXPECTED_LANGUAGE_COUNT - ${#LANGUAGES_NOT_IN_SLIM_IMAGE[@]}))
  fi

  if [[ ${LINTERS_VERSION_FILE_LINES_COUNT} -ne ${EXPECTED_LANGUAGE_COUNT} ]]; then
    fatal "Linters version file lines count (${LINTERS_VERSION_FILE_LINES_COUNT}) doesn't match the length of the languages array (${EXPECTED_LANGUAGE_COUNT}). Is a version descriptor missing in the versions file? Is the version descriptor spanning multiple lines?"
  else
    debug "The versions file lines count (${LINTERS_VERSION_FILE_LINES_COUNT}) matches the expected value (${EXPECTED_LANGUAGE_COUNT})"
  fi

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    if ! IsStandardImage && ! IsLanguageInSlimImage "${LANGUAGE}"; then
      debug "Skip checking if ${LANGUAGE} is in the versions file because ${LANGUAGE} is not included in the slim image"
      continue
    fi

    if ! grep -q "${LANGUAGE}" "${VERSION_FILE}"; then
      fatal "${LANGUAGE} is absent from the versions file"
    else
      debug "${LANGUAGE} present in the versions file"
    fi
  done

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileFormatTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local LINE_NUMBER=0
  local FAILED=false

  while IFS= read -r LINE; do
    LINE_NUMBER=$((LINE_NUMBER + 1))
    if [[ -z "${LINE}" ]]; then
      continue
    fi

    if [[ "${LINE}" =~ ^\[(.*?)\]\ (.*?):\ (.*)$ ]]; then
      local LANGUAGE="${BASH_REMATCH[1]}"
      local LINTER="${BASH_REMATCH[2]}"
      local VERSION_STRING="${BASH_REMATCH[3]}"

      if [[ "${VERSION_STRING}" == "Version command not supported" ]]; then
        continue
      fi

      # Check for unexpected whitespace
      if [[ "${VERSION_STRING}" =~ [[:space:]] ]]; then
        error "Version string contains whitespace in line ${LINE_NUMBER} for ${LANGUAGE} (${LINTER}): '${VERSION_STRING}'"
        FAILED=true
      fi

      # Check for SemVer-like (X.Y) OR 4+ digit build number (like xmllint's 21309)
      if [[ ! "${VERSION_STRING}" =~ ([0-9]+\.[0-9]+)|([0-9]{4,}) ]]; then
        error "Invalid version format in line ${LINE_NUMBER} for ${LANGUAGE} (${LINTER}): '${VERSION_STRING}'"
        FAILED=true
      fi
    else
      error "Invalid line format in line ${LINE_NUMBER}: '${LINE}'"
      FAILED=true
    fi
  done <"${VERSION_FILE}"

  if [[ "${FAILED}" == "true" ]]; then
    fatal "One or more version strings are not well formatted"
  fi

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileSortTest
VersionsFileCompletenessTest
VersionsFileFormatTest
