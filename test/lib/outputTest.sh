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
source "lib/functions/output.sh"

TEMP_WORKSPACE="$(pwd)/super-linter-output"

function InitWorkspace() {
  CleanupWorkspace
  mkdir -p "${TEMP_WORKSPACE}"
}

function CleanupWorkspace() {
  rm -rf "${TEMP_WORKSPACE}"
}

function CheckIfFileDiff() {
  local INPUT_FILE="${1}"
  local EXPECTED_FILE="${2}"
  # Remove eventual HTML comments from the expected file because we use them to disable certain linter rules
  if ! diff "${INPUT_FILE}" <(grep -vE '^\s*<!--' "${EXPECTED_FILE}"); then
    fatal "${INPUT_FILE} contents don't match with the expected contents (${EXPECTED_FILE})"
  else
    echo "${INPUT_FILE} contents match with the expected contents (${EXPECTED_FILE})"
  fi
}

function WriteSummaryMarkdownTableHeaderTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output.md"
  InitWorkspace
  WriteSummaryHeader "${RESULTS_FILE}"
  CheckIfFileDiff "${RESULTS_FILE}" "test/data/super-linter-summary/markdown/table/expected-summary-heading.md"
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
  CheckIfFileDiff "${RESULTS_FILE}" "test/data/super-linter-summary/markdown/table/expected-summary-line-success.md"
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
  CheckIfFileDiff "${RESULTS_FILE}" "test/data/super-linter-summary/markdown/table/expected-summary-line-failure.md"
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
  CheckIfFileDiff "${RESULTS_FILE}" "test/data/super-linter-summary/markdown/table/expected-summary-footer-success.md"
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
  CheckIfFileDiff "${RESULTS_FILE}" "test/data/super-linter-summary/markdown/table/expected-summary-footer-failure.md"
  CleanupWorkspace

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableHeaderTest
WriteSummaryMarkdownTableLineSuccessTest
WriteSummaryMarkdownTableLineFailureTest
WriteSummaryMarkdownTableFooterSuccessTest
WriteSummaryMarkdownTableFooterFailureTest
