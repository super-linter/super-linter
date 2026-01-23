#!/usr/bin/env bash

function LintCodebase() {
  set -o nounset
  set -o pipefail

  local FILE_TYPE
  FILE_TYPE="${1}" && shift
  local TEST_CASE_RUN
  TEST_CASE_RUN="${1}" && shift

  declare -n VALIDATE_LANGUAGE
  VALIDATE_LANGUAGE="VALIDATE_${FILE_TYPE}"

  ValidateBooleanVariable "TEST_CASE_RUN" "${TEST_CASE_RUN}"
  ValidateBooleanVariable "VALIDATE_${FILE_TYPE}" "${VALIDATE_LANGUAGE}"

  if [[ "${VALIDATE_LANGUAGE}" == "false" ]]; then
    if [[ "${TEST_CASE_RUN}" == "false" ]]; then
      debug "Skip validation of ${FILE_TYPE} because VALIDATE_LANGUAGE is ${VALIDATE_LANGUAGE}"
      unset -n VALIDATE_LANGUAGE
      return 0
    else
      if [[ "${FIX_MODE_TEST_CASE_RUN}" == "true" ]]; then
        debug "Don't fail the test even if VALIDATE_${FILE_TYPE} is set to ${VALIDATE_LANGUAGE} because ${FILE_TYPE} might not support fix mode"
        return 0
      else
        fatal "Don't disable any validation when running in test mode. VALIDATE_${FILE_TYPE} is set to: ${VALIDATE_LANGUAGE}. Set it to: true"
      fi
    fi
  fi

  debug "Running LintCodebase. FILE_TYPE: ${FILE_TYPE}. TEST_CASE_RUN: ${TEST_CASE_RUN}"

  debug "VALIDATE_LANGUAGE for ${FILE_TYPE}: ${VALIDATE_LANGUAGE}..."

  unset -n VALIDATE_LANGUAGE

  debug "Populating file array for ${FILE_TYPE}"
  local -n FILE_ARRAY="FILE_ARRAY_${FILE_TYPE}"
  local FILE_ARRAY_LANGUAGE_PATH="${FILE_ARRAYS_DIRECTORY_PATH}/file-array-${FILE_TYPE}"
  FILE_ARRAY=()
  if [[ -e "${FILE_ARRAY_LANGUAGE_PATH}" ]]; then
    while read -r FILE; do
      if [[ "${TEST_CASE_RUN}" == "true" ]]; then
        debug "Ensure that the list files to check for ${FILE_TYPE} doesn't include test cases for other languages"
        # Folder for specific tests. By convention, the last part of the path is the lowercased FILE_TYPE
        local TEST_CASE_DIRECTORY
        TEST_CASE_DIRECTORY="${FILE_TYPE,,}"

        # We use configuration files to pass the list of files to lint to checkov
        # Their name includes "checkov", which is equal to FILE_TYPE for Checkov.
        # In this case, we don't add a trailing slash so we don't fail validation.
        if [[ "${FILE_TYPE}" != "CHECKOV" ]]; then
          TEST_CASE_DIRECTORY="${TEST_CASE_DIRECTORY}/"
          debug "Adding a trailing slash to the test case directory for ${FILE_TYPE}: ${TEST_CASE_DIRECTORY}"
        fi

        debug "TEST_CASE_DIRECTORY for ${FILE_TYPE}: ${TEST_CASE_DIRECTORY}"
        if [[ ${FILE} != *"${TEST_CASE_DIRECTORY}"* ]]; then
          debug "Excluding ${FILE} because it's not in the test case directory for ${FILE_TYPE}..."
          continue
        else
          debug "Including ${FILE} because it's a test case for ${FILE_TYPE}"
        fi
      fi
      FILE_ARRAY+=("${FILE}")
    done <"${FILE_ARRAY_LANGUAGE_PATH}"
  else
    debug "${FILE_ARRAY_LANGUAGE_PATH} doesn't exist. Skip loading the list of files and directories to lint for ${FILE_TYPE}"
  fi

  if [[ "${#FILE_ARRAY[@]}" -eq 0 ]]; then
    if [[ "${TEST_CASE_RUN}" == "false" ]]; then
      debug "There are no items to lint for ${FILE_TYPE}"
      unset -n FILE_ARRAY
      return 0
    else
      fatal "Cannot find any tests for ${FILE_TYPE}"
    fi
  else
    debug "There are ${#FILE_ARRAY[@]} items to lint for ${FILE_TYPE}: ${FILE_ARRAY[*]}"
  fi

  info "Linting ${FILE_TYPE} items..."

  local PARALLEL_RESULTS_FILE_PATH
  PARALLEL_RESULTS_FILE_PATH="${SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH}/super-linter-worker-results-${FILE_TYPE}.json"
  debug "PARALLEL_RESULTS_FILE_PATH for ${FILE_TYPE}: ${PARALLEL_RESULTS_FILE_PATH}"

  local -a PARALLEL_COMMAND
  PARALLEL_COMMAND=(parallel --will-cite --keep-order --max-procs "$(($(nproc) * 1))" --xargs --results "${PARALLEL_RESULTS_FILE_PATH}")

  if [ "${LOG_DEBUG}" == "true" ]; then
    debug "LOG_DEBUG is enabled. Enable verbose output for parallel"
    PARALLEL_COMMAND+=(-v)
  fi
  debug "PARALLEL_COMMAND for ${FILE_TYPE}: ${PARALLEL_COMMAND[*]}"

  # The following linters support linting one file at a time, and don't support linting a list of files,
  # so we cannot pass more than one file per invocation
  if [[ "${FILE_TYPE}" == "ANSIBLE" ]] ||
    [[ "${FILE_TYPE}" == "ARM" ]] ||
    [[ "${FILE_TYPE}" == "BASH_EXEC" ]] ||
    [[ "${FILE_TYPE}" == "CHECKOV" ]] ||
    [[ "${FILE_TYPE}" == "CLOJURE" ]] ||
    [[ "${FILE_TYPE}" == "CSHARP" ]] ||
    [[ "${FILE_TYPE}" == "DOTNET_SLN_FORMAT_ANALYZERS" ]] ||
    [[ "${FILE_TYPE}" == "DOTNET_SLN_FORMAT_STYLE" ]] ||
    [[ "${FILE_TYPE}" == "DOTNET_SLN_FORMAT_WHITESPACE" ]] ||
    [[ "${FILE_TYPE}" == "GIT_COMMITLINT" ]] ||
    [[ "${FILE_TYPE}" == "GITLEAKS" ]] ||
    [[ "${FILE_TYPE}" == "GO_MODULES" ]] ||
    [[ "${FILE_TYPE}" == "JSCPD" ]] ||
    [[ "${FILE_TYPE}" == "KOTLIN" ]] ||
    [[ "${FILE_TYPE}" == "POWERSHELL" ]] ||
    [[ "${FILE_TYPE}" == "R" ]] ||
    [[ "${FILE_TYPE}" == "RUST_CLIPPY" ]] ||
    [[ "${FILE_TYPE}" == "SNAKEMAKE_LINT" ]] ||
    [[ "${FILE_TYPE}" == "SQLFLUFF" ]] ||
    [[ "${FILE_TYPE}" == "STATES" ]] ||
    [[ "${FILE_TYPE}" == "TERRAFORM_TFLINT" ]] ||
    [[ "${FILE_TYPE}" == "TERRAGRUNT" ]]; then
    debug "${FILE_TYPE} doesn't support linting files in batches. Configure the linter to run over the files to lint one by one"
    PARALLEL_COMMAND+=(--max-lines 1)
  fi
  debug "PARALLEL_COMMAND for ${FILE_TYPE} after updating the number of files to lint per process: ${PARALLEL_COMMAND[*]}"

  local LINTER_WORKING_DIRECTORY
  LINTER_WORKING_DIRECTORY="${GITHUB_WORKSPACE}"

  # GNU parallel parameter expansion:
  # - {} input item
  # - {/} basename of the input lint
  # - {//} dirname of input line

  if [[ ${FILE_TYPE} == "CSHARP" ]] ||
    [[ (${FILE_TYPE} == "R" && -f "$(dirname "${FILE}")/.lintr") ]] ||
    [[ ${FILE_TYPE} == "KOTLIN" ]] ||
    [[ ${FILE_TYPE} == "RUST_CLIPPY" ]] ||
    [[ ${FILE_TYPE} == "TERRAFORM_TFLINT" ]]; then
    LINTER_WORKING_DIRECTORY="{//}"
  # Biome: it runs against the entire workspace, but we need to change the
  # the working directory when running test cases, so we can pick a
  # configuration that doesn't ignore the test/data directory
  elif [[ ${FILE_TYPE} == "ANSIBLE" ]] ||
    [[ ${FILE_TYPE} == "BIOME_FORMAT" ]] ||
    [[ ${FILE_TYPE} == "BIOME_LINT" ]] ||
    [[ ${FILE_TYPE} == "GO_MODULES" ]] ||
    [[ ${FILE_TYPE} == "TRIVY" ]]; then
    LINTER_WORKING_DIRECTORY="{}"
  fi

  debug "LINTER_WORKING_DIRECTORY for ${FILE_TYPE}: ${LINTER_WORKING_DIRECTORY}"
  PARALLEL_COMMAND+=(--workdir "${LINTER_WORKING_DIRECTORY}")
  debug "PARALLEL_COMMAND for ${FILE_TYPE} after updating the working directory: ${PARALLEL_COMMAND[*]}"

  # shellcheck source=/dev/null
  if ! source /action/lib/functions/linterCommands.sh; then
    fatal "Error while sourcing linter commands"
  fi

  local -n LINTER_COMMAND_ARRAY
  LINTER_COMMAND_ARRAY="LINTER_COMMANDS_ARRAY_${FILE_TYPE}"
  if [ ${#LINTER_COMMAND_ARRAY[@]} -eq 0 ]; then
    fatal "LINTER_COMMAND_ARRAY for ${FILE_TYPE} is empty."
  else
    debug "LINTER_COMMAND_ARRAY for ${FILE_TYPE} has ${#LINTER_COMMAND_ARRAY[@]} elements: ${LINTER_COMMAND_ARRAY[*]}"
  fi

  if [[ "${FILE_TYPE}" == "ARM" ]] ||
    [[ "${FILE_TYPE}" == "POWERSHELL" ]]; then
    # Explicitly add a GNU Parallel replacement string before wrapping the
    # command in the Powershell executable and before appending fix mode options
    LINTER_COMMAND_ARRAY+=("'{}'")
  fi

  # Dynamically add arguments and commands to each linter command as needed
  if ! InitFixModeOptionsAndCommands "${FILE_TYPE}"; then
    fatal "Error while initializing fix mode and check only options and commands before running linter for ${FILE_TYPE}"
  fi

  # From GNU Parallel manpage (https://www.gnu.org/software/parallel/parallel.html#options)
  # "If the command line contains no replacement strings then {} will be appended to the command line."
  # shellcheck disable=SC2016 # Don't expand $_ on purpose because we want Parallel to interpret it instead of the shell
  local INPUT_CONSUME_COMMAND='# {= $_="" =}'
  if [[ "${FILE_TYPE}" == "ANSIBLE" ]] ||
    [[ "${FILE_TYPE}" == "GO_MODULE" ]] ||
    [[ "${FILE_TYPE}" == "PRE_COMMIT" ]] ||
    [[ "${FILE_TYPE}" == "RUST_CLIPPY" ]]; then
    # These commands don't accept passing a path as input, so add a no-op (a comment)
    # so that GNU Parallel doesn't automatically add the default replacement
    # string
    LINTER_COMMAND_ARRAY+=("${INPUT_CONSUME_COMMAND}")
  elif [[ "${FILE_TYPE}" == "CHECKOV" ]]; then
    # For checkov, add the no-op command only if it loads the list of directories
    # to check from the configuration file
    if CheckovConfigurationFileContainsDirectoryOption "${CHECKOV_LINTER_RULES}"; then
      LINTER_COMMAND_ARRAY+=("${INPUT_CONSUME_COMMAND}")
    else
      LINTER_COMMAND_ARRAY+=("${CHECKOV_DIRECTORY_OPTIONS[@]}")
    fi
  fi

  if [[ "${FILE_TYPE}" == "ARM" ]] ||
    [[ "${FILE_TYPE}" == "POWERSHELL" ]]; then
    # Run as a Powershell command
    LINTER_COMMAND_ARRAY=(pwsh -NoProfile -NoLogo -Command "\"${LINTER_COMMAND_ARRAY[*]}; if (\\\${Error}.Count) { exit 1 }\"")
  fi

  debug "LINTER_COMMAND_ARRAY for ${FILE_TYPE} has ${#LINTER_COMMAND_ARRAY[@]} elements after initializing command arguments: ${LINTER_COMMAND_ARRAY[*]}"

  PARALLEL_COMMAND+=("${LINTER_COMMAND_ARRAY[@]}")
  debug "PARALLEL_COMMAND for ${FILE_TYPE} after LINTER_COMMAND_ARRAY concatenation: ${PARALLEL_COMMAND[*]}"

  unset -n LINTER_COMMAND_ARRAY

  local PARALLEL_COMMAND_OUTPUT
  local PARALLEL_COMMAND_RETURN_CODE
  PARALLEL_COMMAND_OUTPUT=$(printf "%s\n" "${FILE_ARRAY[@]}" | "${PARALLEL_COMMAND[@]}" 2>&1)
  # Don't check for errors on this return code because commands can fail if linter report errors
  PARALLEL_COMMAND_RETURN_CODE=$?
  debug "PARALLEL_COMMAND_OUTPUT for ${FILE_TYPE} (exit code: ${PARALLEL_COMMAND_RETURN_CODE}):\n${PARALLEL_COMMAND_OUTPUT}"
  debug "Parallel output file (${PARALLEL_RESULTS_FILE_PATH}) contents for ${FILE_TYPE}:\n$(cat "${PARALLEL_RESULTS_FILE_PATH}")"

  echo ${PARALLEL_COMMAND_RETURN_CODE} >"${SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH}/super-linter-parallel-command-exit-code-${FILE_TYPE}"

  local RESULTS_OBJECT
  RESULTS_OBJECT=
  if ! RESULTS_OBJECT=$(jq --raw-output -n '[inputs]' "${PARALLEL_RESULTS_FILE_PATH}"); then
    fatal "Error loading results for ${FILE_TYPE}: ${RESULTS_OBJECT}"
  fi
  debug "RESULTS_OBJECT for ${FILE_TYPE}:\n${RESULTS_OBJECT}"

  # To count how many files were checked for a given FILE_TYPE
  local INDEX
  INDEX=0
  if ! ((INDEX = $(jq '[.[] | .V | length] | add' <<<"${RESULTS_OBJECT}"))); then
    fatal "Error when setting INDEX for ${FILE_TYPE}: ${INDEX}"
  fi
  debug "Set INDEX for ${FILE_TYPE} to: ${INDEX}"

  local STDOUT_LINTER
  # Get raw output so we can strip quotes from the data we load. Also, strip the final newline to avoid adding it two times
  if ! STDOUT_LINTER="$(jq --raw-output '.[] | select(.Stdout[:-1] | length > 0) | .Stdout[:-1]' <<<"${RESULTS_OBJECT}")"; then
    fatal "Error when loading stdout for ${FILE_TYPE}:\n${STDOUT_LINTER}"
  fi

  local STDERR_LINTER
  if ! STDERR_LINTER="$(jq --raw-output '.[] | select(.Stderr[:-1] | length > 0) | .Stderr[:-1]' <<<"${RESULTS_OBJECT}")"; then
    fatal "Error when loading stderr for ${FILE_TYPE}:\n${STDERR_LINTER}"
  fi

  # Load output functions because we might need to process stdout and stderr
  # shellcheck source=/dev/null
  source /action/lib/functions/output.sh

  # At this point, we have all the info to process outputs

  if [ ${PARALLEL_COMMAND_RETURN_CODE} -ne 0 ]; then
    error "Found errors when linting ${FILE_TYPE}. Exit code: ${PARALLEL_COMMAND_RETURN_CODE}."
  else
    info "${FILE_TYPE} linted successfully"
  fi

  local -A LINTER_OUTPUTS
  LINTER_OUTPUTS["stdout"]="${STDOUT_LINTER:-""}"
  LINTER_OUTPUTS["stderr"]="${STDERR_LINTER:-""}"

  local LINTER_OUTPUT
  local LINTER_OUTPUT_CONTENTS
  for LINTER_OUTPUT in "${!LINTER_OUTPUTS[@]}"; do
    LINTER_OUTPUT_CONTENTS="${LINTER_OUTPUTS["${LINTER_OUTPUT}"]}"
    if [[ -n "${LINTER_OUTPUT_CONTENTS}" ]]; then
      info "Command ${LINTER_OUTPUT} for ${FILE_TYPE}:\n------\n${LINTER_OUTPUT_CONTENTS}\n------"

      local OUTPUT_LINTER_FILE_PATH
      OUTPUT_LINTER_FILE_PATH="${SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH}/super-linter-parallel-${LINTER_OUTPUT}-${FILE_TYPE}"
      debug "Saving ${LINTER_OUTPUT} for ${FILE_TYPE} to ${OUTPUT_LINTER_FILE_PATH} in case we need it later"
      printf '%s\n' "${LINTER_OUTPUT_CONTENTS}" >"${OUTPUT_LINTER_FILE_PATH}"
      if [[ "${REMOVE_ANSI_COLOR_CODES_FROM_OUTPUT}" == "true" ]] &&
        ! RemoveAnsiColorCodesFromFile "${OUTPUT_LINTER_FILE_PATH}"; then
        fatal "Error while removing ANSI color codes from ${OUTPUT_LINTER_FILE_PATH}"
      fi
    else
      debug "${LINTER_OUTPUT} for ${FILE_TYPE} is empty"
    fi
  done

  unset -n FILE_ARRAY
}

# We need this for parallel
export -f LintCodebase
