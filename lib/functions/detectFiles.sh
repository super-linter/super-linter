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

  local FILE
  FILE="$1"

  local GET_FILE_TYPE_CMD
  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  local FILE_TYPE_MESSAGE

  if [[ ${GET_FILE_TYPE_CMD} == *"Ruby script"* ]]; then
    FILE_TYPE_MESSAGE="Found Ruby script without extension (${FILE}). Rename the file with proper extension for Ruby files."
    echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUBY"
  elif [[ ${GET_FILE_TYPE_CMD} == *"Python script"* ]]; then
    FILE_TYPE_MESSAGE="Found Python script without extension (${FILE}). Rename the file with proper extension for Python files."
    echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON"
  elif [[ ${GET_FILE_TYPE_CMD} == *"Perl script"* ]]; then
    FILE_TYPE_MESSAGE="Found Perl script without extension (${FILE}). Rename the file with proper extension for Perl files."
    echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PERL"
  else
    FILE_TYPE_MESSAGE="Failed to get file type for: ${FILE}"
  fi

  if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
    warn "${FILE_TYPE_MESSAGE}"
  else
    debug "${FILE_TYPE_MESSAGE}"
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

  debug "File:[${FILE}], File extension:[${FILE_EXTENSION}], File type: [${GET_FILE_TYPE_CMD}]"

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

  debug "$FILE is NOT a supported shell script. Skipping"
  return 1
}

function IsGenerated() {
  FILE="$1"

  if [ "${IGNORE_GENERATED_FILES}" == "false" ]; then
    debug "Don't check if ${FILE} is generated because IGNORE_GENERATED_FILES is: ${IGNORE_GENERATED_FILES}"
    return 1
  fi

  if ! grep -q "@generated" "$FILE"; then
    debug "File:[${FILE}] is not generated, because it doesn't have @generated marker"
    return 1
  fi

  if grep -q "@not-generated" "$FILE"; then
    debug "File:[${FILE}] is not-generated because it has @not-generated marker"
    return 1
  else
    debug "File:[${FILE}] is generated because it has @generated marker"
    return 0
  fi
}

# We need these functions when building the file list with paralle
export -f CheckFileType
export -f DetectActions
export -f DetectARMFile
export -f DetectAWSStatesFIle
export -f DetectCloudFormationFile
export -f DetectKubernetesFile
export -f DetectOpenAPIFile
export -f DetectTektonFile
export -f GetFileExtension
export -f GetFileType
export -f IsValidShellScript
export -f IsGenerated

function RunAdditionalInstalls() {

  if [ -z "${FILE_ARRAYS_DIRECTORY_PATH}" ] || [ ! -d "${FILE_ARRAYS_DIRECTORY_PATH}" ]; then
    fatal "FILE_ARRAYS_DIRECTORY_PATH (set to ${FILE_ARRAYS_DIRECTORY_PATH}) is empty or doesn't exist"
  fi

  ##################################
  # Run installs for Psalm and PHP #
  ##################################
  if [ "${VALIDATE_PHP_PSALM}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PSALM" ]; then
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

  if [ "${VALIDATE_PYTHON_MYPY}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_MYPY" ]; then
    local MYPY_CACHE_DIRECTORY_PATH
    MYPY_CACHE_DIRECTORY_PATH="${GITHUB_WORKSPACE}/.mypy_cache"
    debug "Create MyPy cache directory: ${MYPY_CACHE_DIRECTORY_PATH}"
    mkdir -v "${MYPY_CACHE_DIRECTORY_PATH}"
  fi

  ###############################
  # Run installs for R language #
  ###############################
  if [ "${VALIDATE_R}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-R" ]; then
    info "Detected R Language files to lint."
    info "Trying to install the R package inside:[${GITHUB_WORKSPACE}]"
    #########################
    # Run the build command #
    #########################
    BUILD_CMD=$(R CMD build "${GITHUB_WORKSPACE}" 2>&1)

    ##############
    # Error code #
    ##############
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ "${ERROR_CODE}" -ne 0 ]; then
      # Error
      warn "ERROR! Failed to run:[R CMD build] at location:[${GITHUB_WORKSPACE}]"
      warn "BUILD_CMD:[${BUILD_CMD}]"
    else
      # Get the build package
      BUILD_PKG=$(
        cd "${GITHUB_WORKSPACE}" || exit 0
        echo *.tar.gz 2>&1
      )
      ##############################
      # Install the build packages #
      ##############################
      INSTALL_CMD=$(
        cd "${GITHUB_WORKSPACE}" || exit 0
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

    if [ ! -f "${R_RULES_FILE_PATH_IN_ROOT}" ]; then
      info "No .lintr configuration file found, using defaults."
      cp "$R_LINTER_RULES" "$GITHUB_WORKSPACE"
      # shellcheck disable=SC2034
      SUPER_LINTER_COPIED_R_LINTER_RULES_FILE="true"
    fi
  fi

  ####################################
  # Run installs for TFLINT language #
  ####################################
  if [ "${VALIDATE_TERRAFORM_TFLINT}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TERRAFORM_TFLINT" ]; then
    info "Detected TFLint Language files to lint."
    info "Trying to install the TFLint init inside:[${GITHUB_WORKSPACE}]"
    #########################
    # Run the build command #
    #########################
    BUILD_CMD=$(
      cd "${GITHUB_WORKSPACE}" || exit 0
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

    # Array to track directories where tflint was run
    local -A TFLINT_SEEN_DIRS
    TFLINT_SEEN_DIRS=()
    for FILE in "${FILE_ARRAY_TERRAFORM_TFLINT[@]}"; do
      local DIR_NAME
      DIR_NAME=$(dirname "${FILE}" 2>&1)
      debug "DIR_NAME for ${FILE}: ${DIR_NAME}"
      # Check the cache to see if we've already prepped this directory for tflint
      if [[ ! -v "TFLINT_SEEN_DIRS[${DIR_NAME}]" ]]; then
        debug "Configuring Terraform data directory for ${DIR_NAME}"

        # Define the path to an empty Terraform data directory
        # (def: https://developer.hashicorp.com/terraform/cli/config/environment-variables#tf_data_dir)
        # in case the user has a Terraform data directory already, and we don't
        # want to modify it.
        # TFlint considers this variable as well.
        # Ref: https://github.com/terraform-linters/tflint/blob/master/docs/user-guide/compatibility.md#environment-variables
        TF_DATA_DIR="/tmp/.terraform-${TERRAFORM_TFLINT}-${DIR_NAME}"

        # Fetch Terraform modules
        debug "Fetch Terraform modules for ${FILE} in ${DIR_NAME} in ${TF_DATA_DIR}"
        local FETCH_TERRAFORM_MODULES_CMD
        if ! FETCH_TERRAFORM_MODULES_CMD="$(terraform get)"; then
          fatal "Error when fetching Terraform modules while linting ${FILE}. Command output: ${FETCH_TERRAFORM_MODULES_CMD}"
        fi
        debug "Fetch Terraform modules command for ${FILE} output: ${FETCH_TERRAFORM_MODULES_CMD}"
        # Let the cache know we've seen this before
        # Set the value to an arbitrary non-empty string.
        TFLINT_SEEN_DIRS[${DIR_NAME}]="false"
      else
        debug "Skip fetching Terraform modules for ${FILE} because we already did that for ${DIR_NAME}"
      fi
    done
  fi

  # Check if there's local configuration for the Raku linter
  if [ -e "${GITHUB_WORKSPACE}/META6.json" ]; then
    cd "${GITHUB_WORKSPACE}" && zef install --deps-only --/test .
  fi
}
