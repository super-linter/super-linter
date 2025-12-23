#!/usr/bin/env bash

DetectGitHubActionsWorkflows() {
  local FILE="${1}"

  if [[ "${VALIDATE_GITHUB_ACTIONS}" == "false" ]] &&
    [[ "${VALIDATE_GITHUB_ACTIONS_ZIZMOR}" == "false" ]]; then
    debug "Don't check if ${FILE} is a GitHub Actions file because VALIDATE_GITHUB_ACTIONS is ${VALIDATE_GITHUB_ACTIONS}, and VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
    return 1
  fi

  local FILE_DIR_NAME
  local RET_CODE
  FILE_DIR_NAME="$(dirname "${FILE}")"
  RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    fatal "Error while getting the directory name for ${FILE:-"not set"} when detecting GitHub Actions workflow files. Output: ${FILE_DIR_NAME:-"empty"}"
  fi

  # Check if in the users .github, or the super linter test suite
  if [[ "${FILE_DIR_NAME}" == *".github/workflows"* ]] ||
    [[ "${FILE_DIR_NAME}" == *"${TEST_CASE_FOLDER}/github_actions"* ]]; then
    debug "${FILE} is GitHub Actions file."
    return 0
  else
    return 1
  fi
}

DetectDependabot() {
  local FILE="${1}"

  if [[ "${VALIDATE_GITHUB_ACTIONS_ZIZMOR}" == "false" ]]; then
    debug "Don't check if ${FILE} is a Dependabot file because VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
    return 1
  fi

  if [[ "${FILE}" =~ (^|/)\.github/dependabot\.ya?ml$ ]]; then
    debug "${FILE} is a Dependabot file."
    return 0
  else
    return 1
  fi
}

DetectGitHubActions() {
  local FILE="${1}"

  if [[ "${VALIDATE_GITHUB_ACTIONS_ZIZMOR}" == "false" ]]; then
    debug "Don't check if ${FILE} is a GitHub Action file because VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
    return 1
  fi

  if [[ "${FILE}" =~ (^|/)action\.ya?ml$ ]]; then
    debug "${FILE} is a GitHub Action file."
    return 0
  else
    return 1
  fi
}

DetectOpenAPIFile() {
  FILE="${1}"

  if [ "${VALIDATE_OPENAPI}" == "false" ]; then
    debug "Don't check if ${FILE} is an OpenAPI file because VALIDATE_OPENAPI is: ${VALIDATE_OPENAPI}"
    return 1
  fi

  if grep -E '"openapi":|"swagger":|^openapi:|^swagger:' "${FILE}" >/dev/null; then
    debug "${FILE} is an OpenAPI descriptor"
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

  if grep -E 'schema.management.azure.com' "${FILE}" >/dev/null; then
    debug "${FILE} is an ARM file"
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

  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-formats.html
  # AWSTemplateFormatVersion is optional

  # Check if file has AWS Template info or AWS References
  if grep -q 'AWSTemplateFormatVersion' "${FILE}" >/dev/null ||
    grep -q -E '(AWS|Alexa|Custom)::' "${FILE}" >/dev/null; then
    debug "Checking if ${FILE} is a Cloud Formation file..."
    return 0
  else
    return 1
  fi
}

DetectKubernetesFile() {
  FILE="${1}"

  if [ "${VALIDATE_KUBERNETES_KUBECONFORM}" == "false" ]; then
    debug "Don't check if ${FILE} is a Kubernetes file because VALIDATE_KUBERNETES_KUBECONFORM is: ${VALIDATE_KUBERNETES_KUBECONFORM}"
    return 1
  fi

  if grep -q -v 'kustomize.config.k8s.io' "${FILE}" &&
    grep -q -E '(^apiVersion):' "${FILE}" &&
    grep -q -E '(^kind):' "${FILE}"; then
    debug "${FILE} is a Kubernetes descriptor"
    return 0
  else
    return 1
  fi
}

DetectAWSStatesFIle() {
  FILE="${1}"

  if [ "${VALIDATE_STATES}" == "false" ]; then
    debug "Don't check if ${FILE} is an AWS states file because VALIDATE_STATES is: ${VALIDATE_STATES}"
    return 1
  fi

  # https://states-language.net/spec.html#example
  if grep -q '"Resource": *"arn' "${FILE}" &&
    grep -q '"States"' "${FILE}"; then
    debug "${FILE} is an AWS states descriptor"
    return 0
  else
    return 1
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

# HasNoShebang returns true if a file has no shebang line
function HasNoShebang() {
  local FILE SHEBANG FIRST_TWO

  FILE="${1}"
  SHEBANG='#!'
  IFS= read -rn2 FIRST_TWO <"${FILE}"

  if [[ ${FIRST_TWO} == "${SHEBANG}" ]]; then
    return 1
  fi

  debug "${FILE} doesn't contain a shebang"
  return 0
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

function IsNotSymbolicLink() {
  local FILE="$1"

  if [[ -L "${FILE}" ]]; then
    debug "${FILE} is a symbolic link"
    return 1
  else
    return 0
  fi
}

# We need these functions when building the file list with parallel
export -f DetectGitHubActionsWorkflows
export -f DetectDependabot
export -f DetectGitHubActions
export -f DetectARMFile
export -f DetectAWSStatesFIle
export -f DetectCloudFormationFile
export -f DetectKubernetesFile
export -f DetectOpenAPIFile
export -f GetFileExtension
export -f HasNoShebang
export -f IsGenerated
export -f IsNotSymbolicLink

function RunAdditionalInstalls() {

  if [ -z "${FILE_ARRAYS_DIRECTORY_PATH}" ] || [ ! -d "${FILE_ARRAYS_DIRECTORY_PATH}" ]; then
    fatal "FILE_ARRAYS_DIRECTORY_PATH (set to ${FILE_ARRAYS_DIRECTORY_PATH}) is empty or doesn't exist"
  fi

  # Run installs for Ruby

  # Ref: https://bundler.io/guides/bundler_docker_guide.html
  unset BUNDLE_PATH
  unset BUNDLE_BIN

  ##################################
  # Run installs for Psalm and PHP #
  ##################################
  if [[ ("${VALIDATE_PHP:-"${VALIDATE_PHP_BUILTIN}"}" == "true" && -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_BUILTIN") ]] ||
    [[ ("${VALIDATE_PHP_BUILTIN}" == "true" && -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_BUILTIN") ]] ||
    [[ ("${VALIDATE_PHP_PHPCS}" == "true" && -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PHPCS") ]] ||
    [[ ("${VALIDATE_PHP_PHPSTAN}" == "true" && -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PHPSTAN") ]] ||
    [[ ("${VALIDATE_PHP_PSALM}" == "true" && -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PSALM") ]]; then
    # found PHP files and were validating it, need to composer install
    info "Found PHP files to validate. Check if we need to run composer install"
    local -a COMPOSER_FILE_ARRAY
    mapfile -t COMPOSER_FILE_ARRAY < <(find "${GITHUB_WORKSPACE}" -name composer.json 2>&1)
    debug "COMPOSER_FILE_ARRAY contents: ${COMPOSER_FILE_ARRAY[*]}"
    if [ "${#COMPOSER_FILE_ARRAY[@]}" -ne 0 ]; then
      for LINE in "${COMPOSER_FILE_ARRAY[@]}"; do
        local COMPOSER_PATH
        COMPOSER_PATH="$(dirname "${LINE}" 2>&1)"
        info "Found Composer file: ${LINE}"
        local COMPOSER_CMD
        local COMPOSER_EXIT_STATUS
        COMPOSER_CMD=$(cd "${COMPOSER_PATH}" && composer install --no-progress 2>&1)
        COMPOSER_EXIT_STATUS=$?
        if [ "${COMPOSER_EXIT_STATUS}" -ne 0 ]; then
          fatal "Failed to run composer install for ${COMPOSER_PATH}. Output: ${COMPOSER_CMD}"
        else
          info "Successfully ran composer install."
        fi
        debug "Composer install output: ${COMPOSER_CMD}"
      done
    fi
  fi

  if [ "${VALIDATE_PYTHON_MYPY}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_MYPY" ]; then
    local MYPY_CACHE_DIRECTORY_PATH
    MYPY_CACHE_DIRECTORY_PATH="${GITHUB_WORKSPACE}/.mypy_cache"
    debug "Create MyPy cache directory: ${MYPY_CACHE_DIRECTORY_PATH}"
    mkdir -p "${MYPY_CACHE_DIRECTORY_PATH}"
  fi

  ###############################
  # Run installs for R language #
  ###############################
  if [ "${VALIDATE_R}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-R" ]; then
    debug "Detected R Language files to lint."

    if [[ -e "${GITHUB_WORKSPACE}/DESCRIPTION" ]]; then
      debug "Installing the R package in: ${GITHUB_WORKSPACE}"
      local BUILD_CMD
      if ! BUILD_CMD=$(R CMD build "${GITHUB_WORKSPACE}" 2>&1); then
        warn "Failed to build R package in ${GITHUB_WORKSPACE}. Output: ${BUILD_CMD}"
      else
        local BUILD_PKG
        if ! BUILD_PKG=$(cd "${GITHUB_WORKSPACE}" && echo *.tar.gz 2>&1); then
          warn "Failed to echo R archives. Output: ${BUILD_PKG}"
        fi
        debug "echo R archives output: ${BUILD_PKG}"
        local INSTALL_CMD
        if ! INSTALL_CMD=$(cd "${GITHUB_WORKSPACE}" && R -e "remotes::install_local('.', dependencies=T)" 2>&1); then
          warn "Failed to install the R package. Output: ${BUILD_PKG}]"
        fi
        debug "R package install output: ${INSTALL_CMD}"
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
    info "Initializing TFLint in ${GITHUB_WORKSPACE}"
    local BUILD_CMD
    if ! BUILD_CMD=$(cd "${GITHUB_WORKSPACE}" && tflint --init -c "${TERRAFORM_TFLINT_LINTER_RULES}" 2>&1); then
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

  if [ "${VALIDATE_TERRAFORM_TERRASCAN}" == "true" ] && [ -e "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TERRAFORM_TERRASCAN" ]; then
    info "Initializing Terrascan repository"
    local -a TERRASCAN_INIT_COMMAND
    TERRASCAN_INIT_COMMAND=(terrascan init -c "${TERRAFORM_TERRASCAN_LINTER_RULES}")
    if [[ "${LOG_DEBUG}" == "true" ]]; then
      TERRASCAN_INIT_COMMAND+=(--log-level "debug")
    fi
    debug "Terrascan init command: ${TERRASCAN_INIT_COMMAND[*]}"

    local TERRASCAN_INIT_COMMAND_OUTPUT
    if ! TERRASCAN_INIT_COMMAND_OUTPUT="$("${TERRASCAN_INIT_COMMAND[@]}" 2>&1)"; then
      fatal "Error while initializing Terrascan:\n${TERRASCAN_INIT_COMMAND_OUTPUT}"
    fi
    debug "Terrascan init command output:\n${TERRASCAN_INIT_COMMAND_OUTPUT}"
  fi
}

function IsAnsibleDirectory() {
  local FILE
  FILE="$1"

  if [[ ("${FILE}" =~ .*${ANSIBLE_DIRECTORY}.*) ]] && [[ -d "${FILE}" ]]; then
    debug "${FILE} is the Ansible directory"
    return 0
  else
    return 1
  fi
}
export -f IsAnsibleDirectory
