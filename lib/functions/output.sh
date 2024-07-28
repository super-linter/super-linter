#!/usr/bin/env bash

WriteSummaryHeader() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"

  {
    echo "# Super-linter summary"
    echo ""
    echo "| Language               | Validation result |"
    echo "| -----------------------|-------------------|"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryLineSuccess() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local LANGUAGE_NAME="${2}"
  echo "| ${LANGUAGE_NAME} | Pass ✅ |" >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryLineFailure() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local LANGUAGE_NAME="${2}"
  echo "| ${LANGUAGE_NAME} | Fail ❌ |" >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryFooterSuccess() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  {
    echo ""
    echo "All files and directories linted successfully"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryFooterFailure() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  {
    echo ""
    echo "Super-linter detected linting errors"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}
