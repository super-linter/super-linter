#!/usr/bin/env bash

# This function runs linter in batch
#
# To reproduce serial behavior, ERRORS_FOUND_${FILE_TYPE} should be calculated from linter output
#
# The calculation should not affect, break or interleave linter output in any way
function LintCodebaseEslint() {
  FILE_TYPE="${1}" && shift      # Pull the variable and remove from array path  (Example: JSON)
  LINTER_NAME="${1}" && shift    # Pull the variable and remove from array path  (Example: jsonlint)
  LINTER_COMMAND="${1}" && shift # Pull the variable and remove from array path  (Example: jsonlint -c ConfigFile /path/to/file)
  TEST_CASE_RUN="${1}" && shift  # Flag for if running in test cases
  FILE_ARRAY=("$@")              # Array of files to validate                    (Example: ${FILE_ARRAY_JSON})

  info "Running EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}, LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"
  # * space separated $LINTER_COMMAND, expect to split before feeding into xargs correctly
  # shellcheck disable=SC2046 disable=SC2086
  ESLINT_ERRORS_FOUND=$(
    printf "%s\n" "${FILE_ARRAY[@]}" |
      parallel -L 64 -P "$(nproc)" --xargs ${LINTER_COMMAND} |
      tee /dev/stderr |
      (
        ESLINT_ERRORS_FOUND=0
        while IFS= read -r LINE; do
          if grep "$PWD" <<<"$LINE" >/dev/null; then
            ESLINT_CUR_FILENAME=$LINE
            debug "Filename from eslint: $ESLINT_CUR_FILENAME"
            ESLINT_CUR_FILE_COUNTED="false"
            continue
          fi

          if grep "[[:space:]]\+[0-9]\+:[0-9]\+[[:space:]]\+error[[:space:]]\+" <<<"$LINE" >/dev/null; then
            debug "Eslint error matched"
            if [[ "$ESLINT_CUR_FILE_COUNTED" == "false" ]]; then
              ESLINT_CUR_FILE_COUNTED="true"
              (("ESLINT_ERRORS_FOUND++"))
              debug "Error counter incremented to ${ESLINT_ERRORS_FOUND}"
            fi
            continue
          fi
        done
        echo "${ESLINT_ERRORS_FOUND}"
      )
  ) 2>&1

  (("ERRORS_FOUND_${FILE_TYPE}=ESLINT_ERRORS_FOUND"))

  info "Exiting EXPERIMENTAL batched LintCodebase on ${#FILE_ARRAY[@]} files. ERROR_FOUND: ${ESLINT_ERRORS_FOUND} FILE_TYPE: ${FILE_TYPE}. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}"
}
