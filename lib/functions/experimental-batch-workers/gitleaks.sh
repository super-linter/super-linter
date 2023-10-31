#!/usr/bin/env bash

# gitleaks reports failing linter rules to stdout
# stderr contains uncaught linter errors e.g. invalid parameter, which shall indicate a bug in this script
# using default LintCodebaseBaseStderrParser

# Sample gitleaks output:
#
# Finding:     API_KEY=XXXXXXXXX
# Secret:      XXXXXXXXX
# RuleID:      generic-api-key
# Entropy:     1.000000
# File:        /tmp/lint/my-api-key.config
# Line:        1
# Fingerprint: /tmp/lint/my-api-key.config:generic-api-key:1
#
function LintCodebaseGitleaksStdoutParser() {
  local STDOUT_PIPENAME="${1}" && shift
  local LINTER_NAME="${1}" && shift

  # shellcheck disable=SC2155
  local ERRORS_FOUND=$( (grep "^File:[[:space:]]\+" | sort -u | wc -l) <"${STDOUT_PIPENAME}")

  echo "${ERRORS_FOUND}" >"${STDOUT_PIPENAME}.return"
  return 0
}

function ParallelLintCodebaseGitleaks() {
  local FILE_TYPE="${1}" && shift
  local LINTER_NAME="${1}" && shift
  local LINTER_COMMAND="${1}" && shift
  local TEST_CASE_RUN="${1}" && shift
  local FILE_ARRAY=("$@")
  local NUM_PROC="$(($(nproc) * 1))"
  local FILES_PER_PROC="1" # no file batching support for gitleaks
  local STDOUT_PARSER="LintCodebaseGitleaksStdoutParser"
  local STDERR_PARSER="LintCodebaseBaseStderrParser"

  info "Running EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}"

  local MODIFIED_LINTER_COMMAND="${LINTER_COMMAND}"
  MODIFIED_LINTER_COMMAND=${MODIFIED_LINTER_COMMAND//--source/}
  MODIFIED_LINTER_COMMAND=${MODIFIED_LINTER_COMMAND//-s/}

  warn "Gitleaks output \"WRN leaks found: <number>\" is suppressed in parallel mode"
  MODIFIED_LINTER_COMMAND=${MODIFIED_LINTER_COMMAND//--verbose/}
  MODIFIED_LINTER_COMMAND=${MODIFIED_LINTER_COMMAND//-v/}
  # shellcheck disable=SC2001
  MODIFIED_LINTER_COMMAND=$(sed "s/\-\(-log-level\|l\) \(info\|warn\)//g" <<<"${MODIFIED_LINTER_COMMAND}")
  MODIFIED_LINTER_COMMAND="${MODIFIED_LINTER_COMMAND} -v -l error -s"
  MODIFIED_LINTER_COMMAND=$(tr -s ' ' <<<"${MODIFIED_LINTER_COMMAND}" | xargs)
  debug "Linter command updated from: ${LINTER_COMMAND}"
  debug "to: ${MODIFIED_LINTER_COMMAND}"

  ParallelLintCodebaseImpl "${FILE_TYPE}" "${LINTER_NAME}" "${MODIFIED_LINTER_COMMAND}" "${TEST_CASE_RUN}" "${NUM_PROC}" "${FILES_PER_PROC}" "${STDOUT_PARSER}" "${STDERR_PARSER}" "${FILE_ARRAY[@]}"

  info "Exiting EXPERIMENTAL parallel ${FILE_TYPE} LintCodebase on ${#FILE_ARRAY[@]} files. ERROR_FOUND: ${ERRORS_FOUND}. LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}"

  return 0
}
