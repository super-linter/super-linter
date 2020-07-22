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
  VALIDATE_ANSIBLE="${VALIDATE_ANSIBLE,,}"
  VALIDATE_ARM="${VALIDATE_ARM,,}"
  VALIDATE_BASH="${VALIDATE_BASH,,}"
  VALIDATE_CLOJURE="${VALIDATE_CLOJURE,,}"
  VALIDATE_CLOUDFORMATION="${VALIDATE_CLOUDFORMATION,,}"
  VALIDATE_COFFEE="${VALIDATE_COFFEE,,}"
  VALIDATE_CSS="${VALIDATE_CSS,,}"
  VALIDATE_DART="${VALIDATE_DART,,}"
  VALIDATE_DOCKER="${VALIDATE_DOCKER,,}"
  VALIDATE_EDITORCONFIG="${VALIDATE_EDITORCONFIG,,}"
  VALIDATE_ENV="${VALIDATE_ENV,,}"
  VALIDATE_GO="${VALIDATE_GO,,}"
  VALIDATE_HTML="${VALIDATE_HTML,,}"
  VALIDATE_JAVASCRIPT_ES="${VALIDATE_JAVASCRIPT_ES,,}"
  VALIDATE_JAVASCRIPT_STANDARD="${VALIDATE_JAVASCRIPT_STANDARD,,}"
  VALIDATE_JSON="${VALIDATE_JSON,,}"
  VALIDATE_JSX="${VALIDATE_JSX,,}"
  VALIDATE_KOTLIN="${VALIDATE_KOTLIN,,}"
  VALIDATE_MARKDOWN="${VALIDATE_MARKDOWN,,}"
  VALIDATE_OPENAPI="${VALIDATE_OPENAPI,,}"
  VALIDATE_PERL="${VALIDATE_PERL,,}"
  VALIDATE_PHP="${VALIDATE_PHP,,}"
  VALIDATE_POWERSHELL="${VALIDATE_POWERSHELL,,}"
  VALIDATE_PROTOBUF="${VALIDATE_PROTOBUF,,}"
  VALIDATE_PYTHON="${VALIDATE_PYTHON,,}"
  VALIDATE_RAKU="${VALIDATE_RAKU,,}"
  VALIDATE_RUBY="${VALIDATE_RUBY,,}"
  VALIDATE_STATES="${VALIDATE_STATES,,}"
  VALIDATE_TERRAFORM="${VALIDATE_TERRAFORM,,}"
  VALIDATE_TSX="${VALIDATE_TSX,,}"
  VALIDATE_TYPESCRIPT_ES="${VALIDATE_TYPESCRIPT_ES,,}"
  VALIDATE_TYPESCRIPT_STANDARD="${VALIDATE_TYPESCRIPT_STANDARD,,}"
  VALIDATE_YAML="${VALIDATE_YAML,,}"
  VALIDATE_XML="${VALIDATE_XML,,}"

  ################################################
  # Determine if any linters were explicitly set #
  ################################################
  ANY_SET="false"
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    # Check to see if the variable was set
    if [ -n ${!VALIDATE_LANGUAGE} ]; then
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
      if [ -z ${!VALIDATE_LANGUAGE} ]; then
        # Flag was not set, default to false
        eval "${VALIDATE_LANGUAGE}='false'"
      fi
    else
      # No linter flags were set - default all to true
      eval "${VALIDATE_LANGUAGE}='true'"
    fi
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
