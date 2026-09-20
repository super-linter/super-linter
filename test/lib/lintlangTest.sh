#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

LINTLANG_TEST_BIN_DIRECTORY="$(mktemp -d)"
SYSTEM_PATH="${PATH}"

WriteLintLangStub() {
  local STDERR_MESSAGE="${1}"
  local EXIT_CODE="${2}"

  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "%s" >&2\nexit %s\n' "${STDERR_MESSAGE}" "${EXIT_CODE}" >"${LINTLANG_TEST_BIN_DIRECTORY}/lintlang"
  chmod +x "${LINTLANG_TEST_BIN_DIRECTORY}/lintlang"
}

LintLangNoSupportedFilesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  WriteLintLangStub "Error: No files were successfully scanned." "1"
  export PATH="${LINTLANG_TEST_BIN_DIRECTORY}:${SYSTEM_PATH}"

  set +o errexit
  local OUTPUT
  OUTPUT="$(lib/functions/lintlang.sh /workspace 2>&1)"
  local EXIT_CODE=$?
  set -o errexit

  if [[ "${EXIT_CODE}" -ne 0 ]]; then
    fatal "${FUNCTION_NAME} should return 0 for a workspace without LintLang inputs"
  fi
  if ! AssertStringsMatch "${OUTPUT}" "Error: No files were successfully scanned."; then
    fatal "${FUNCTION_NAME} should preserve LintLang's diagnostic"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangNoSupportedFilesTest

LintLangOtherFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  WriteLintLangStub "Error: Failed to parse: invalid JSON" "1"
  export PATH="${LINTLANG_TEST_BIN_DIRECTORY}:${SYSTEM_PATH}"

  set +o errexit
  local OUTPUT
  OUTPUT="$(lib/functions/lintlang.sh /workspace 2>&1)"
  local EXIT_CODE=$?
  set -o errexit

  if [[ "${EXIT_CODE}" -ne 1 ]]; then
    fatal "${FUNCTION_NAME} should preserve non-empty-scan failures"
  fi
  if ! AssertStringsMatch "${OUTPUT}" "Error: Failed to parse: invalid JSON"; then
    fatal "${FUNCTION_NAME} should preserve LintLang's diagnostic"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangOtherFailureTest

LintLangDoesNotSuppressMixedInputFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local INPUT_DIRECTORY
  INPUT_DIRECTORY="$(mktemp -d)"
  cp "test/linters/ai_lintlang/good/agent.json" "${INPUT_DIRECTORY}/agent.json"
  printf '{"tools": ' >"${INPUT_DIRECTORY}/malformed.json"
  printf 'not a LintLang input\n' >"${INPUT_DIRECTORY}/unsupported.bin"
  export PATH="${SYSTEM_PATH}"

  set +o errexit
  local OUTPUT
  OUTPUT="$(lib/functions/lintlang.sh "${INPUT_DIRECTORY}" --format terminal --fail-on fail 2>&1)"
  local EXIT_CODE=$?
  set -o errexit

  if [[ "${EXIT_CODE}" -ne 1 ]]; then
    fatal "${FUNCTION_NAME} should preserve a malformed supported-input failure"
  fi
  if [[ "${OUTPUT}" != *"Failed to parse"* ]]; then
    fatal "${FUNCTION_NAME} should preserve the malformed-input diagnostic"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangDoesNotSuppressMixedInputFailureTest

LintLangPassesCustomArgumentsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >&2\n' >"${LINTLANG_TEST_BIN_DIRECTORY}/lintlang"
  chmod +x "${LINTLANG_TEST_BIN_DIRECTORY}/lintlang"
  export PATH="${LINTLANG_TEST_BIN_DIRECTORY}:${SYSTEM_PATH}"

  local OUTPUT
  OUTPUT="$(lib/functions/lintlang.sh /workspace --patterns H1 --min-severity high 2>&1)"
  if ! AssertStringsMatch "${OUTPUT}" "scan /workspace --patterns H1 --min-severity high"; then
    fatal "${FUNCTION_NAME} should pass configured LintLang arguments unchanged"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangPassesCustomArgumentsTest
