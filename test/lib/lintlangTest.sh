#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

LINTLANG_TEST_BIN_DIRECTORY="$(mktemp -d)"
SYSTEM_PATH="${PATH}"

LintLangEmptyScanAllowedTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  export PATH="${SYSTEM_PATH}"

  local INPUT_DIRECTORY
  INPUT_DIRECTORY="$(mktemp -d)"
  printf 'not a LintLang input\n' >"${INPUT_DIRECTORY}/unsupported.bin"

  set +o errexit
  lib/functions/lintlang.sh "${INPUT_DIRECTORY}" >/dev/null 2>&1
  local EXIT_CODE=$?
  set -o errexit

  if [[ "${EXIT_CODE}" -ne 0 ]]; then
    fatal "${FUNCTION_NAME} should return 0 for a workspace without LintLang inputs"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangEmptyScanAllowedTest

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
  if ! AssertStringsMatch "${OUTPUT}" "scan --allow-empty /workspace --patterns H1 --min-severity high"; then
    fatal "${FUNCTION_NAME} should pass configured LintLang arguments unchanged"
  fi

  notice "${FUNCTION_NAME} PASS"
}
LintLangPassesCustomArgumentsTest
