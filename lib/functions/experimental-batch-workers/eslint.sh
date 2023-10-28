#!/usr/bin/env bash

# Sample eslint output:
#
# /path/to/failed.js
#  11:5  error  'a' is never reassigned. Use 'const' instead  prefer-const
#  11:5  error  'a' is assigned a value but never used        no-unused-vars
#
function LintCodebaseEslintStdoutParser() {
  local STDOUT_PIPENAME="${1}" && shift
  local LINTER_NAME="${1}" && shift

  local ERRORS_FOUND=0
  local CUR_FILE_COUNTED
  local LINE
  while IFS= read -r LINE; do
    if grep "$PWD" <<<"$LINE" >/dev/null; then
      CUR_FILE_COUNTED="false"
      continue
    fi
    if grep "[[:space:]]\+[0-9]\+:[0-9]\+[[:space:]]\+error[[:space:]]\+" <<<"$LINE" >/dev/null; then
      if [[ "$CUR_FILE_COUNTED" == "false" ]]; then
        CUR_FILE_COUNTED="true"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
      fi
    fi
  done <"${STDOUT_PIPENAME}"

  echo "${ERRORS_FOUND}" >"${STDOUT_PIPENAME}.return"
  return 0
}

function ParallelLintCodebaseEslint() {
  local FILE_TYPE="${1}" && shift
  local LINTER_NAME="${1}" && shift
  local LINTER_COMMAND="${1}" && shift
  local TEST_CASE_RUN="${1}" && shift
  local FILE_ARRAY=("$@")
  local NUM_PROC="$(($(nproc) * 1))"
  local FILES_PER_PROC="64"
  local STDOUT_PARSER="LintCodebaseEslintStdoutParser"
  local STDERR_PARSER="LintCodebaseBaseStderrParser"

  info "Running EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"

  ParallelLintCodebaseImpl "${FILE_TYPE}" "${LINTER_NAME}" "${LINTER_COMMAND}" "${TEST_CASE_RUN}" "${NUM_PROC}" "${FILES_PER_PROC}" "${STDOUT_PARSER}" "${STDERR_PARSER}" "${FILE_ARRAY[@]}"

  info "Exiting EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. ERROR_FOUND: ${ERRORS_FOUND}. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}"

  return 0
}
