#!/usr/bin/env bash

# This function runs linter in batch
#
# To reproduce serial behavior, ERRORS_FOUND_${FILE_TYPE} should be calculated from linter output
#
# The calculation should not affect, break or interleave linter output in any way
function LintCodebaseCfnLint() {
  FILE_TYPE="${1}" && shift            # Pull the variable and remove from array path  (Example: JSON)
  LINTER_NAME="${1}" && shift          # Pull the variable and remove from array path  (Example: jsonlint)
  LINTER_COMMAND="${1}" && shift       # Pull the variable and remove from array path  (Example: jsonlint -c ConfigFile /path/to/file)
  TEST_CASE_RUN="${1}" && shift        # Flag for if running in test cases
  FILE_ARRAY=("$@")                    # Array of files to validate                    (Example: ${FILE_ARRAY_JSON})

  info "Running EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}, LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"
  # * space separated $LINTER_COMMAND, expect to split before feeding into xargs correctly
  # shellcheck disable=SC2046 disable=SC2086
  # * workaround shfmt error for =ESLINT_ERRORS_FOUND
  for i in $(seq "$CFNLINT_ERRORS_FOUND");
  do
    (("ERRORS_FOUND_${FILE_TYPE}"++));
  done
  
  info "Exiting EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}. Linter name: ${LINTER_NAME}, linter command: ${LINTER_COMMAND}"
}
