#!/usr/bin/env bash

DetectActions() {
  FILE="${1}"

  if [ "${VALIDATE_GITHUB_ACTIONS}" == "false" ]; then
    debug "Don't check if ${FILE} is a GitHub Actions file because VALIDATE_GITHUB_ACTIONS is: ${VALIDATE_GITHUB_ACTIONS}"
    return 1
  fi

  debug "Checking if ${FILE} is a GitHub Actions file..."

  # Check if in the users .github, or the super linter test suite
  if [[ "$(dirname "${FILE}")" == *".github/workflows"* ]] || [[ "$(dirname "${FILE}")" == *"${TEST_CASE_FOLDER}/github_actions"* ]]; then
    debug "${FILE} is GitHub Actions file."
    return 0
  else
    debug "${FILE} is NOT GitHub Actions file."
    return 1
  fi
}

DetectOpenAPIFile() {
  FILE="${1}"

  if [ "${VALIDATE_OPENAPI}" == "false" ]; then
    debug "Don't check if ${FILE} is an OpenAPI file because VALIDATE_OPENAPI is: ${VALIDATE_OPENAPI}"
    return 1
  fi

  debug "Checking if ${FILE} is an OpenAPI file..."

  if grep -E '"openapi":|"swagger":|^openapi:|^swagger:' "${FILE}" >/dev/null; then
    debug "${FILE} is an OpenAPI descriptor"
    return 0
  else
    debug "${FILE} is NOT an OpenAPI descriptor"
    return 1
  fi
}

DetectTektonFile() {
  FILE="${1}"

  if [ "${VALIDATE_TEKTON}" == "false" ]; then
    debug "Don't check if ${FILE} is a Tekton file because VALIDATE_TEKTON is: ${VALIDATE_TEKTON}"
    return 1
  fi

  debug "Checking if ${FILE} is a Tekton file..."

  if grep -q -E 'apiVersion: tekton' "${FILE}" >/dev/null; then
    return 0
  else
    return 1
  fi
}

DetectARMFile() {
  FILE="${1}"

  if [ "${VALIDATE_ARM}" == "false" ]; then
    debug "Don't check if ${FILE} is an ARM file because VALIDATE_ARM is: ${VALIDATE_ARM}"
    return 1
  fi

  debug "Checking if ${FILE} is an ARM file..."

  if grep -E 'schema.management.azure.com' "${FILE}" >/dev/null; then
    return 0
  else
    return 1
  fi
}

DetectCloudFormationFile() {
  FILE="${1}"

  if [ "${VALIDATE_CLOUDFORMATION}" == "false" ]; then
    debug "Don't check if ${FILE} is a CloudFormation file because VALIDATE_CLOUDFORMATION is: ${VALIDATE_CLOUDFORMATION}"
    return 1
  fi

  debug "Checking if ${FILE} is a Cloud Formation file..."

  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-formats.html
  # AWSTemplateFormatVersion is optional

  # Check if file has AWS Template info
  if grep -q 'AWSTemplateFormatVersion' "${FILE}" >/dev/null; then
    return 0
  fi

  # See if it contains AWS References
  if grep -q -E '(AWS|Alexa|Custom)::' "${FILE}" >/dev/null; then
    return 0
  fi

  return 1
}

DetectKubernetesFile() {
  FILE="${1}"

  if [ "${VALIDATE_KUBERNETES_KUBECONFORM}" == "false" ]; then
    debug "Don't check if ${FILE} is a Kubernetes file because VALIDATE_KUBERNETES_KUBECONFORM is: ${VALIDATE_KUBERNETES_KUBECONFORM}"
    return 1
  fi

  debug "Checking if ${FILE} is a Kubernetes descriptor..."
  if grep -q -v 'kustomize.config.k8s.io' "${FILE}" &&
    grep -q -v "tekton" "${FILE}" &&
    grep -q -E '(^apiVersion):' "${FILE}" &&
    grep -q -E '(^kind):' "${FILE}"; then
    debug "${FILE} is a Kubernetes descriptor"
    return 0
  fi

  debug "${FILE} is NOT a Kubernetes descriptor"
  return 1
}

DetectAWSStatesFIle() {
  FILE="${1}"

  if [ "${VALIDATE_STATES}" == "false" ]; then
    debug "Don't check if ${FILE} is an AWS states file because VALIDATE_STATES is: ${VALIDATE_STATES}"
    return 1
  fi

  debug "Checking if ${FILE} is a AWS states descriptor..."

  # https://states-language.net/spec.html#example
  if grep -q '"Resource": *"arn' "${FILE}" &&
    grep -q '"States"' "${FILE}"; then
    return 0
  fi

  return 1
}

CheckInArray() {
  NEEDLE="$1" # Language we need to match

  ######################################
  # Check if Language was in the array #
  ######################################
  for LANG in "${UNIQUE_LINTED_ARRAY[@]}"; do
    if [[ "${LANG}" == "${NEEDLE}" ]]; then
      return 0
    fi
  done

  return 1
}

function GetFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  FILE="$1"
  GET_FILE_TYPE_CMD=$(file "${FILE}" 2>&1)

  echo "${GET_FILE_TYPE_CMD}"
}

function CheckFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  FILE="$1"

  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  if [[ ${GET_FILE_TYPE_CMD} == *"Ruby script"* ]]; then
    if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
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

function GetFileExtension() {
  FILE="$1"
  # We want a lowercase value
  local -l FILE_TYPE
  # Extract the file extension
  FILE_TYPE=${FILE##*.}
  echo "$FILE_TYPE"
}

function IsValidShellScript() {
  FILE="$1"

  if [ "${VALIDATE_BASH}" == "false" ] && [ "${VALIDATE_BASH_EXEC}" == "false" ] && [ "${VALIDATE_SHELL_SHFMT}" == "false" ]; then
    debug "Don't check if ${FILE} is a shell script because VALIDATE_BASH, VALIDATE_BASH_EXEC, and VALIDATE_SHELL_SHFMT are set to: ${VALIDATE_BASH}, ${VALIDATE_BASH_EXEC}, ${VALIDATE_SHELL_SHFMT}"
    return 1
  fi

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

function IsGenerated() {
  FILE="$1"

  if [ "${IGNORE_GENERATED_FILES}" == "false" ]; then
    debug "Don't check if ${FILE} is generated because IGNORE_GENERATED_FILES is: ${IGNORE_GENERATED_FILES}"
    return 1
  fi

  if ! grep -q "@generated" "$FILE"; then
    trace "File:[${FILE}] is not generated, because it doesn't have @generated marker"
    return 1
  fi

  if grep -q "@not-generated" "$FILE"; then
    trace "File:[${FILE}] is not-generated because it has @not-generated marker"
    return 1
  else
    trace "File:[${FILE}] is generated because it has @generated marker"
    return 0
  fi
}

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
        R -e "remotes::install_local('.', dependencies=T)" 2>&1
      )

      ##############
      # Error code #
      ##############
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      debug "INSTALL_CMD:[${INSTALL_CMD}]"
      if [ "${ERROR_CODE}" -ne 0 ]; then
        warn "ERROR: Failed to install the build package at:[${BUILD_PKG}]"
      fi
    fi
  fi

  ####################################
  # Run installs for TFLINT language #
  ####################################
  if [ "${VALIDATE_TERRAFORM_TFLINT}" == "true" ] && [ "${#FILE_ARRAY_TERRAFORM_TFLINT[@]}" -ne 0 ]; then
    info "Detected TFLint Language files to lint."
    info "Trying to install the TFLint init inside:[${WORKSPACE_PATH}]"
    #########################
    # Run the build command #
    #########################
    BUILD_CMD=$(
      cd "${WORKSPACE_PATH}" || exit 0
      tflint --init -c "${TERRAFORM_TFLINT_LINTER_RULES}" 2>&1
    )

    ##############
    # Error code #
    ##############
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ "${ERROR_CODE}" -ne 0 ]; then
      fatal "ERROR! Failed to initialize tflint with the ${TERRAFORM_TFLINT_LINTER_RULES} config file: ${BUILD_CMD}"
    else
      info "Successfully initialized tflint with the ${TERRAFORM_TFLINT_LINTER_RULES} config file"
      debug "Tflint output: ${BUILD_CMD}"
    fi
  fi
}
