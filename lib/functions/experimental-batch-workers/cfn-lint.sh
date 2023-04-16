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
  CFNLINT_ERRORS_FOUND=$(printf "%s\n" "${FILE_ARRAY[@]}" | xargs -P $(nproc) -n 16 ${LINTER_COMMAND} | tee "/dev/stderr" | (
    CFNLINT_ERRORS_FOUND=0
    while IFS= read -r LINE; do
      if grep "[EW][0-9]\+[[:space:]]" <<<"$LINE" >/dev/null; then
        debug "cfnlint error matched"
        CFNLINT_IS_ERROR="true"
        continue
      fi
      if grep "$PWD" <<<"$LINE" >/dev/null; then
        CFNLINT_NEXT_FILENAME=$(cut -d: -f1 <<<"$LINE")
        if [[ "$CFNLINT_NEXT_FILENAME" != "$CFNLINT_CUR_FILENAME" ]]; then
          debug "Filename from cfnlint: $CFNLINT_NEXT_FILENAME"
          CFNLINT_CUR_FILENAME=$CFNLINT_NEXT_FILENAME
          if [[ "$CFNLINT_IS_ERROR" == "true" ]]; then
            CFNLINT_IS_ERROR="false"
            (("CFNLINT_ERRORS_FOUND++"))
            debug "Error counter incremented to ${CFNLINT_ERRORS_FOUND}"
          fi
        fi
        continue
      fi
    done
    echo "${CFNLINT_ERRORS_FOUND}"
  ));
  (("ERRORS_FOUND_${FILE_TYPE}"=CFNLINT_ERRORS_FOUND));
  info "Exiting EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}. Linter name: ${LINTER_NAME}, linter command: ${LINTER_COMMAND}"
}
