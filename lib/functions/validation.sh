#!/usr/bin/env bash

function GetValidationInfo() {
  ############################################
  # Print headers for user provided env vars #
  ############################################
  info "--------------------------------------------"
  info "Gathering user validation information..."

  ###########################################
  # Skip validation if were running locally #
  ###########################################
  if [[ ${RUN_LOCAL} != "true" ]]; then
    ###############################
    # Convert string to lowercase #
    ###############################
    VALIDATE_ALL_CODEBASE="${VALIDATE_ALL_CODEBASE,,}"
    ######################################
    # Validate we should check all files #
    ######################################
    if [[ ${VALIDATE_ALL_CODEBASE} != "false" ]]; then
      # Set to true
      VALIDATE_ALL_CODEBASE="${DEFAULT_VALIDATE_ALL_CODEBASE}"
      info "- Validating ALL files in code base..."
    else
      info "- Only validating [new], or [edited] files in code base..."
    fi
  fi

  ######################
  # Create Print Array #
  ######################
  PRINT_ARRAY=()

  ################################
  # Convert strings to lowercase #
  ################################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Set the value of the var to lowercase
    eval "${VALIDATE_LANGUAGE}=${!VALIDATE_LANGUAGE,,}"
  done

  ################################################
  # Determine if any linters were explicitly set #
  ################################################
  ANY_SET="false"
  ANY_TRUE="false"
  ANY_FALSE="false"
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Check to see if the variable was set
    if [ -n "${!VALIDATE_LANGUAGE}" ]; then
      # It was set, need to set flag
      ANY_SET="true"
      if [ "${!VALIDATE_LANGUAGE}" == "true" ]; then
        ANY_TRUE="true"
      elif [ "${!VALIDATE_LANGUAGE}" == "false" ]; then
        ANY_FALSE="true"
      fi
    fi
  done

  if [ $ANY_TRUE == "true" ] && [ $ANY_FALSE == "true" ]; then
    fatal "Behavior not supported, please either only include (VALIDATE=true) or exclude (VALIDATE=false) linters, but not both"
  fi

  #########################################################
  # Validate if we should check/omit individual languages #
  #########################################################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Check if ANY_SET was set
    if [[ ${ANY_SET} == "true" ]]; then
      # Check to see if the variable was set
      if [ -z "${!VALIDATE_LANGUAGE}" ]; then
        # Flag was not set, default to:
        # if ANY_TRUE then set to false
        # if ANY_FALSE then set to true
        eval "${VALIDATE_LANGUAGE}='$ANY_FALSE'"
      fi
    else
      # No linter flags were set - default all to true
      eval "${VALIDATE_LANGUAGE}='true'"
    fi
    eval "export ${VALIDATE_LANGUAGE}"
  done

  #######################################
  # Print which linters we are enabling #
  #######################################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    if [[ ${!VALIDATE_LANGUAGE} == "true" ]]; then
      # We need to validate
      PRINT_ARRAY+=("- Validating [${LANGUAGE}] files in code base...")

      debug "Defining variables for ${LANGUAGE} linter..."

      ERRORS_VARIABLE_NAME="ERRORS_FOUND_${LANGUAGE}"
      debug "Setting ${ERRORS_VARIABLE_NAME} variable value to 0..."
      eval "${ERRORS_VARIABLE_NAME}=0"
      debug "Exporting ${ERRORS_VARIABLE_NAME} variable..."
      eval "export ${ERRORS_VARIABLE_NAME}"
    else
      # We are skipping the language
      PRINT_ARRAY+=("- Excluding [$LANGUAGE] files in code base...")
    fi
  done

  ##############################
  # Validate Ansible Directory #
  ##############################
  # No Value, need to default
  if [ -z "${ANSIBLE_DIRECTORY}" ]; then

    if [ "${TEST_CASE_RUN}" != "true" ]; then
      ANSIBLE_DIRECTORY="${DEFAULT_ANSIBLE_DIRECTORY}"
      debug "Setting Ansible directory to the default: ${DEFAULT_ANSIBLE_DIRECTORY}"
    else
      ANSIBLE_DIRECTORY="${DEFAULT_TEST_CASE_ANSIBLE_DIRECTORY}"
      debug "Setting Ansible directory to the default for test cases: ${DEFAULT_TEST_CASE_ANSIBLE_DIRECTORY}"
    fi
    debug "Setting Ansible directory to: ${ANSIBLE_DIRECTORY}"
  else
    # Check if first char is '/'
    if [[ ${ANSIBLE_DIRECTORY:0:1} == "/" ]]; then
      # Remove first char
      ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY:1}"
    fi

    if [ -z "${ANSIBLE_DIRECTORY}" ] || [[ ${ANSIBLE_DIRECTORY} == "." ]]; then
      # Catches the case where ANSIBLE_DIRECTORY="/" or ANSIBLE_DIRECTORY="."
      TEMP_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}"
    else
      # Need to give it full path
      TEMP_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/${ANSIBLE_DIRECTORY}"
    fi

    # Set the value
    ANSIBLE_DIRECTORY="${TEMP_ANSIBLE_DIRECTORY}"
    debug "Setting Ansible directory to: ${ANSIBLE_DIRECTORY}"
  fi

  ###############################
  # Get the disable errors flag #
  ###############################
  if [ -z "${DISABLE_ERRORS}" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    DISABLE_ERRORS="${DEFAULT_DISABLE_ERRORS}"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  DISABLE_ERRORS="${DISABLE_ERRORS,,}"

  ############################
  # Set to false if not true #
  ############################
  if [ "${DISABLE_ERRORS}" != "true" ]; then
    DISABLE_ERRORS="false"
  fi

  ############################
  # Get the run verbose flag #
  ############################
  if [ -z "${ACTIONS_RUNNER_DEBUG}" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    ACTIONS_RUNNER_DEBUG="${DEFAULT_ACTIONS_RUNNER_DEBUG}"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  ACTIONS_RUNNER_DEBUG="${ACTIONS_RUNNER_DEBUG,,}"

  ############################
  # Set to true if not false #
  ############################
  if [ "${ACTIONS_RUNNER_DEBUG}" != "false" ]; then
    ACTIONS_RUNNER_DEBUG="true"
  fi

  ###########################
  # Print the validate info #
  ###########################
  for LINE in "${PRINT_ARRAY[@]}"; do
    debug "${LINE}"
  done

  debug "--- DEBUG INFO ---"
  debug "---------------------------------------------"
  RUNNER=$(id -un 2>/dev/null)
  debug "Runner:[${RUNNER}]"
  PRINTENV=$(printenv | sort)
  debug "ENV:"
  debug "${PRINTENV}"
  debug "---------------------------------------------"
}

function CheckIfGitBranchExists() {
  local BRANCH_NAME="${1}"
  debug "Check if the ${BRANCH_NAME} branch exists in ${GITHUB_WORKSPACE}"
  if ! git -C "${GITHUB_WORKSPACE}" rev-parse --quiet --verify "${BRANCH_NAME}"; then
    info "The ${BRANCH_NAME} branch doesn't exist in ${GITHUB_WORKSPACE}"
    return 1
  else
    debug "The ${BRANCH_NAME} branch exists in ${GITHUB_WORKSPACE}"
    return 0
  fi
}

function ValidateLocalGitRepository() {
  debug "Check if ${GITHUB_WORKSPACE} is a Git repository"
  if ! git -C "${GITHUB_WORKSPACE}" rev-parse --git-dir; then
    fatal "${GITHUB_WORKSPACE} is not a Git repository."
  else
    debug "${GITHUB_WORKSPACE} is a Git repository"
  fi

  debug "Git branches: $(git -C "${GITHUB_WORKSPACE}" branch -a)"
}

function ValidateGitShaReference() {
  debug "Git HEAD: $(git -C "${GITHUB_WORKSPACE}" show HEAD --stat)"

  debug "Validate that the GITHUB_SHA reference (${GITHUB_SHA}) exists in this Git repository."
  if ! git -C "${GITHUB_WORKSPACE}" cat-file -e "${GITHUB_SHA}"; then
    fatal "The GITHUB_SHA reference (${GITHUB_SHA}) doesn't exist in this Git repository"
  else
    debug "The GITHUB_SHA reference (${GITHUB_SHA}) exists in this repository"
  fi
}

function ValidateDefaultGitBranch() {
  debug "Check if the default branch (${DEFAULT_BRANCH}) exists"
  if ! CheckIfGitBranchExists "${DEFAULT_BRANCH}"; then
    REMOTE_DEFAULT_BRANCH="origin/${DEFAULT_BRANCH}"
    debug "The default branch (${DEFAULT_BRANCH}) doesn't exist in this Git repository. Trying with ${REMOTE_DEFAULT_BRANCH}"
    if ! CheckIfGitBranchExists "${REMOTE_DEFAULT_BRANCH}"; then
      fatal "Neither ${DEFAULT_BRANCH}, nor ${REMOTE_DEFAULT_BRANCH} exist in ${GITHUB_WORKSPACE}"
    else
      info "${DEFAULT_BRANCH} doesn't exist, however ${REMOTE_DEFAULT_BRANCH} exists. Setting DEFAULT_BRANCH to: ${REMOTE_DEFAULT_BRANCH}"
      DEFAULT_BRANCH="${REMOTE_DEFAULT_BRANCH}"
      debug "Updated DEFAULT_BRANCH: ${DEFAULT_BRANCH}"
    fi
  else
    debug "The default branch (${DEFAULT_BRANCH}) exists in this repository"
  fi
}
