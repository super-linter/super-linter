#!/usr/bin/env bash

function ValidateBooleanConfigurationVariables() {
  ValidateBooleanVariable "ACTIONS_RUNNER_DEBUG" "${ACTIONS_RUNNER_DEBUG}"
  ValidateBooleanVariable "BASH_EXEC_IGNORE_LIBRARIES" "${BASH_EXEC_IGNORE_LIBRARIES}"
  ValidateBooleanVariable "CREATE_LOG_FILE" "${CREATE_LOG_FILE}"
  ValidateBooleanVariable "DISABLE_ERRORS" "${DISABLE_ERRORS}"
  ValidateBooleanVariable "ENABLE_COMMITLINT_STRICT_MODE" "${ENABLE_COMMITLINT_STRICT_MODE}"
  ValidateBooleanVariable "ENABLE_GITHUB_ACTIONS_GROUP_TITLE" "${ENABLE_GITHUB_ACTIONS_GROUP_TITLE}"
  ValidateBooleanVariable "ENABLE_GITHUB_ACTIONS_STEP_SUMMARY" "${ENABLE_GITHUB_ACTIONS_STEP_SUMMARY}"
  ValidateBooleanVariable "ENFORCE_COMMITLINT_CONFIGURATION_CHECK" "${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}"
  ValidateBooleanVariable "FIX_MODE_ENABLED" "${FIX_MODE_ENABLED}"
  ValidateBooleanVariable "FIX_MODE_TEST_CASE_RUN" "${FIX_MODE_TEST_CASE_RUN}"
  ValidateBooleanVariable "IGNORE_GENERATED_FILES" "${IGNORE_GENERATED_FILES}"
  ValidateBooleanVariable "IGNORE_GITIGNORED_FILES" "${IGNORE_GITIGNORED_FILES}"
  ValidateBooleanVariable "LOG_DEBUG" "${LOG_DEBUG}"
  ValidateBooleanVariable "LOG_ERROR" "${LOG_ERROR}"
  ValidateBooleanVariable "LOG_NOTICE" "${LOG_NOTICE}"
  ValidateBooleanVariable "LOG_VERBOSE" "${LOG_VERBOSE}"
  ValidateBooleanVariable "LOG_WARN" "${LOG_WARN}"
  ValidateBooleanVariable "MULTI_STATUS" "${MULTI_STATUS}"
  ValidateBooleanVariable "REMOVE_ANSI_COLOR_CODES_FROM_OUTPUT" "${REMOVE_ANSI_COLOR_CODES_FROM_OUTPUT}"
  ValidateBooleanVariable "RUN_LOCAL" "${RUN_LOCAL}"
  ValidateBooleanVariable "SAVE_SUPER_LINTER_OUTPUT" "${SAVE_SUPER_LINTER_OUTPUT}"
  ValidateBooleanVariable "SAVE_SUPER_LINTER_SUMMARY" "${SAVE_SUPER_LINTER_SUMMARY}"
  ValidateBooleanVariable "SSH_INSECURE_NO_VERIFY_GITHUB_KEY" "${SSH_INSECURE_NO_VERIFY_GITHUB_KEY}"
  ValidateBooleanVariable "SSH_SETUP_GITHUB" "${SSH_SETUP_GITHUB}"
  ValidateBooleanVariable "SUPPRESS_FILE_TYPE_WARN" "${SUPPRESS_FILE_TYPE_WARN}"
  ValidateBooleanVariable "SUPPRESS_POSSUM" "${SUPPRESS_POSSUM}"
  ValidateBooleanVariable "TEST_CASE_RUN" "${TEST_CASE_RUN}"
  ValidateBooleanVariable "USE_FIND_ALGORITHM" "${USE_FIND_ALGORITHM}"
  ValidateBooleanVariable "VALIDATE_ALL_CODEBASE" "${VALIDATE_ALL_CODEBASE}"
  ValidateBooleanVariable "YAML_ERROR_ON_WARNING" "${YAML_ERROR_ON_WARNING}"
}

function ValidateGitHubWorkspace() {
  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="${1}"
  if [ -z "${GITHUB_WORKSPACE}" ]; then
    fatal "Failed to get GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
  fi

  if [ ! -d "${GITHUB_WORKSPACE}" ]; then
    fatal "The workspace (${GITHUB_WORKSPACE}) is not a directory!"
  fi
  info "Successfully validated GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
}

function ValidateFindMode() {
  debug "Validating find mode. USE_FIND_ALGORITHM: ${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE: ${VALIDATE_ALL_CODEBASE}"
  if [[ "${USE_FIND_ALGORITHM}" == "true" ]] && [[ "${VALIDATE_ALL_CODEBASE}" == "false" ]]; then
    error "Setting USE_FIND_ALGORITHM to true and VALIDATE_ALL_CODEBASE to false is not supported because super-linter relies on Git to validate changed files."
    return 1
  fi
}

function ValidateAnsibleDirectory() {
  if [ -z "${ANSIBLE_DIRECTORY:-}" ]; then
    ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/ansible"
    debug "Set ANSIBLE_DIRECTORY to the default: ${ANSIBLE_DIRECTORY}"
  else
    debug "ANSIBLE_DIRECTORY before considering corner cases: ${ANSIBLE_DIRECTORY}"
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
  export ANSIBLE_DIRECTORY
}

function ValidateValidationVariables() {
  ################################################
  # Determine if any linters were explicitly set #
  ################################################
  local ANY_SET="false"
  local ANY_TRUE="false"
  local ANY_FALSE="false"
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    debug "Check if configuration provided a custom value to enable or disable ${LANGUAGE}"
    local VALIDATE_LANGUAGE
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    if [ -n "${!VALIDATE_LANGUAGE:-}" ]; then
      debug "Configuration provided a custom value for ${VALIDATE_LANGUAGE}: ${!VALIDATE_LANGUAGE}"
      # Validate if user provided a string representing a valid boolean
      ValidateBooleanVariable "${VALIDATE_LANGUAGE}" "${!VALIDATE_LANGUAGE}"
      ANY_SET="true"
      if [ "${!VALIDATE_LANGUAGE}" == "true" ]; then
        ANY_TRUE="true"
      # We already checked that VALIDATE_LANGUAGE is either true or false
      else
        ANY_FALSE="true"
      fi
    else
      debug "Configuration didn't provide a custom value for ${VALIDATE_LANGUAGE}"
    fi
  done

  debug "ANY_SET: ${ANY_SET}, ANY_TRUE: ${ANY_TRUE}, ANY_FALSE: ${ANY_FALSE}"

  if [ $ANY_TRUE == "true" ] && [ $ANY_FALSE == "true" ]; then
    error "Behavior not supported, please either only include (VALIDATE=true) or exclude (VALIDATE=false) linters, but not both"
    return 1
  fi

  #########################################################
  # Validate if we should check/omit individual languages #
  #########################################################
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local VALIDATE_LANGUAGE
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    if [[ ${ANY_SET} == "true" ]]; then
      debug "Configuration contains at least one custom value to enable or disable linters."
      if [ -z "${!VALIDATE_LANGUAGE:-}" ]; then
        # Flag was not set, default to:
        # - true if the configuration provided any false value -> enable linters that the user didn't explicitly disable
        # - false if the configuration didn't provid any false value -> disable linters that the user didn't explicitly enable
        eval "${VALIDATE_LANGUAGE}='$ANY_FALSE'"
      fi
    else
      # The user didn't provide and configuration value -> enable all linters by default
      eval "${VALIDATE_LANGUAGE}='true'"
      debug "Configuration doesn't include any custom values to enable or disable linters. Setting VALIDATE variable for ${LANGUAGE} to: ${!VALIDATE_LANGUAGE}"
    fi

    if [[ "${!VALIDATE_LANGUAGE}" == "true" ]]; then
      debug "- Validating [${LANGUAGE}] files in code base..."
    else
      debug "- Excluding [$LANGUAGE] files in code base..."
    fi

    eval "export ${VALIDATE_LANGUAGE}"
  done
}

function ValidateCheckModeAndFixModeVariables() {
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local FIX_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_FIX_MODE_OPTIONS"
    local CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_CHECK_ONLY_MODE_OPTIONS"
    local FIX_MODE_VARIABLE_NAME="FIX_${LANGUAGE}"
    debug "Check if ${LANGUAGE} supports fix mode by checking if ${FIX_MODE_OPTIONS_VARIABLE_NAME}, ${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}, or both variables are set."
    if [[ -v "${FIX_MODE_OPTIONS_VARIABLE_NAME}" ]] ||
      [[ -v "${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}" ]]; then
      debug "Assuming that ${LANGUAGE} supports fix mode because ${FIX_MODE_OPTIONS_VARIABLE_NAME}, ${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}, or both variables are set."

      local -n FIX_MODE_REF="${FIX_MODE_VARIABLE_NAME}"
      if [[ -n "${FIX_MODE_REF:-}" ]]; then
        debug "The configuration provided a value for ${FIX_MODE_VARIABLE_NAME}: ${FIX_MODE_REF}"
      else
        FIX_MODE_REF="false"
        debug "The configuration didn't provide a value for ${FIX_MODE_VARIABLE_NAME} for ${LANGUAGE}. Setting it to: ${FIX_MODE_REF}"
      fi

      # TODO: After refactoring ValidateBooleanVariable to return an error instead
      # of exiting the whole program, add a test case for when ValidateBooleanVariable fails
      ValidateBooleanVariable "${!FIX_MODE_REF}" "${FIX_MODE_REF}"

      local -n VALIDATE_MODE_REF="VALIDATE_${LANGUAGE}"

      if [[ "${FIX_MODE_REF}" == "true" ]] && [[ "${VALIDATE_MODE_REF}" == "false" ]]; then
        error "Cannot set ${!FIX_MODE_REF} to ${FIX_MODE_REF} when ${!VALIDATE_MODE_REF} is ${VALIDATE_MODE_REF}"
        return 1
      fi

      export FIX_MODE_REF
    else
      debug "Assuming that ${LANGUAGE} doesn't support fix mode because it doesn't have ${FIX_MODE_OPTIONS_VARIABLE_NAME}, nor ${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME} variables defined."
      if [[ -v "${FIX_MODE_VARIABLE_NAME}" ]]; then
        error "The configuration provided a value for ${FIX_MODE_VARIABLE_NAME} but it's not supported for ${LANGUAGE}"
        return 1
      else
        debug "The configuration didn't provide a value for ${FIX_MODE_VARIABLE_NAME} for ${LANGUAGE}"
      fi
    fi

    unset -n FIX_MODE_REF
    unset -n VALIDATE_MODE_REF
  done
}

function CheckIfFixModeIsEnabled() {
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local FIX_MODE_VARIABLE_NAME="FIX_${LANGUAGE}"
    local -n FIX_MODE_REF="${FIX_MODE_VARIABLE_NAME}"

    if [[ -v "${FIX_MODE_VARIABLE_NAME}" ]] &&
      [[ "${FIX_MODE_REF:-"false"}" == "true" ]]; then
      FIX_MODE_ENABLED="true"
      debug "Fix mode for ${LANGUAGE} is ${FIX_MODE_REF}. Set FIX_MODE_ENABLED to ${FIX_MODE_ENABLED}"
    fi
    unset -n FIX_MODE_REF
  done
  ValidateBooleanVariable "FIX_MODE_ENABLED" "${FIX_MODE_ENABLED}"
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

function ValidateBooleanVariable() {
  local VAR_NAME
  VAR_NAME="${1}"

  local VAR_VALUE
  VAR_VALUE="${2}"

  if [[ "${VAR_VALUE}" != "true" ]] && [[ "${VAR_VALUE}" != "false" ]]; then
    fatal "Set ${VAR_NAME} to either true or false. It was set to: ${VAR_VALUE}"
  else
    debug "${VAR_NAME} has a valid boolean string value: ${VAR_VALUE}"
  fi
}
export -f ValidateBooleanVariable

function ValidateLocalGitRepository() {
  debug "Check if ${GITHUB_WORKSPACE} is a Git repository"
  if ! git -C "${GITHUB_WORKSPACE}" rev-parse --git-dir; then
    fatal "${GITHUB_WORKSPACE} is not a Git repository."
  else
    debug "${GITHUB_WORKSPACE} is a Git repository"
  fi

  debug "Git branches: $(git -C "${GITHUB_WORKSPACE}" branch -a)"
}

function CheckIfGitRefExists() {
  local GIT_REF=${1}
  if git -C "${GITHUB_WORKSPACE}" cat-file -e "${GIT_REF}"; then
    return 0
  else
    return 1
  fi
}

function IsUnsignedInteger() {
  case ${1} in
  '' | *[!0-9]*)
    return 1
    ;;
  *)
    return 0
    ;;
  esac
}

function ValidateGitShaReference() {
  debug "Git HEAD: $(git -C "${GITHUB_WORKSPACE}" show HEAD --stat)"

  debug "Validate that the GITHUB_SHA reference (${GITHUB_SHA}) exists in this Git repository."
  if ! CheckIfGitRefExists "${GITHUB_SHA}"; then
    IssueHintForFullGitHistory
    fatal "The GITHUB_SHA reference (${GITHUB_SHA}) doesn't exist in this Git repository"
  else
    debug "The GITHUB_SHA reference (${GITHUB_SHA}) exists in this repository"
  fi
}

InitializeAndValidateGitBeforeShaReference() {
  debug "Initializing and validating GITHUB_BEFORE_SHA"
  debug "Check if the ${GITHUB_SHA} commit is a merge commit by checking if it has more than one parent"

  local GITHUB_SHA="${1}"
  local -i GITHUB_EVENT_COMMIT_COUNT="${2}"
  local GIT_ROOT_COMMIT_SHA="${3}"

  if [[ "${GITHUB_SHA}" == "${GIT_ROOT_COMMIT_SHA}" ]]; then
    debug "${GITHUB_SHA} is the initial commit. Skip initializing GITHUB_BEFORE_SHA because there cannot be any commit before the initial commit"
    return 0
  fi
  debug "${GITHUB_SHA} is not the initial commit. Initializing and validating GITHUB_BEFORE_SHA"

  local -i GIT_COMMIT_PARENTS_COUNT
  GIT_COMMIT_PARENTS_COUNT="$(git -C "${GITHUB_WORKSPACE}" rev-list --parents -n 1 "${GITHUB_SHA}" | wc -w)"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    fatal "Error while getting ${GITHUB_SHA} commit parents count. Output: ${GIT_COMMIT_PARENTS_COUNT}"
  fi
  debug "${GITHUB_SHA} git commit parents count (GIT_COMMIT_PARENTS_COUNT): ${GIT_COMMIT_PARENTS_COUNT}"
  GIT_COMMIT_PARENTS_COUNT=$((GIT_COMMIT_PARENTS_COUNT - 1))
  debug "Subtract 1 from GIT_COMMIT_PARENTS_COUNT to get the actual number of merge parents because the count includes the ${GITHUB_SHA} commit itself. GIT_COMMIT_PARENTS_COUNT: ${GIT_COMMIT_PARENTS_COUNT}"

  # Ref: https://git-scm.com/docs/git-rev-parse#Documentation/git-rev-parse.txt
  # Use GITHUB_SHA instead of HEAD because for pull requests, HEAD points that the PR merge commit
  local GIT_BEFORE_SHA_HEAD="${GITHUB_SHA}"
  if [ ${GIT_COMMIT_PARENTS_COUNT} -gt 1 ]; then
    debug "${GITHUB_SHA} is a merge commit because it has more than one parent."
    GIT_BEFORE_SHA_HEAD="${GIT_BEFORE_SHA_HEAD}^2"
    debug "Add the suffix to GIT_BEFORE_SHA_HEAD to get the second parent of the merge commit: ${GIT_BEFORE_SHA_HEAD}"

    if [ ${GITHUB_EVENT_COMMIT_COUNT} -gt 0 ]; then
      GITHUB_EVENT_COMMIT_COUNT=$((GITHUB_EVENT_COMMIT_COUNT - 1))
      debug "Remove one commit from GITHUB_EVENT_COMMIT_COUNT to account for the merge commit. GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"
    else
      debug "Don't subtract one commit from GITHUB_EVENT_COMMIT_COUNT to account for the merge commit because there were no commits pushed. GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"
    fi
  else
    debug "${GITHUB_SHA} is not a merge commit because it has a single parent. No need to add the parent identifier (^) to the revision indicator because it's implicitly set to ^1 when there's only one parent."
  fi

  GIT_BEFORE_SHA_HEAD="${GIT_BEFORE_SHA_HEAD}~${GITHUB_EVENT_COMMIT_COUNT}"
  debug "GIT_BEFORE_SHA_HEAD: ${GIT_BEFORE_SHA_HEAD}"

  # shellcheck disable=SC2086  # We checked that GITHUB_EVENT_COMMIT_COUNT is an integer
  GITHUB_BEFORE_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse ${GIT_BEFORE_SHA_HEAD})"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    fatal "Failed to initialize GITHUB_BEFORE_SHA for a ${GITHUB_EVENT_NAME} event. Output: ${GITHUB_BEFORE_SHA}"
  fi

  debug "Validating GITHUB_BEFORE_SHA: ${GITHUB_BEFORE_SHA}"
  if [ -z "${GITHUB_BEFORE_SHA}" ] ||
    [ "${GITHUB_BEFORE_SHA}" == "null" ] ||
    [ "${GITHUB_BEFORE_SHA}" == "0000000000000000000000000000000000000000" ]; then
    fatal "Failed to get GITHUB_BEFORE_SHA: [${GITHUB_BEFORE_SHA}]"
  fi

  debug "Validate that the GITHUB_BEFORE_SHA reference (${GITHUB_BEFORE_SHA}) exists in this Git repository."
  if ! CheckIfGitRefExists "${GITHUB_BEFORE_SHA}"; then
    fatal "The GITHUB_BEFORE_SHA reference (${GITHUB_BEFORE_SHA}) doesn't exist in this Git repository"
  else
    debug "The GITHUB_BEFORE_SHA reference (${GITHUB_BEFORE_SHA}) exists in this repository"
  fi

  debug "Successfully found GITHUB_BEFORE_SHA: ${GITHUB_BEFORE_SHA}"
  export GITHUB_BEFORE_SHA
}

InitializeRootCommitSha() {
  GIT_ROOT_COMMIT_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-list --max-parents=0 "${GITHUB_SHA}")"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to get the root commit: ${GIT_ROOT_COMMIT_SHA}"
    return 1
  else
    debug "Successfully found the root commit: ${GIT_ROOT_COMMIT_SHA}"
  fi
  export GIT_ROOT_COMMIT_SHA
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

function CheckovConfigurationFileContainsDirectoryOption() {
  local CHECKOV_LINTER_RULES_PATH="${1}"
  local CONFIGURATION_OPTION_KEY="directory:"
  debug "Checking if ${CHECKOV_LINTER_RULES_PATH} contains a '${CONFIGURATION_OPTION_KEY}' configuration option"

  if [ ! -e "${CHECKOV_LINTER_RULES_PATH}" ]; then
    fatal "${CHECKOV_LINTER_RULES_PATH} doesn't exist. Cannot check if it contains a '${CONFIGURATION_OPTION_KEY}' configuration option"
  fi

  if grep -q "${CONFIGURATION_OPTION_KEY}" "${CHECKOV_LINTER_RULES_PATH}"; then
    debug "${CHECKOV_LINTER_RULES_PATH} contains a '${CONFIGURATION_OPTION_KEY}' statement"
    return 0
  else
    debug "${CHECKOV_LINTER_RULES_PATH} doesn't contain a '${CONFIGURATION_OPTION_KEY}' statement"
    return 1
  fi
}
export -f CheckovConfigurationFileContainsDirectoryOption

function ValidateGitHubUrls() {
  if [[ -z "${DEFAULT_GITHUB_DOMAIN:-}" ]]; then
    error "DEFAULT_GITHUB_DOMAIN is empty."
    return 1
  fi
  debug "Default GitHub domain: ${DEFAULT_GITHUB_DOMAIN}"

  if [[ -z "${GITHUB_DOMAIN:-}" ]]; then
    error "GITHUB_DOMAIN is empty."
    return 1
  fi
  debug "GitHub domain: ${GITHUB_DOMAIN}"

  if [[ "${GITHUB_DOMAIN}" != "${DEFAULT_GITHUB_DOMAIN}" ]]; then
    debug "GITHUB_DOMAIN (${GITHUB_DOMAIN}) is not set to the default GitHub domain (${DEFAULT_GITHUB_DOMAIN})"

    if [[ -n "${GITHUB_CUSTOM_API_URL:-}" || -n "${GITHUB_CUSTOM_SERVER_URL:-}" ]]; then
      error "Cannot set GITHUB_DOMAIN (${GITHUB_DOMAIN}) along with GITHUB_CUSTOM_API_URL (${GITHUB_CUSTOM_API_URL:-}) or with GITHUB_CUSTOM_SERVER_URL (${GITHUB_CUSTOM_SERVER_URL:-})."
      return 1
    fi
  else
    debug "GITHUB_DOMAIN (${GITHUB_DOMAIN}) is set to the default GitHub domain (${DEFAULT_GITHUB_DOMAIN})"

    if [[ -n "${GITHUB_CUSTOM_API_URL:-}" && -z "${GITHUB_CUSTOM_SERVER_URL:-}" ]] ||
      [[ -z "${GITHUB_CUSTOM_API_URL:-}" && -n "${GITHUB_CUSTOM_SERVER_URL:-}" ]]; then
      error "Configure both GITHUB_CUSTOM_API_URL and GITHUB_CUSTOM_SERVER_URL. Current values: GITHUB_CUSTOM_API_URL: ${GITHUB_CUSTOM_API_URL:-}, GITHUB_CUSTOM_SERVER_URL: ${GITHUB_CUSTOM_SERVER_URL:-}"
      return 1
    fi
  fi
}

function ValidateSuperLinterSummaryOutputPath() {
  debug "Validating SUPER_LINTER_SUMMARY_OUTPUT_PATH"
  if [[ -z "${SUPER_LINTER_SUMMARY_OUTPUT_PATH:-}" ]]; then
    error "SUPER_LINTER_SUMMARY_OUTPUT_PATH is not set."
    return 1
  fi
  debug "SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to: ${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
  if [[ ! -e "${SUPER_LINTER_SUMMARY_OUTPUT_PATH}" ]]; then
    error "SUPER_LINTER_SUMMARY_OUTPUT_PATH (${SUPER_LINTER_SUMMARY_OUTPUT_PATH}) doesn't exist."
    return 1
  fi
  if [[ ! -f "${SUPER_LINTER_SUMMARY_OUTPUT_PATH}" ]]; then
    error "SUPER_LINTER_SUMMARY_OUTPUT_PATH (${SUPER_LINTER_SUMMARY_OUTPUT_PATH}) is not a file."
    return 1
  fi
  debug "Super-linter summary ouput path passed validation"
}

ValidateCommitlintConfiguration() {
  local GITHUB_WORKSPACE="${1}"
  local ENFORCE_COMMITLINT_CONFIGURATION_CHECK="${2}"

  debug "Validating Commitlint configuration. Enforce commitlint configuration check: ${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}"

  if [[ "${VALIDATE_GIT_COMMITLINT}" == "true" ]]; then
    local COMMITLINT_VERSION_CHECK_OUTPUT
    COMMITLINT_VERSION_CHECK_OUTPUT="$(commitlint --cwd "${GITHUB_WORKSPACE}" --last)"
    local COMMITLINT_EXIT_CODE=$?
    debug "Commitlint configuration check output:\n${COMMITLINT_VERSION_CHECK_OUTPUT}"
    # Commitlint exits with 9 if no configuration file is avaialble.
    # Ref: https://github.com/conventional-changelog/commitlint/pull/4143
    # Ref: https://commitlint.js.org/reference/cli.html
    # Set this here so we can reuse this variable for tests
    COMMITLINT_EXIT_CODE_CONFIGURATION_ERROR=9
    if [[ ${COMMITLINT_EXIT_CODE} -eq ${COMMITLINT_EXIT_CODE_CONFIGURATION_ERROR} ]]; then
      warn "Git commit message validation with commitlint is enabled, but no commitlint configuration file is available. Disabling commitlint. To suppress this message, either disable Git commit validation by setting VALIDATE_GIT_COMMITLINT to false in your Super-linter configuration, or provide a commitlint configuration file."
      VALIDATE_GIT_COMMITLINT="false"
      export VALIDATE_GIT_COMMITLINT

      if [[ "${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}" == "true" ]]; then
        info "Commitlint configuration check enforcement is enabled. Exiting with an error because the commitlint configuration check failed."
        return 1
      fi
    fi
  else
    debug "Commitlint is disabled. Skipping commitlint configuration validation"
  fi
}

function WarnIfVariableIsSet() {
  local INPUT_VARIABLE="${1}"
  shift
  local INPUT_VARIABLE_NAME="${1}"

  if [ -n "${INPUT_VARIABLE:-}" ]; then
    warn "${INPUT_VARIABLE_NAME} environment variable is set, it's deprecated, and super-linter will ignore it. Remove it from your configuration. This warning may turn in a fatal error in the future. For more information, see the upgrade guide: https://github.com/super-linter/super-linter/blob/main/docs/upgrade-guide.md"
  fi
}

function WarnIfDeprecatedValueForConfigurationVariableIsSet() {
  local INPUT_VARIABLE_VALUE
  INPUT_VARIABLE_VALUE="${1}"
  shift
  local DEPRECATED_VARIABLE_VALUE
  DEPRECATED_VARIABLE_VALUE="${1}"
  shift
  local INPUT_VARIABLE_NAME
  INPUT_VARIABLE_NAME="${1}"
  shift
  local VALUE_TO_UPDATE_TO
  VALUE_TO_UPDATE_TO="${1}"

  if [[ "${INPUT_VARIABLE_VALUE}" == "${DEPRECATED_VARIABLE_VALUE}" ]]; then
    warn "${INPUT_VARIABLE_NAME} is set to a deprecated value: ${DEPRECATED_VARIABLE_VALUE}. Set it to ${VALUE_TO_UPDATE_TO} instead. Falling back to ${VALUE_TO_UPDATE_TO}. This warning may turn in a fatal error in the future."
  fi
}

function ValidateDeprecatedVariables() {

  # The following variables have been deprecated in v6.0.0
  WarnIfVariableIsSet "${ERROR_ON_MISSING_EXEC_BIT:-}" "ERROR_ON_MISSING_EXEC_BIT"
  WarnIfVariableIsSet "${EXPERIMENTAL_BATCH_WORKER:-}" "EXPERIMENTAL_BATCH_WORKER"
  WarnIfVariableIsSet "${VALIDATE_JSCPD_ALL_CODEBASE:-}" "VALIDATE_JSCPD_ALL_CODEBASE"
  WarnIfVariableIsSet "${VALIDATE_KOTLIN_ANDROID:-}" "VALIDATE_KOTLIN_ANDROID"

  # The following values have been deprecated in v6.1.0
  WarnIfDeprecatedValueForConfigurationVariableIsSet "${LOG_LEVEL}" "TRACE" "LOG_LEVEL" "DEBUG"
  WarnIfDeprecatedValueForConfigurationVariableIsSet "${LOG_LEVEL}" "VERBOSE" "LOG_LEVEL" "INFO"

  # The following variables have been deprecated in v6.8.0
  WarnIfVariableIsSet "${JAVASCRIPT_DEFAULT_STYLE:-}" "JAVASCRIPT_DEFAULT_STYLE"
  WarnIfVariableIsSet "${TYPESCRIPT_DEFAULT_STYLE:-}" "TYPESCRIPT_DEFAULT_STYLE"

  # The following variables have been deprecated in v7.0.0
  WarnIfVariableIsSet "${SQL_CONFIG_FILE:-}" "SQL_CONFIG_FILE"
  WarnIfVariableIsSet "${VALIDATE_SQL:-}" "VALIDATE_SQL"
}
