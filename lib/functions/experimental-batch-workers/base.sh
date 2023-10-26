#!/usr/bin/env bash

# stderr contains `parallel` command trace (starting with $LINTER_COMMAND) and linter's stderr
#
# implement to report error count and traces correctly
#
# IN: pipe from ${STDERR_PIPENAME}
#     - multiline text input
# OUT: pipe to ${STDERR_PIPENAME}.return number of file with linter error
#     - int: number of file with linter error
function LintCodebaseBaseStderrParser() {
  local STDERR_PIPENAME="${1}" && shift
  local LINTER_NAME="${1}" && shift
  local LINTER_COMMAND="${1}" && shift

  # usually linter reports failing linter rules to stdout
  # stderr contains uncaught linter errors e.g. invalid parameter, which shall indicate a bug in the parallel implementation
  # as the origin of error is unknown, we shall count each instance of linter error as 1 file to alert user of an error
  local UNCAUGHT_LINTER_ERRORS=0
  local LINE
  while IFS= read -r LINE; do
      if [[ "${LINE}" == "${LINTER_COMMAND}"* ]]; then
        trace "[parallel] ${LINE}"
        continue
      fi
      error "[${LINTER_NAME}] ${LINE//\\/\\\\}"
      UNCAUGHT_LINTER_ERRORS="$((UNCAUGHT_LINTER_ERRORS+1))"
  done < "${STDERR_PIPENAME}"

  echo "${UNCAUGHT_LINTER_ERRORS}" > "${STDERR_PIPENAME}.return"

  return 0
}


# stdout is piped from linter's stdout
# * this stream is already `tee`-ed to stdout by caller as in serial super-linter behavior
#
# implement to report error count correctly
#
# IN: pipe from ${STDERR_PIPENAME}
#     - multiline text input
# OUT: pipe to ${STDERR_PIPENAME}.return
#     - int: number of file with linter error
function LintCodebaseBaseStdoutParser() {
  local STDOUT_PIPENAME="${1}" && shift
  local LINTER_NAME="${1}" && shift

  # this function is an example only to illustrate the interface
  # should be implemented for each linter, do not use this

  # * you can use any way to parse the linter output as you like
  fatal "LintCodebaseBaseStdoutParser is not implemented"

  echo 0 > "${STDOUT_PIPENAME}.return"
  return 0
}


# This function runs linter in parallel and batch#
# To reproduce serial behavior, ERRORS_FOUND_${FILE_TYPE} should be calculated from linter output
# The calculation should not affect, break or interleave linter output in any way
# logging level below info is allowed to interleave linter output
function ParallelLintCodebaseImpl() {
  local FILE_TYPE="${1}" && shift      # File type (Example: JSON)
  local LINTER_NAME="${1}" && shift    # Linter name (Example: jsonlint)
  local LINTER_COMMAND="${1}" && shift # Full linter command including linter name (Example: jsonlint -c ConfigFile /path/to/file)
  # shellcheck disable=SC2034
  local TEST_CASE_RUN="${1}" && shift  # Flag for if running in test cases
  local NUM_PROC="${1}" && shift       # Number of processes to run in parallel
  local FILES_PER_PROC="${1}" && shift # Max. number of file to pass into one linter process, still subject to maximum of 65536 characters per command line, which parallel will handle for us
  local STDOUT_PARSER="${1}" && shift  # Function to parse stdout to count number of files with linter error
  local STDERR_PARSER="${1}" && shift  # Function to parse stderr to count number of files with linter error
  local FILE_ARRAY=("$@")              # Array of files to validate                    (Example: ${FILE_ARRAY_JSON})

  debug "Running ParallelLintCodebaseImpl on ${#FILE_ARRAY[@]} files. FILE_TYPE: ${FILE_TYPE}, LINTER_NAME: ${LINTER_NAME}, LINTER_COMMAND: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}, NUM_PROC: ${NUM_PROC}, FILES_PER_PROC: ${FILES_PER_PROC}, STDOUT_PARSER: ${STDOUT_PARSER}, STDERR_PARSER: ${STDERR_PARSER}"

  local PARALLEL_DEBUG_OPTS=""
  if [ "${LOG_TRACE}" == "true" ]; then
    PARALLEL_DEBUG_OPTS="--verbose"
  fi
  local PARALLEL_COMMAND="parallel --will-cite --keep-order --max-lines ${FILES_PER_PROC} --max-procs ${NUM_PROC} ${PARALLEL_DEBUG_OPTS} --xargs ${LINTER_COMMAND}"
  info "Parallel command: ${PARALLEL_COMMAND}"
  
  # named pipes for routing linter outputs and return values
  local STDOUT_PIPENAME="/tmp/parallel-${FILE_TYPE,,}.stdout"
  local STDERR_PIPENAME="/tmp/parallel-${FILE_TYPE,,}.stderr"
  trace "Stdout pipe: ${STDOUT_PIPENAME}"
  trace "Stderr pipe: ${STDERR_PIPENAME}"
  mkfifo "${STDOUT_PIPENAME}" "${STDOUT_PIPENAME}.return" "${STDERR_PIPENAME}" "${STDERR_PIPENAME}.return"

  # start all functions in bg
  "${STDOUT_PARSER}" "${STDOUT_PIPENAME}" "${LINTER_NAME}" &
  "${STDERR_PARSER}" "${STDERR_PIPENAME}" "${LINTER_NAME}" "${LINTER_COMMAND}" &
  # start linter in parallel
  printf "%s\n" "${FILE_ARRAY[@]}" | ${PARALLEL_COMMAND} 2> "${STDERR_PIPENAME}" | tee "${STDOUT_PIPENAME}" &

  local UNCAUGHT_LINTER_ERRORS
  local ERRORS_FOUND
  # wait for all parsers to finish, should read a number from each pipe
  IFS= read -r UNCAUGHT_LINTER_ERRORS < "${STDERR_PIPENAME}.return"
  trace "UNCAUGHT_LINTER_ERRORS: ${UNCAUGHT_LINTER_ERRORS}"
  IFS= read -r ERRORS_FOUND < "${STDOUT_PIPENAME}.return"
  trace "ERRORS_FOUND: ${ERRORS_FOUND}"
  # assert return values are integers >= 0 just in case some implementation error
  if ! [[ "${ERRORS_FOUND}" =~ ^[0-9]+$ ]]; then
    fatal "ERRORS_FOUND is not a number: ${ERRORS_FOUND}"
    exit 1
  fi
  if ! [[ "${UNCAUGHT_LINTER_ERRORS}" =~ ^[0-9]+$ ]]; then
    fatal "UNCAUGHT_LINTER_ERRORS is not a number: ${UNCAUGHT_LINTER_ERRORS}"
    exit 1
  fi
  ERRORS_FOUND=$((ERRORS_FOUND+UNCAUGHT_LINTER_ERRORS))
  printf -v "ERRORS_FOUND_${FILE_TYPE}" "%d" "${ERRORS_FOUND}"

  return 0
}
