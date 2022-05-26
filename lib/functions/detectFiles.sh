#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions @admiralawkbar ######################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
#### Function DetectActions ####################################################
DetectActions() {
  FILE="${1}"

  debug "Checking if ${FILE} is a GitHub Actions file..."

  # Check if in the users .github, or the super linter test suite
  if [[ "$(dirname "${FILE}")" == *".github/workflows"* ]] || [[ "$(dirname "${FILE}")" == *".automation/test/github_actions"* ]]; then
    debug "${FILE} is GitHub Actions file."
    return 0
  else
    debug "${FILE} is NOT GitHub Actions file."
    return 1
  fi
}
################################################################################
#### Function DetectOpenAPIFile ################################################
DetectOpenAPIFile() {
  ################
  # Pull in vars #
  ################
  FILE="${1}"
  debug "Checking if ${FILE} is an OpenAPI file..."

  ###############################
  # Check the file for keywords #
  ###############################
  grep -E '"openapi":|"swagger":|^openapi:|^swagger:' "${FILE}" >/dev/null

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -eq 0 ]; then
    debug "${FILE} is an OpenAPI descriptor"
    return 0
  else
    debug "${FILE} is NOT an OpenAPI descriptor"
    return 1
  fi
}
################################################################################
#### Function DetectTektonFile #################################################
DetectTektonFile() {
  ################
  # Pull in vars #
  ################
  FILE="${1}"
  debug "Checking if ${FILE} is a Tekton file..."

  ###############################
  # Check the file for keywords #
  ###############################
  grep -q -E 'apiVersion: tekton' "${FILE}" >/dev/null

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -eq 0 ]; then
    ########################
    # Found string in file #
    ########################
    return 0
  else
    ###################
    # No string match #
    ###################
    return 1
  fi
}
################################################################################
#### Function DetectARMFile ####################################################
DetectARMFile() {
  ################
  # Pull in vars #
  ################
  FILE="${1}" # Name of the file/path we are validating
  debug "Checking if ${FILE} is an ARM file..."

  ###############################
  # Check the file for keywords #
  ###############################
  grep -E 'schema.management.azure.com' "${FILE}" >/dev/null

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -eq 0 ]; then
    ########################
    # Found string in file #
    ########################
    return 0
  else
    ###################
    # No string match #
    ###################
    return 1
  fi
}
################################################################################
#### Function DetectCloudFormationFile #########################################
DetectCloudFormationFile() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate
  debug "Checking if ${FILE} is a Cloud Formation file..."

  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-formats.html
  # AWSTemplateFormatVersion is optional
  #######################################
  # Check if file has AWS Template info #
  #######################################
  if grep -q 'AWSTemplateFormatVersion' "${FILE}" >/dev/null; then
    # Found it
    return 0
  fi

  #####################################
  # See if it contains AWS References #
  #####################################
  if grep -q -E '(AWS|Alexa|Custom)::' "${FILE}" >/dev/null; then
    # Found it
    return 0
  fi

  #####################################################
  # No identifiers of a CLOUDFORMATION template found #
  #####################################################
  return 1
}
################################################################################
#### Function DetectKubernetesFile #########################################
DetectKubernetesFile() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate
  debug "Checking if ${FILE} is a Kubernetes descriptor..."
  if grep -q -v 'kustomize.config.k8s.io' "${FILE}" &&
    grep -q -v "tekton" "${FILE}" &&
    grep -q -E '(apiVersion):' "${FILE}" &&
    grep -q -E '(kind):' "${FILE}"; then
    debug "${FILE} is a Kubernetes descriptor"
    return 0
  fi

  debug "${FILE} is NOT a Kubernetes descriptor"
  return 1
}
################################################################################
#### Function DetectAWSStatesFIle ##############################################
DetectAWSStatesFIle() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate
  debug "Checking if ${FILE} is a AWS states descriptor..."

  # https://states-language.net/spec.html#example
  ###############################
  # check if file has resources #
  ###############################
  if grep -q '"Resource": *"arn' "${FILE}" &&
    grep -q '"States"' "${FILE}"; then
    # Found it
    return 0
  fi

  #################################################
  # No identifiers of a AWS States Language found #
  #################################################
  return 1
}
################################################################################
#### Function CheckInArray #####################################################
CheckInArray() {
  ###############
  # Pull in Var #
  ###############
  NEEDLE="$1" # Language we need to match

  ######################################
  # Check if Language was in the array #
  ######################################
  for LANG in "${UNIQUE_LINTED_ARRAY[@]}"; do
    if [[ "${LANG}" == "${NEEDLE}" ]]; then
      ############
      # Found it #
      ############
      return 0
    fi
  done

  ###################
  # Did not find it #
  ###################
  return 1
}
################################################################################
#### Function GetFileType ######################################################
function GetFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  ################
  # Pull in Vars #
  ################
  FILE="$1"

  ##################
  # Check the file #
  ##################
  GET_FILE_TYPE_CMD=$(file "${FILE}" 2>&1)

  echo "${GET_FILE_TYPE_CMD}"
}
################################################################################
#### Function CheckFileType ####################################################
function CheckFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  ################
  # Pull in Vars #
  ################
  FILE="$1"

  #################
  # Get file type #
  #################
  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  if [[ ${GET_FILE_TYPE_CMD} == *"Ruby script"* ]]; then
    if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
      #######################
      # It is a Ruby script #
      #######################
      warn "Found ruby script without extension:[.rb]"
      info "Please update file with proper extensions."
    fi
    ################################
    # Append the file to the array #
    ################################
    FILE_ARRAY_JSCPD+=("${FILE}")
    FILE_ARRAY_RUBY+=("${FILE}")
  elif [[ ${GET_FILE_TYPE_CMD} == *"Python script"* ]]; then
    if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
      #########################
      # It is a Python script #
      #########################
      warn "Found Python script without extension:[.py]"
      info "Please update file with proper extensions."
    fi
    ################################
    # Append the file to the array #
    ################################
    FILE_ARRAY_JSCPD+=("${FILE}")
    FILE_ARRAY_PYTHON+=("${FILE}")
  elif [[ ${GET_FILE_TYPE_CMD} == *"Perl script"* ]]; then
    if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
      #######################
      # It is a Perl script #
      #######################
      warn "Found Perl script without extension:[.pl]"
      info "Please update file with proper extensions."
    fi
    ################################
    # Append the file to the array #
    ################################
    FILE_ARRAY_JSCPD+=("${FILE}")
    FILE_ARRAY_PERL+=("${FILE}")
  else
    ############################
    # Extension was not found! #
    ############################
    debug "Failed to get filetype for:[${FILE}]!"
  fi
}
################################################################################
#### Function GetFileExtension ###############################################
function GetFileExtension() {
  ################
  # Pull in Vars #
  ################
  FILE="$1"

  ###########################
  # Get the files extension #
  ###########################
  # Extract just the file extension
  FILE_TYPE=${FILE##*.}
  # To lowercase
  FILE_TYPE=${FILE_TYPE,,}

  echo "$FILE_TYPE"
}
################################################################################
#### Function IsValidShellScript ###############################################
function IsValidShellScript() {
  ################
  # Pull in Vars #
  ################
  FILE="$1"

  #################
  # Get file type #
  #################
  FILE_EXTENSION="$(GetFileExtension "$FILE")"
  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  trace "File:[${FILE}], File extension:[${FILE_EXTENSION}], File type: [${GET_FILE_TYPE_CMD}]"

  if [[ "${FILE_EXTENSION}" == "zsh" ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"zsh script"* ]]; then
    warn "$FILE is a ZSH script. Skipping..."
    return 1
  fi

  if [ "${FILE_EXTENSION}" == "sh" ] ||
    [ "${FILE_EXTENSION}" == "bash" ] ||
    [ "${FILE_EXTENSION}" == "bats" ] ||
    [ "${FILE_EXTENSION}" == "dash" ] ||
    [ "${FILE_EXTENSION}" == "ksh" ]; then
    debug "$FILE is a valid shell script (has a valid extension: ${FILE_EXTENSION})"
    return 0
  fi

  if [[ "${GET_FILE_TYPE_CMD}" == *"POSIX shell script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"Bourne-Again shell script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"dash script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"ksh script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"/usr/bin/env sh script"* ]]; then
    debug "$FILE is a valid shell script (has a valid file type: ${GET_FILE_TYPE_CMD})"
    return 0
  fi

  trace "$FILE is NOT a supported shell script. Skipping"
  return 1
}
################################################################################
#### Function IsGenerated ######################################################
function IsGenerated() {
  # Pull in Vars #
  ################
  FILE="$1"

  ##############################
  # Check the file for keyword #
  ##############################
  grep -q "@generated" "$FILE"

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  if [ ${ERROR_CODE} -ne 0 ]; then
    trace "File:[${FILE}] is not generated, because it doesn't have @generated marker"
    return 1
  fi

  ##############################
  # Check the file for keyword #
  ##############################
  grep -q "@not-generated" "$FILE"

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  if [ ${ERROR_CODE} -eq 0 ]; then
    trace "File:[${FILE}] is not-generated because it has @not-generated marker"
    return 1
  else
    trace "File:[${FILE}] is generated because it has @generated marker"
    return 0
  fi
}
################################################################################
#### Function RunAdditionalInstalls ############################################
function RunAdditionalInstalls() {
  ##################################
  # Run installs for Psalm and PHP #
  ##################################
  if [ "${VALIDATE_PHP_PSALM}" == "true" ] && [ "${#FILE_ARRAY_PHP_PSALM[@]}" -ne 0 ]; then
    # found PHP files and were validating it, need to composer install
    info "Found PHP files to validate, and [VALIDATE_PHP_PSALM] set to true, need to run composer install"
    info "looking for composer.json in the users repository..."
    mapfile -t COMPOSER_FILE_ARRAY < <(find / -name composer.json 2>&1)
    debug "COMPOSER_FILE_ARRAY contents:[${COMPOSER_FILE_ARRAY[*]}]"
    ############################################
    # Check if we found the file in the system #
    ############################################
    if [ "${#COMPOSER_FILE_ARRAY[@]}" -ne 0 ]; then
      for LINE in "${COMPOSER_FILE_ARRAY[@]}"; do
        COMPOSER_PATH=$(dirname "${LINE}" 2>&1)
        info "Found [composer.json] at:[${LINE}]"
        COMPOSER_CMD=$(
          cd "${COMPOSER_PATH}" || exit 1
          composer install --no-progress -q 2>&1
        )

        ##############
        # Error code #
        ##############
        ERROR_CODE=$?

        ##############################
        # Check the shell for errors #
        ##############################
        if [ "${ERROR_CODE}" -ne 0 ]; then
          # Error
          error "ERROR! Failed to run composer install at location:[${COMPOSER_PATH}]"
          fatal "ERROR:[${COMPOSER_CMD}]"
        else
          # Success
          info "Successfully ran:[composer install] for PHP validation"
        fi
      done
    fi
  fi

  ###############################
  # Run installs for R language #
  ###############################
  if [ "${VALIDATE_R}" == "true" ] && [ "${#FILE_ARRAY_R[@]}" -ne 0 ]; then
    info "Detected R Language files to lint."
    info "Trying to install the R package inside:[${WORKSPACE_PATH}]"
    #########################
    # Run the build command #
    #########################
    BUILD_CMD=$(R CMD build "${WORKSPACE_PATH}" 2>&1)

    ##############
    # Error code #
    ##############
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ "${ERROR_CODE}" -ne 0 ]; then
      # Error
      warn "ERROR! Failed to run:[R CMD build] at location:[${WORKSPACE_PATH}]"
      warn "BUILD_CMD:[${BUILD_CMD}]"
    else
      # Get the build package
      BUILD_PKG=$(
        cd "${WORKSPACE_PATH}" || exit 0
        echo *.tar.gz 2>&1
      )
      ##############################
      # Install the build packages #
      ##############################
      INSTALL_CMD=$(
        cd "${WORKSPACE_PATH}" || exit 0
        R CMD INSTALL "${BUILD_PKG}" 2>&1
      )

      ##############
      # Error code #
      ##############
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ "${ERROR_CODE}" -ne 0 ]; then
        # Error
        warn "ERROR: Failed to install the build package at:[${BUILD_PKG}]"
        warn "INSTALL_CMD:[${INSTALL_CMD}]"
      fi
    fi
  fi

  ####################################
  # Run installs for TFLINT language #
  ####################################
  if [ "${VALIDATE_TERRAFORM_TFLINT}" == "true" ] && [ "${#FILE_ARRAY_TERRAFORM_TFLINT[@]}" -ne 0 ]; then
    info "Detected TFLint Language files to lint."
    info "Trying to install the TFLint init inside:[${WORKSPACE_PATH}]"
    # Set the log level
    TF_LOG_LEVEL="info"
    if [ "${ACTIONS_RUNNER_DEBUG}" = "true" ]; then
      TF_LOG_LEVEL="debug"
    fi
    #########################
    # Run the build command #
    #########################
    BUILD_CMD=$(
      cd "${WORKSPACE_PATH}" || exit 0
      tflint --init --loglevel="${TF_LOG_LEVEL}" -c "${TERRAFORM_TFLINT_LINTER_RULES}" 2>&1
    )

    ##############
    # Error code #
    ##############
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ "${ERROR_CODE}" -ne 0 ]; then
      # Error
      warn "ERROR! Failed to run:[tflint --init] at location:[${WORKSPACE_PATH}]"
      warn "BUILD_CMD:[${BUILD_CMD}]"
    else
      info "Successfully ran:[tflint --init] in workspace:[${WORKSPACE_PATH}]"
    fi
  fi
}
