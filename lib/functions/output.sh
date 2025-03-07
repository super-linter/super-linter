#!/usr/bin/env bash

WriteSummaryHeader() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"

  {
    echo "# Super-linter summary"
    echo ""
    echo "| Language | Validation result |"
    echo "| -------- | ----------------- |"
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

FormatSuperLinterSummaryFile() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local SUPER_LINTER_SUMMARY_FORMAT_COMMAND=(prettier --write)

  # Avoid emitting output except of warnings and errors if debug logging is
  # disabled.
  if [[ "${LOG_DEBUG}" != "true" ]]; then
    SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=(--log-level warn)
  fi
  # Override the default prettier ignore paths (.gitignore, .prettierignore) to
  # avoid considering their defaults because prettier will skip formatting
  # the summary report file if the summary report file is ignored in those
  # ignore files, which is usually the case for generated files.
  # Ref: https://prettier.io/docs/en/cli#--ignore-path
  SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=(--ignore-path /dev/null)
  SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=("${SUPER_LINTER_SUMMARY_OUTPUT_PATH}")
  debug "Formatting the Super-linter summary file by running: ${SUPER_LINTER_SUMMARY_FORMAT_COMMAND[*]}"
  if ! "${SUPER_LINTER_SUMMARY_FORMAT_COMMAND[@]}"; then
    error "Error while formatting the Super-linter summary file."
    return 1
  fi
}

# 0x1B (= ^[) is the control code that starts all ANSI color codes escape sequences
# Ref: https://en.wikipedia.org/wiki/ANSI_escape_code#C0_control_codes
ANSI_COLOR_CODES_SEARCH_PATTERN='\x1b\[[0-9;]*m'
export ANSI_COLOR_CODES_SEARCH_PATTERN
RemoveAnsiColorCodesFromFile() {
  local FILE_PATH="${1}"
  debug "Removing ANSI color codes from ${FILE_PATH}"
  if ! sed -i "s/${ANSI_COLOR_CODES_SEARCH_PATTERN}//g" "${FILE_PATH}"; then
    error "Error while removing ANSI color codes from ${FILE_PATH}"
    return 1
  fi
}
