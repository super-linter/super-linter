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

  # Ensure each line matches one of the following formats:
  # - [LANGUAGE NAME] linter name: linter_version (e.g., x.y.z, vx.y.z, x.y.z@commit-hash)
  # - [LANGUAGE NAME] linter name: Version command not supported
  local REGEX="^\[[A-Z0-9_]+\] [a-zA-Z0-9._-]+: (v?[0-9]+(\.[0-9]+)*(-[a-zA-Z0-9.-]+)?(@[0-9a-f]+)?|Version command not supported)$"

  local LINE_NUMBER=1
  while IFS= read -r LINE; do
    if [[ ! "${LINE}" =~ ${REGEX} ]]; then
      fatal "Line ${LINE_NUMBER} in versions file does not match expected format: ${LINE}"
    else
      debug "Line ${LINE_NUMBER} matches format: ${LINE}"
    fi
    ((LINE_NUMBER++))
  done <"${VERSION_FILE}"

  notice "${FUNCTION_NAME} PASS"
}

VersionsFileSortTest
VersionsFileCompletenessTest
VersionsFileFormatTest
