#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter Validation Functions @admiralawkbar ###################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function GetValidationInfo ################################################
function GetValidationInfo() {
  ############################################
  # Print headers for user provided env vars #
  ############################################
  echo ""
  echo "--------------------------------------------"
  echo "Gathering user validation information..."

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
      echo "- Validating ALL files in code base..."
    else
      # Its false
      echo "- Only validating [new], or [edited] files in code base..."
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
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Check to see if the variable was set
    if [ -n "${!VALIDATE_LANGUAGE}" ]; then
      # It was set, need to set flag
      ANY_SET="true"
    fi
  done


  ###################################################
  # Validate if we should check individual lanuages #
  ###################################################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Check if ANY_SET was set
    if [[ ${ANY_SET} == "true" ]]; then
      # Check to see if the variable was set
      if [ -z "${!VALIDATE_LANGUAGE}" ]; then
        # Flag was not set, default to false
        eval "${VALIDATE_LANGUAGE}='false'"
      fi
    else
      # No linter flags were set - default all to true
      eval "${VALIDATE_LANGUAGE}='true'"
      # Default Terrascan to false
      export VALIDATE_TERRAFORM_TERRASCAN="false"
    fi
  done

  ######################################
  # Validate if we should check GROOVY #
  ######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_GROOVY ]]; then
      # GROOVY flag was not set - default to false
      VALIDATE_GROOVY="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_GROOVY="true"
  fi

  #######################################
  # Print which linters we are enabling #
  #######################################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    if [[ ${!VALIDATE_LANGUAGE} == "true" ]]; then
      # We need to validate
      PRINT_ARRAY+=("- Validating [$LANGUAGE] files in code base...")
    else
      # We are skipping the language
      PRINT_ARRAY+=("- Excluding [$LANGUAGE] files in code base...")
    fi
  done

  ##############################
  # Validate Ansible Directory #
  ##############################
  if [ -z "${ANSIBLE_DIRECTORY}" ]; then
    # No Value, need to default
    ANSIBLE_DIRECTORY="${DEFAULT_ANSIBLE_DIRECTORY}"
  else
    # Check if first char is '/'
    if [[ ${ANSIBLE_DIRECTORY:0:1} == "/" ]]; then
      # Remove first char
      ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY:1}"
    fi
    # Need to give it full path
    TEMP_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/${ANSIBLE_DIRECTORY}"
    # Set the value
    ANSIBLE_DIRECTORY="${TEMP_ANSIBLE_DIRECTORY}"
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

  ###################
  # Debug on runner #
  ###################
  if [[ ${ACTIONS_RUNNER_DEBUG} == "true" ]]; then
    ###########################
    # Print the validate info #
    ###########################
    for LINE in "${PRINT_ARRAY[@]}"; do
      echo "${LINE}"
    done

    echo "--- DEBUG INFO ---"
    echo "---------------------------------------------"
    RUNNER=$(whoami)
    echo "Runner:[${RUNNER}]"
    echo "ENV:"
    printenv
    echo "---------------------------------------------"
  fi
}
