#!/usr/bin/env bash

# Sample cfn-lint v0.x output:
#
# E3002 Invalid Property Resources/Whatever/Properties/Is/Wrong
# ./path/to/my-stack.yml:35:7
#
function LintCodebaseCfnLintStdoutParser() {
  local STDOUT_PIPENAME="${1}" && shift
  local LINTER_NAME="${1}" && shift

  local ERRORS_FOUND=0
  local IS_ERROR
  local CUR_FILENAME
  local NEXT_FILENAME
  local LINE
  while IFS= read -r LINE; do
    if grep "[EW][0-9]\+[[:space:]]" <<<"$LINE" >/dev/null; then
      IS_ERROR="true"
      continue
    fi
    if grep "$PWD" <<<"$LINE" >/dev/null; then
      NEXT_FILENAME=$(cut -d: -f1 <<<"$LINE")
      if [[ "$NEXT_FILENAME" != "$CUR_FILENAME" ]]; then
        CUR_FILENAME=$NEXT_FILENAME
        if [[ "$IS_ERROR" == "true" ]]; then
          IS_ERROR="false"
          ERRORS_FOUND=$((ERRORS_FOUND + 1))
        fi
      fi
      continue
    fi
  done <"${STDOUT_PIPENAME}"

  echo "${ERRORS_FOUND}" >"${STDOUT_PIPENAME}.return"
  return 0
}

function ParallelLintCodebaseCfnLint() {
  local FILE_TYPE="${1}" && shift
  local LINTER_NAME="${1}" && shift
  local LINTER_COMMAND="${1}" && shift
  local TEST_CASE_RUN="${1}" && shift
  local FILE_ARRAY=("$@")
  local NUM_PROC="$(($(nproc) * 1))"
  local FILES_PER_PROC="16"
  local STDOUT_PARSER="LintCodebaseCfnLintStdoutParser"
  local STDERR_PARSER="LintCodebaseBaseStderrParser"

  info "Running EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"

  ParallelLintCodebaseImpl "${FILE_TYPE}" "${LINTER_NAME}" "${LINTER_COMMAND}" "${TEST_CASE_RUN}" "${NUM_PROC}" "${FILES_PER_PROC}" "${STDOUT_PARSER}" "${STDERR_PARSER}" "${FILE_ARRAY[@]}"

  info "Exiting EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. ERROR_FOUND: ${ERRORS_FOUND}. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}"

  return 0
}
