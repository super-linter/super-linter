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

# shellcheck source=/dev/null
source "lib/functions/output.sh"

TEMP_WORKSPACE="$(pwd)/super-linter-output"

function InitWorkspace() {
  CleanupWorkspace
  mkdir -p "${TEMP_WORKSPACE}"
}

function CleanupWorkspace() {
  rm -rf "${TEMP_WORKSPACE}"
}

CheckIfContentsDiff() {
  local INPUT_FILE_CONTENT
  INPUT_FILE_CONTENT="$(cat "${1}")"
  local EXPECTED_CONTENT="${2}"
  if [[ "${INPUT_FILE_CONTENT}" != "${EXPECTED_CONTENT}" ]]; then
    fatal "\n${INPUT_FILE_CONTENT}\ncontents don't match the expected contents:\n${EXPECTED_CONTENT}"
  else
    debug "\n${INPUT_FILE_CONTENT}\ncontents match the expected contents\n${EXPECTED_CONTENT}"
  fi
}

function WriteSummaryMarkdownTableHeaderTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output.md"
  InitWorkspace
  WriteSummaryHeader "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF
# Super-linter summary

| Language | Validation result |
| -------- | ----------------- |
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableLineSuccessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"
  InitWorkspace
  WriteSummaryLineSuccess "${RESULTS_FILE}" "Test Language"
  CheckIfContentsDiff "${RESULTS_FILE}" "| Test Language | Pass ✅ |"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableLineFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"
  InitWorkspace
  WriteSummaryLineFailure "${RESULTS_FILE}" "Test Language"
  CheckIfContentsDiff "${RESULTS_FILE}" "| Test Language | Fail ❌ |"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableFooterSuccessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"
  InitWorkspace
  WriteSummaryFooterSuccess "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

All files and directories linted successfully
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableFooterFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"
  InitWorkspace
  WriteSummaryFooterFailure "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

Super-linter detected linting errors
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

RemoveAnsiColorCodesFromFileTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace

  local TEST_CASE_FILE_WITH_ANSI_COLOR_CODES="test/data/output/ansi-color-codes/super-linter-parallel-stdout-ARM"
  local EXPECTED_TEST_CASE_FILE_WITHOUT_ANSI_COLOR_CODES="test/data/output/ansi-color-codes/super-linter-parallel-stdout-ARM-no-ANSI-color-codes"
  local INPUT_FILE
  INPUT_FILE="${TEMP_WORKSPACE}/$(basename "${TEST_CASE_FILE_WITH_ANSI_COLOR_CODES}")"
  cp "${TEST_CASE_FILE_WITH_ANSI_COLOR_CODES}" "${INPUT_FILE}"
  RemoveAnsiColorCodesFromFile "${INPUT_FILE}"
  AssertFileAndDirContentsMatch "${INPUT_FILE}" "${EXPECTED_TEST_CASE_FILE_WITHOUT_ANSI_COLOR_CODES}"

  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableHeaderTest
WriteSummaryMarkdownTableLineSuccessTest
WriteSummaryMarkdownTableLineFailureTest
WriteSummaryMarkdownTableFooterSuccessTest
WriteSummaryMarkdownTableFooterFailureTest
RemoveAnsiColorCodesFromFileTest
