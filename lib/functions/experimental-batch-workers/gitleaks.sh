#!/usr/bin/env bash

# This function runs linter in parallel, gitleaks does not support batch
#
# To reproduce serial behavior, ERRORS_FOUND_${FILE_TYPE} should be calculated from linter output
#
# The calculation should not affect, break or interleave linter output in any way
function LintCodebaseGitleaks() {
  FILE_TYPE="${1}" && shift      # Pull the variable and remove from array path  (Example: JSON)
  LINTER_NAME="${1}" && shift    # Pull the variable and remove from array path  (Example: jsonlint)
  LINTER_COMMAND="${1}" && shift # Pull the variable and remove from array path  (Example: jsonlint -c ConfigFile /path/to/file)
  TEST_CASE_RUN="${1}" && shift  # Flag for if running in test cases
  FILE_ARRAY=("$@")              # Array of files to validate                    (Example: ${FILE_ARRAY_JSON})

  info "Running EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}, LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"
  warn "Gitleaks output \"WRN leaks found: <number>\" is suppressed in parallel mode"
  # * space separated $LINTER_COMMAND, expect to split before feeding into xargs correctly
  LINTER_COMMAND=${LINTER_COMMAND//-v/-v -l error}
  # shellcheck disable=SC2046 disable=SC2086
  GITLEAKS_ERRORS_FOUND=$(
    printf "%s\n" "${FILE_ARRAY[@]}" |
      parallel -L 1 -P "$(nproc)" --xargs ${LINTER_COMMAND} |
      tee /dev/stderr | grep "^File:[[:space:]]\+" | sort -u | wc -l
  ) 2>&1

  (("ERRORS_FOUND_${FILE_TYPE}=GITLEAKS_ERRORS_FOUND"))

  info "Exiting EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. ERROR_FOUND: ${GITLEAKS_ERRORS_FOUND} FILE_TYPE: ${FILE_TYPE}. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}"
}
