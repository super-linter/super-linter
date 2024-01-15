#!/usr/bin/env bash

function LintCodebase() {
  FILE_TYPE="${1}" && shift
  LINTER_NAME="${1}" && shift
  LINTER_COMMAND="${1}" && shift
  FILTER_REGEX_INCLUDE="${1}" && shift
  FILTER_REGEX_EXCLUDE="${1}" && shift
  TEST_CASE_RUN="${1}" && shift
  FILE_ARRAY=("$@")

  # Array to track directories where tflint was run
  declare -A TFLINT_SEEN_DIRS

  # To count how many files were checked for a given FILE_TYPE
  INDEX=0

  # To check how many "bad" and "good" test cases we ran
  BAD_TEST_CASES_COUNT=0
  GOOD_TEST_CASES_COUNT=0

  WORKSPACE_PATH="${GITHUB_WORKSPACE}"
  if [ "${TEST_CASE_RUN}" == "true" ]; then
    WORKSPACE_PATH="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}"
  fi
  debug "Workspace path: ${WORKSPACE_PATH}"

  info ""
  info "----------------------------------------------"
  info "----------------------------------------------"
  debug "Running LintCodebase. FILE_TYPE: ${FILE_TYPE}. Linter name: ${LINTER_NAME}, linter command: ${LINTER_COMMAND}, TEST_CASE_RUN: ${TEST_CASE_RUN}, FILTER_REGEX_INCLUDE: ${FILTER_REGEX_INCLUDE}, FILTER_REGEX_EXCLUDE: ${FILTER_REGEX_EXCLUDE}, files to lint: ${FILE_ARRAY[*]}"
  info "Linting ${FILE_TYPE} files..."
  info "----------------------------------------------"
  info "----------------------------------------------"

  for FILE in "${FILE_ARRAY[@]}"; do
    info "Checking file: ${FILE}"

    if [[ "${TEST_CASE_RUN}" == "true" ]]; then
      # Folder for specific tests. By convention, the last part of the path is the lowercased FILE_TYPE
      local TEST_CASE_DIRECTORY
      TEST_CASE_DIRECTORY="${TEST_CASE_FOLDER}/${FILE_TYPE,,}/"
      debug "TEST_CASE_DIRECTORY for ${FILE}: ${TEST_CASE_DIRECTORY}"

      if [[ ${FILE} != *"${TEST_CASE_DIRECTORY}"* ]]; then
        debug "Skipping ${FILE} because it's not in the test case directory for ${FILE_TYPE}..."
        continue
      fi
    fi

    local FILE_NAME
    FILE_NAME=$(basename "${FILE}" 2>&1)
    debug "FILE_NAME for ${FILE}: ${FILE_NAME}"

    local DIR_NAME
    DIR_NAME=$(dirname "${FILE}" 2>&1)
    debug "DIR_NAME for ${FILE}: ${DIR_NAME}"

    (("INDEX++"))

    LINTED_LANGUAGES_ARRAY+=("${FILE_TYPE}")
    local LINT_CMD
    LINT_CMD=''

    if [[ ${FILE_TYPE} == "POWERSHELL" ]] || [[ ${FILE_TYPE} == "ARM" ]]; then
      # Need to run PowerShell commands using pwsh -c, also exit with exit code from inner subshell
      LINT_CMD=$(
        cd "${WORKSPACE_PATH}" || exit
        pwsh -NoProfile -NoLogo -Command "${LINTER_COMMAND} \"${FILE}\"; if (\${Error}.Count) { exit 1 }"
        exit $? 2>&1
      )
    elif [[ ${FILE_TYPE} == "R" ]]; then
      local r_dir
      if [ ! -f "${DIR_NAME}/.lintr" ]; then
        r_dir="${WORKSPACE_PATH}"
      else
        r_dir="${DIR_NAME}"
      fi
      LINT_CMD=$(
        cd "$r_dir" || exit
        R --slave -e "lints <- lintr::lint('$FILE');print(lints);errors <- purrr::keep(lints, ~ .\$type == 'error');quit(save = 'no', status = if (length(errors) > 0) 1 else 0)" 2>&1
      )
    elif [[ ${FILE_TYPE} == "CSHARP" ]]; then
      # Because the C# linter writes to tty and not stdout
      LINT_CMD=$(
        cd "${DIR_NAME}" || exit
        ${LINTER_COMMAND} "${FILE_NAME}" | tee /dev/tty2 2>&1
        exit "${PIPESTATUS[0]}"
      )
    elif [[ ${FILE_TYPE} == "ANSIBLE" ]] ||
      [[ ${FILE_TYPE} == "GO_MODULES" ]]; then
      debug "Linting ${FILE_TYPE}. Changing the working directory to ${FILE} before running the linter."
      # Because it expects that the working directory is a Go module (GO_MODULES) or
      # because we want to enable ansible-lint autodetection mode.
      # Ref: https://ansible-lint.readthedocs.io/usage
      LINT_CMD=$(
        cd "${FILE}" || exit 1
        ${LINTER_COMMAND} 2>&1
      )
    elif [[ ${FILE_TYPE} == "KOTLIN" ]]; then
      # Because it needs to change directory to where the file to lint is
      LINT_CMD=$(
        cd "${DIR_NAME}" || exit
        ${LINTER_COMMAND} "${FILE_NAME}" 2>&1
      )
    elif [[ ${FILE_TYPE} == "TERRAFORM_TFLINT" ]]; then
      # Check the cache to see if we've already prepped this directory for tflint
      if [[ ! -v "TFLINT_SEEN_DIRS[${DIR_NAME}]" ]]; then
        debug "Configuring Terraform data directory for ${DIR_NAME}"

        # Define the path to an empty Terraform data directory
        # (def: https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_data_dir)
        # in case the user has a Terraform data directory already, and we don't
        # want to modify it.
        # TFlint considers this variable as well.
        # Ref: https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/compatibility.md#environment-variables
        local TF_DATA_DIR
        TF_DATA_DIR="/tmp/.terraform-${FILE_TYPE}-${DIR_NAME}"
        export TF_DATA_DIR
        # Let the cache know we've seen this before
        # Set the value to an arbitrary non-empty string.

        # Fetch Terraform modules
        debug "Fetch Terraform modules for ${DIR_NAME} in ${TF_DATA_DIR}"
        local FETCH_TERRAFORM_MODULES_CMD
        FETCH_TERRAFORM_MODULES_CMD="$(terraform get)"
        ERROR_CODE=$?
        debug "Fetch Terraform modules. Exit code: ${ERROR_CODE}. Command output: ${FETCH_TERRAFORM_MODULES_CMD}"
        if [ ${ERROR_CODE} -ne 0 ]; then
          fatal "Error when fetching Terraform modules while linting ${FILE}"
        fi
        TFLINT_SEEN_DIRS[${DIR_NAME}]="false"
      fi

      # Because it needs to change the directory to where the file to lint is
      LINT_CMD=$(
        cd "${DIR_NAME}" || exit
        ${LINTER_COMMAND} --filter="${FILE_NAME}" 2>&1
      )
    else
      LINT_CMD=$(
        cd "${WORKSPACE_PATH}" || exit
        ${LINTER_COMMAND} "${FILE}" 2>&1
      )
    fi

    ERROR_CODE=$?

    local FILE_STATUS
    # Assume that the file should pass linting checks
    FILE_STATUS="good"

    if [[ "${TEST_CASE_RUN}" == "true" ]] && [[ ${FILE} == *"bad"* ]]; then
      FILE_STATUS="bad"
      debug "We are running in test mode. Updating the expected FILE_STATUS for ${FILE} to: ${FILE_STATUS}"
    fi

    debug "Results for ${FILE}. Exit code: ${ERROR_CODE}. Command output:\n------\n${LINT_CMD}\n------"

    ########################################
    # File status = good, this should pass #
    ########################################
    if [[ ${FILE_STATUS} == "good" ]]; then
      (("GOOD_TEST_CASES_COUNT++"))

      if [ ${ERROR_CODE} -ne 0 ]; then
        error "Found errors when linting ${FILE_NAME}. Exit code: ${ERROR_CODE}. Command output:\n------\n${LINT_CMD}\n------"
        (("ERRORS_FOUND_${FILE_TYPE}++"))
      else
        notice "${FILE} was linted successfully"
        if [ -n "${LINT_CMD}" ]; then
          info "Command output for ${FILE_NAME}:\n------\n${LINT_CMD}\n------"
        fi
      fi
    #######################################
    # File status = bad, this should fail #
    #######################################
    else
      if [[ "${TEST_CASE_RUN}" == "false" ]]; then
        fatal "All files are supposed to pass linting checks when not running in test mode."
      fi

      (("BAD_TEST_CASES_COUNT++"))

      if [ ${ERROR_CODE} -eq 0 ]; then
        error "${FILE} should have failed test case."
        (("ERRORS_FOUND_${FILE_TYPE}++"))
      else
        notice "${FILE} failed the test case as expected"
      fi
    fi
  done

  if [ "${TEST_CASE_RUN}" = "true" ]; then

    debug "${LINTER_NAME} test suite has ${INDEX} test(s), of which ${BAD_TEST_CASES_COUNT} 'bad' (expected to fail), ${GOOD_TEST_CASES_COUNT} 'good' (expected to pass)."

    # Check if we ran at least one test
    if [ "${INDEX}" -eq 0 ]; then
      fatal "Failed to find any tests ran for: ${LINTER_NAME}. Check that tests exist for linter: ${LINTER_NAME}"
    fi

    # Check if we ran at least one 'bad' test
    if [ "${BAD_TEST_CASES_COUNT}" -eq 0 ]; then
      fatal "Failed to find any tests that are expected to fail for: ${LINTER_NAME}. Check that tests that are expected to fail exist for linter: ${LINTER_NAME}"
    fi

    # Check if we ran at least one 'good' test
    if [ "${GOOD_TEST_CASES_COUNT}" -eq 0 ]; then
      fatal "Failed to find any tests that are expected to pass for: ${LINTER_NAME}. Check that tests that are expected to pass exist for linter: ${LINTER_NAME}"
    fi
  fi
}
