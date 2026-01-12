#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/output.sh"

LOG_FILE_NAME="super-linter.log"

function InitWorkspace() {
  TEMP_WORKSPACE="$(mktemp -d)"
  initialize_temp_directory_cleanup_traps "${TEMP_WORKSPACE}"
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

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output.md"

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

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableLineSuccessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  WriteSummaryLineSuccess "${RESULTS_FILE}" "Test Language"
  CheckIfContentsDiff "${RESULTS_FILE}" "| Test Language | Pass ✅ |"

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableLineFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  WriteSummaryLineFailure "${RESULTS_FILE}" "Test Language"
  CheckIfContentsDiff "${RESULTS_FILE}" "| Test Language | Fail ❌ |"

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableFooterSuccessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  WriteSummaryFooterSuccess "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

All files and directories linted successfully
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"

  notice "${FUNCTION_NAME} PASS"
}

function WriteSummaryMarkdownTableFooterFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  WriteSummaryFooterFailure "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

Super-linter detected linting errors
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableFooterMoreInfoTest() {
  local GITHUB_WORKSPACE="${TEMP_WORKSPACE}"
  # shellcheck disable=SC2034
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${RESULTS_FILE}"
  # shellcheck disable=SC2034
  local LOG_FILE_PATH="${GITHUB_WORKSPACE}/${LOG_FILE_NAME}"

  WriteSummaryFooterMoreInfo "${RESULTS_FILE}"
  local EXPECTED_CONTENT="${1}"
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"
}

WriteSummaryFooterSuperLinterInfoTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  WriteSummaryFooterSuperLinterInfo "${RESULTS_FILE}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

Powered by [Super-linter](https://github.com/super-linter/super-linter)
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableFooterMoreInfoGitHubWorkflowTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKFLOW_RUN_URL="test-workflow-url"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

For more information, see the [GitHub Actions workflow run](${GITHUB_WORKFLOW_RUN_URL})
EOF
  )

  if ! WriteSummaryMarkdownTableFooterMoreInfoTest "${EXPECTED_CONTENT}"; then
    fatal "${FUNCTION_NAME} should have passed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableFooterMoreInfoSummaryAndLogTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local SAVE_SUPER_LINTER_SUMMARY="true"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"
  local EXPECTED_SUPER_LINTER_SUMMARY_PATH
  EXPECTED_SUPER_LINTER_SUMMARY_PATH="$(basename "${RESULTS_FILE}")"

  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

For more information, see the Super-linter summary (${EXPECTED_SUPER_LINTER_SUMMARY_PATH}) and the Super-linter log (${LOG_FILE_NAME})
EOF
  )

  if ! WriteSummaryMarkdownTableFooterMoreInfoTest "${EXPECTED_CONTENT}"; then
    fatal "${FUNCTION_NAME} should have passed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableFooterMoreInfoLogTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

For more information, see the Super-linter log (${LOG_FILE_NAME})
EOF
  )

  if ! WriteSummaryMarkdownTableFooterMoreInfoTest "${EXPECTED_CONTENT}"; then
    fatal "${FUNCTION_NAME} should have passed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

WriteMarkdownCollapsedSectionTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  local EXPECTED_SUMMARY="summary"
  local EXPECTED_BODY
  EXPECTED_BODY=$(
    cat <<EOF
# Header 2

Test body
EOF
  )

  WriteMarkdownCollapsedSection "${RESULTS_FILE}" "${EXPECTED_SUMMARY}" "${EXPECTED_BODY}"
  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF

<details>

<summary>${EXPECTED_SUMMARY}</summary>

${EXPECTED_BODY}

</details>
EOF
  )
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"

  notice "${FUNCTION_NAME} PASS"
}

WriteMarkdownCodeBlockTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitWorkspace
  local RESULTS_FILE="${TEMP_WORKSPACE}/${FUNCTION_NAME}-output-${FUNCTION_NAME}.md"

  local EXPECTED_BODY
  EXPECTED_BODY=$(
    cat <<EOF
Test body
EOF
  )

  local OBSERVED_CONTENT
  OBSERVED_CONTENT=$(WriteMarkdownCodeBlock "${EXPECTED_BODY}" "json")

  local EXPECTED_CONTENT
  EXPECTED_CONTENT=$(
    cat <<EOF
\`\`\`json
${EXPECTED_BODY}
\`\`\`
EOF
  )

  # CheckIfContentsDiff expects a file, but here we are checking string output.
  # So we will write observed content to a file.
  echo "${OBSERVED_CONTENT}" >"${RESULTS_FILE}"
  CheckIfContentsDiff "${RESULTS_FILE}" "${EXPECTED_CONTENT}"

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

  notice "${FUNCTION_NAME} PASS"
}

WriteSummaryMarkdownTableHeaderTest
WriteMarkdownCodeBlockTest
WriteSummaryMarkdownTableLineSuccessTest
WriteSummaryMarkdownTableLineFailureTest
WriteSummaryMarkdownTableFooterSuccessTest
WriteSummaryMarkdownTableFooterFailureTest
WriteSummaryMarkdownTableFooterMoreInfoGitHubWorkflowTest
WriteSummaryMarkdownTableFooterMoreInfoSummaryAndLogTest
WriteSummaryMarkdownTableFooterMoreInfoLogTest
WriteSummaryFooterSuperLinterInfoTest
WriteMarkdownCollapsedSectionTest
RemoveAnsiColorCodesFromFileTest
