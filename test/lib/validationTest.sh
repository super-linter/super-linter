#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/validation.sh"

# shellcheck source=/dev/null
source "lib/functions/githubEvent.sh"

IsUnsignedIntegerTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local INPUT=1
  if ! IsUnsignedInteger ${INPUT}; then
    fatal "${FUNCTION_NAME} should have succeeded when checking ${INPUT}"
  fi

  INPUT="test"
  if IsUnsignedInteger "${INPUT}"; then
    fatal "${FUNCTION_NAME} should have failed when checking ${INPUT}"
  fi

  INPUT=-1
  if IsUnsignedInteger ${INPUT}; then
    fatal "${FUNCTION_NAME} should have failed when checking ${INPUT}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

# In the current implementation, there is no return value to assert
function ValidateDeprecatedVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  ERROR_ON_MISSING_EXEC_BIT="true" \
    ValidateDeprecatedVariables
  EXPERIMENTAL_BATCH_WORKER="true" \
    ValidateDeprecatedVariables
  LOG_LEVEL="TRACE" \
    ValidateDeprecatedVariables
  LOG_LEVEL="VERBOSE" \
    ValidateDeprecatedVariables
  VALIDATE_JSCPD_ALL_CODEBASE="true" \
    ValidateDeprecatedVariables
  VALIDATE_KOTLIN_ANDROID="true" \
    ValidateDeprecatedVariables
  EDITORCONFIG_FILE_NAME=".ecrc" \
    ValidateDeprecatedVariables

  notice "${FUNCTION_NAME} PASS"
}

function ValidateGitHubUrlsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  DEFAULT_GITHUB_DOMAIN="github.com"

  # shellcheck disable=SC2034
  GITHUB_DOMAIN=
  if ValidateGitHubUrls; then
    fatal "Empty GITHUB_DOMAIN should have failed validation"
  else
    info "Empty GITHUB_DOMAIN passed validation"
  fi

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="github.example.com"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} should have passed validation"
  else
    info "${GITHUB_DOMAIN} passed validation"
  fi
  unset GITHUB_DOMAIN

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} should have passed validation"
  else
    info "${GITHUB_DOMAIN} passed validation"
  fi
  unset GITHUB_DOMAIN

  GITHUB_DOMAIN="github.example.com"
  # shellcheck disable=SC2034
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="github.example.com"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_SERVER_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_SERVER_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN}, ${GITHUB_CUSTOM_API_URL}, and ${GITHUB_CUSTOM_SERVER_URL} should have passed validation"
  else
    info "${GITHUB_DOMAIN}, ${GITHUB_CUSTOM_API_URL}, and ${GITHUB_CUSTOM_SERVER_URL} passed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL
  unset GITHUB_CUSTOM_SERVER_URL

  notice "${FUNCTION_NAME} PASS"
}

function ValidateSuperLinterSummaryOutputPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="/non/existing/file"
  if ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have failed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a non-existing file"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} failed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="$(pwd)"
  if ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have failed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a directory"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} failed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="${0}"
  if ! ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have passed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a file"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} passed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  notice "${FUNCTION_NAME} PASS"
}

function ValidateFindModeTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  USE_FIND_ALGORITHM="true"
  VALIDATE_ALL_CODEBASE="false"
  if ValidateFindMode; then
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have failed validation"
  else
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} failed validation as expected"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="false"
  VALIDATE_ALL_CODEBASE="false"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="false"
  VALIDATE_ALL_CODEBASE="true"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="true"
  VALIDATE_ALL_CODEBASE="true"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  notice "${FUNCTION_NAME} PASS"
}

function ValidateAnsibleDirectoryTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  GITHUB_WORKSPACE="/test-github-workspace"

  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/ansible"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  ANSIBLE_DIRECTORY="."
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  INPUT_ANSIBLE_DIRECTORY="/custom-ansible-directory"
  ANSIBLE_DIRECTORY="${INPUT_ANSIBLE_DIRECTORY}"
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}${INPUT_ANSIBLE_DIRECTORY}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  INPUT_ANSIBLE_DIRECTORY="custom-ansible-directory"
  ANSIBLE_DIRECTORY="${INPUT_ANSIBLE_DIRECTORY}"
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/${INPUT_ANSIBLE_DIRECTORY}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  unset GITHUB_WORKSPACE

  notice "${FUNCTION_NAME} PASS"
}

function ValidateValidationVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A' 'B')

  if ValidateValidationVariables; then
    info "Providing no VALIDATE_xxx variables passed validation as expected"
  else
    fatal "Providing no VALIDATE_xxx variables should have passed validation"
  fi

  VALIDATE_A="true"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A} should have passed validation"
  fi
  unset VALIDATE_A

  # TODO: Refactor the ValidateBooleanVariable function to throw an error instead of a fatal
  # VALIDATE_A="blah"
  # if ! ValidateValidationVariables; then
  #   info "VALIDATE_A=${VALIDATE_A} failed validation as expected"
  # else
  #   fatal "VALIDATE_A=${VALIDATE_A} should have failed validation"
  # fi
  # unset VALIDATE_A

  VALIDATE_A="true"
  VALIDATE_B="true"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have passed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="false"
  VALIDATE_B="false"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have passed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="true"
  VALIDATE_B="false"
  if ! ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} failed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have failed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="false"
  VALIDATE_B="true"
  if ! ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} failed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have failed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  notice "${FUNCTION_NAME} PASS"
}

function ValidationVariablesExportTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A' 'B')

  ValidateValidationVariables

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local -n VALIDATE_LANGUAGE
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    debug "VALIDATE_LANGUAGE (Language: ${LANGUAGE}) variable attributes: ${VALIDATE_LANGUAGE@a}"
    if [[ "${VALIDATE_LANGUAGE@a}" == *x* ]]; then
      info "VALIDATE_LANGUAGE for ${LANGUAGE} is exported as expected"
    else
      fatal "VALIDATE_LANGUAGE for ${LANGUAGE} should have been exported"
    fi
    unset -n VALIDATE_LANGUAGE
  done

  notice "${FUNCTION_NAME} PASS"
}

function ValidateCheckModeAndFixModeVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A' 'B' 'C' 'D')
  # shellcheck disable=SC2034
  A_FIX_MODE_OPTIONS=(--fixA)
  # shellcheck disable=SC2034
  A_CHECK_ONLY_MODE_OPTIONS=(--checkA)
  # shellcheck disable=SC2034
  B_FIX_MODE_OPTIONS=(--fixB)
  # shellcheck disable=SC2034
  C_CHECK_ONLY_MODE_OPTIONS=(--checkC)

  # shellcheck disable=SC2034
  VALIDATE_A="true"
  # shellcheck disable=SC2034
  VALIDATE_B="true"
  # shellcheck disable=SC2034
  VALIDATE_C="true"
  # shellcheck disable=SC2034
  FIX_B="true"

  if ! ValidateCheckModeAndFixModeVariables; then
    fatal "Error while validating fix mode variables"
  fi

  if [[ -v FIX_A ]]; then
    debug "FIX_A variable is defined as expected"
  else
    fatal "FIX_A variable should have been defined"
  fi

  EXPECTED_FIX_A="false"
  if [[ "${FIX_A}" == "${EXPECTED_FIX_A}" ]]; then
    debug "FIX_A variable has the expected value: ${FIX_A}"
  else
    fatal "FIX_A (${FIX_A}) doesn't match with the expected value: ${EXPECTED_FIX_A}"
  fi

  if [[ -v FIX_C ]]; then
    debug "FIX_C variable is defined as expected"
  else
    fatal "FIX_C variable should have been defined"
  fi

  EXPECTED_FIX_C="false"
  if [[ "${FIX_C}" == "${EXPECTED_FIX_C}" ]]; then
    debug "FIX_C variable has the expected value: ${FIX_C}"
  else
    fatal "FIX_C (${FIX_C}) doesn't match with the expected value: ${EXPECTED_FIX_C}"
  fi

  # No need to check if FIX_B is defined because we defined it earlier in this test function

  if [[ ! -v FIX_D ]]; then
    debug "FIX_D is not defined as expected"
  else
    fatal "FIX_D variable should have not been defined"
  fi

  debug "FIX_A variable attributes: ${FIX_A@a}"
  if [[ "${FIX_A@a}" == *x* ]]; then
    debug "FIX_A is exported as expected"
  else
    fatal "FIX_A should have been exported"
  fi

  debug "FIX_B variable attributes: ${FIX_B@a}"
  if [[ "${FIX_B@a}" == *x* ]]; then
    debug "FIX_B is exported as expected"
  else
    fatal "FIX_B should have been exported"
  fi

  debug "FIX_C variable attributes: ${FIX_C@a}"
  if [[ "${FIX_C@a}" == *x* ]]; then
    debug "FIX_C is exported as expected"
  else
    fatal "FIX_C should have been exported"
  fi

  unset FIX_A
  unset FIX_B
  unset FIX_C
  unset FIX_D
  unset VALIDATE_A
  unset VALIDATE_B
  unset VALIDATE_C

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('E')
  # shellcheck disable=SC2034
  E_FIX_MODE_OPTIONS=(--fixA)
  FIX_E="true"
  VALIDATE_E="false"

  if ValidateCheckModeAndFixModeVariables; then
    fatal "FIX_E (${FIX_E}) and VALIDATE_E (${VALIDATE_E}) should have failed validation"
  else
    debug "FIX_E (${FIX_E}) and VALIDATE_E (${VALIDATE_E}) failed validation as expected"
  fi

  unset FIX_E
  unset VALIDATE_E

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('F')
  FIX_F="true"

  if ValidateCheckModeAndFixModeVariables; then
    fatal "FIX_F (${FIX_F}) should have failed validation when it doesn't support fix mode or check only mode"
  else
    debug "FIX_F (${FIX_F}) failed validation as expected when it doesn't support fix mode or check only mode"
  fi

  unset FIX_F
  unset VALIDATE_F

  notice "${FUNCTION_NAME} PASS"
}

CheckIfFixModeIsEnabledTest() {
  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A')

  FIX_MODE_ENABLED="false"
  FIX_A="true"
  CheckIfFixModeIsEnabled
  EXPECTED_FIX_MODE_ENABLED="true"
  if [[ "${FIX_MODE_ENABLED}" == "${EXPECTED_FIX_MODE_ENABLED}" ]]; then
    debug "FIX_MODE_ENABLED variable has the expected value: ${FIX_MODE_ENABLED}"
  else
    fatal "FIX_MODE_ENABLED (${FIX_MODE_ENABLED}) doesn't match with the expected value: ${EXPECTED_FIX_MODE_ENABLED}"
  fi

  FIX_MODE_ENABLED="false"
  FIX_A="false"
  CheckIfFixModeIsEnabled
  EXPECTED_FIX_MODE_ENABLED="false"
  if [[ "${FIX_MODE_ENABLED}" == "${EXPECTED_FIX_MODE_ENABLED}" ]]; then
    debug "FIX_MODE_ENABLED variable has the expected value: ${FIX_MODE_ENABLED}"
  else
    fatal "FIX_MODE_ENABLED (${FIX_MODE_ENABLED}) doesn't match with the expected value: ${EXPECTED_FIX_MODE_ENABLED}"
  fi

}

ValidateCommitlintConfigurationTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  local ENFORCE_COMMITLINT_CONFIGURATION_CHECK="false"

  VALIDATE_GIT_COMMITLINT="false"
  if ! ValidateCommitlintConfiguration "${GITHUB_WORKSPACE}" "${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}"; then
    fatal "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT} should have passed validation"
  else
    debug "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT} passed validation as expected"
  fi

  VALIDATE_GIT_COMMITLINT="true"
  if ! ValidateCommitlintConfiguration "${GITHUB_WORKSPACE}" "${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}"; then
    fatal "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT}, ENFORCE_COMMITLINT_CONFIGURATION_CHECK: ${ENFORCE_COMMITLINT_CONFIGURATION_CHECK} should have passed validation"
  else
    debug "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT}, ENFORCE_COMMITLINT_CONFIGURATION_CHECK: ${ENFORCE_COMMITLINT_CONFIGURATION_CHECK} passed validation as expected"
  fi
  if [[ "${VALIDATE_GIT_COMMITLINT}" == "true" ]]; then
    fatal "VALIDATE_GIT_COMMITLINT should have been false"
  else
    debug "VALIDATE_GIT_COMMITLINT is ${VALIDATE_GIT_COMMITLINT} as expected"
  fi

  VALIDATE_GIT_COMMITLINT="true"
  ENFORCE_COMMITLINT_CONFIGURATION_CHECK="true"
  if ValidateCommitlintConfiguration "${GITHUB_WORKSPACE}" "${ENFORCE_COMMITLINT_CONFIGURATION_CHECK}"; then
    fatal "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT}, ENFORCE_COMMITLINT_CONFIGURATION_CHECK: ${ENFORCE_COMMITLINT_CONFIGURATION_CHECK} should have failed validation"
  else
    debug "VALIDATE_GIT_COMMITLINT: ${VALIDATE_GIT_COMMITLINT}, ENFORCE_COMMITLINT_CONFIGURATION_CHECK: ${ENFORCE_COMMITLINT_CONFIGURATION_CHECK} failed validation as expected"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitBeforeShaReferenceFastForwardPushTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  local -i COMMIT_COUNT=3

  for ((i = 0; i < COMMIT_COUNT; i++)); do
    touch "${GITHUB_WORKSPACE}/file-${i}.txt"
    git -C "${GITHUB_WORKSPACE}" add .
    git -C "${GITHUB_WORKSPACE}" commit -m "add file-${i}"

    # Set EXPECTED_GITHUB_BEFORE_SHA to the initial commit because it's the only
    # one we don't push
    if [[ "${i}" -eq 0 ]]; then
      local EXPECTED_GITHUB_BEFORE_SHA
      EXPECTED_GITHUB_BEFORE_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse HEAD)"
      debug "Setting EXPECTED_GITHUB_BEFORE_SHA to ${EXPECTED_GITHUB_BEFORE_SHA}"
    fi
  done

  git_log_graph "${GITHUB_WORKSPACE}"

  initialize_github_sha "${GITHUB_WORKSPACE}"

  # Simulate pushing all the commits besides the initial one
  InitializeGitBeforeShaReference "${GITHUB_SHA}" "((${COMMIT_COUNT}-1))" "${EXPECTED_GITHUB_BEFORE_SHA}" "push" "${DEFAULT_BRANCH}"

  if [[ "${GITHUB_BEFORE_SHA}" != "${EXPECTED_GITHUB_BEFORE_SHA}" ]]; then
    fatal "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) is not equal to the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  else
    debug "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) matches the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitBeforeShaReferenceMergeCommitTest() {
  local EVENT_NAME="${1}"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  local -i COMMIT_COUNT=3

  if [[ "${EVENT_NAME}" == "pull_request" ]] ||
    [[ "${EVENT_NAME}" == "pull_request_target" ]]; then
    initialize_git_repository_contents "${GITHUB_WORKSPACE}" "${COMMIT_COUNT}" "true" "${EVENT_NAME}" "true" "false" "false" "true"
  elif [[ "${EVENT_NAME}" == "merge_group" ]]; then
    initialize_git_repository_contents "${GITHUB_WORKSPACE}" "${COMMIT_COUNT}" "true" "${EVENT_NAME}" "false" "false" "false" "true"
  fi
  local EXPECTED_GITHUB_BEFORE_SHA="${GIT_ROOT_COMMIT_SHA}"
  debug "Setting EXPECTED_GITHUB_BEFORE_SHA to ${EXPECTED_GITHUB_BEFORE_SHA}"

  GITHUB_SHA="${GITHUB_PULL_REQUEST_HEAD_SHA}"
  debug "Updating GITHUB_SHA to the pull request head SHA for the ${FUNCTION_NAME} test: ${GITHUB_SHA}"

  InitializeGitBeforeShaReference "${GITHUB_SHA}" "((${COMMIT_COUNT}))" "${EXPECTED_GITHUB_BEFORE_SHA}" "${EVENT_NAME}" "${DEFAULT_BRANCH}"

  if [[ "${GITHUB_BEFORE_SHA}" != "${EXPECTED_GITHUB_BEFORE_SHA}" ]]; then
    fatal "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) is not equal to the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  else
    debug "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) matches the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  fi
}

InitializeGitBeforeShaReferenceMergeCommitPullRequestTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitializeGitBeforeShaReferenceMergeCommitTest "pull_request"

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitBeforeShaReferenceMergeCommitPullRequestTargetGroupTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitializeGitBeforeShaReferenceMergeCommitTest "pull_request_target"

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitBeforeShaReferenceMergeCommitMergeGroupTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  InitializeGitBeforeShaReferenceMergeCommitTest "merge_group"

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitBeforeShaReferenceMergeDefaultBranchInPullRequestBranchTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  touch "${GITHUB_WORKSPACE}/test-${DEFAULT_BRANCH}-0.txt"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "initial commit"

  GIT_ROOT_COMMIT_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse HEAD)"

  local FEATURE_BRANCH_1_NAME="feature/test-branch-1"
  local FEATURE_BRANCH_2_NAME="feature/test-branch-2"

  debug "Create feature branch"
  git -C "${GITHUB_WORKSPACE}" checkout -b "${FEATURE_BRANCH_1_NAME}"

  info "Add commits to ${FEATURE_BRANCH_1_NAME}"
  for i in {1..3}; do
    touch "${GITHUB_WORKSPACE}/file${i}.txt"
    git -C "${GITHUB_WORKSPACE}" add .
    git -C "${GITHUB_WORKSPACE}" commit -m "feat: commit ${i}"
  done

  debug "Create a new feature branch from ${DEFAULT_BRANCH}"
  git -C "${GITHUB_WORKSPACE}" switch "${DEFAULT_BRANCH}"
  git -C "${GITHUB_WORKSPACE}" checkout -b "${FEATURE_BRANCH_2_NAME}"

  debug "Add commits to ${FEATURE_BRANCH_2_NAME}"
  touch "${GITHUB_WORKSPACE}/file-feat-branch-2.txt"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "feat: commit on ${FEATURE_BRANCH_2_NAME}"

  debug "Switch to ${FEATURE_BRANCH_1_NAME}"
  git -C "${GITHUB_WORKSPACE}" switch "${FEATURE_BRANCH_1_NAME}"

  info "Merge ${FEATURE_BRANCH_2_NAME} to ${FEATURE_BRANCH_1_NAME} (without squashing)"
  git -C "${GITHUB_WORKSPACE}" merge \
    -m "chore: merge commit ${FEATURE_BRANCH_2_NAME} into ${FEATURE_BRANCH_1_NAME}" \
    --no-ff \
    "${FEATURE_BRANCH_2_NAME}"

  info "Add commits to ${FEATURE_BRANCH_1_NAME}"
  touch "${GITHUB_WORKSPACE}/file-feat-1.txt"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "feat: commit on ${FEATURE_BRANCH_1_NAME}"

  local -i COMMIT_COUNT
  COMMIT_COUNT=$(git -C "${GITHUB_WORKSPACE}" rev-list --count main.."${FEATURE_BRANCH_1_NAME}")
  debug "Setting COMMIT_COUNT to ${COMMIT_COUNT}"

  git_log_graph "${GITHUB_WORKSPACE}"

  initialize_github_sha "${GITHUB_WORKSPACE}"

  GITHUB_PULL_REQUEST_HEAD_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse "${FEATURE_BRANCH_1_NAME}")"

  local EXPECTED_GITHUB_BEFORE_SHA="${GIT_ROOT_COMMIT_SHA}"
  debug "Setting EXPECTED_GITHUB_BEFORE_SHA to ${EXPECTED_GITHUB_BEFORE_SHA}"

  GITHUB_SHA="${GITHUB_PULL_REQUEST_HEAD_SHA}"
  debug "Updating GITHUB_SHA to the pull request head SHA for the ${FUNCTION_NAME} test: ${GITHUB_SHA}"

  # Simulate pushing all the commits besides the initial one
  InitializeGitBeforeShaReference "${GITHUB_SHA}" "((${COMMIT_COUNT}))" "${EXPECTED_GITHUB_BEFORE_SHA}" "pull_request" "${DEFAULT_BRANCH}"

  if [[ "${GITHUB_BEFORE_SHA}" != "${EXPECTED_GITHUB_BEFORE_SHA}" ]]; then
    fatal "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) is not equal to the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  else
    debug "GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) matches the expected value: ${EXPECTED_GITHUB_BEFORE_SHA}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InitializeRootCommitShaTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  initialize_git_repository_contents "${GITHUB_WORKSPACE}" 0 "false" "push" "false" "false" "false" "true"

  local EXPECTED_GIT_ROOT_COMMIT_SHA="${GIT_ROOT_COMMIT_SHA}"
  unset GIT_ROOT_COMMIT_SHA

  InitializeRootCommitSha

  if [[ "${GIT_ROOT_COMMIT_SHA}" != "${EXPECTED_GIT_ROOT_COMMIT_SHA}" ]]; then
    fatal "GIT_ROOT_COMMIT_SHA (${GIT_ROOT_COMMIT_SHA}) doesn't match the expected value: ${EXPECTED_GIT_ROOT_COMMIT_SHA}"
  fi

  unset GIT_ROOT_COMMIT_SHA
  notice "${FUNCTION_NAME} PASS"
}

DeprecatedConfigurationFileExistsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local EDITORCONFIG_LINTER_RULES="test/data/deprecated-linter-rules-test/.editorconfig-checker.json"
  # shellcheck disable=SC2034
  local LANGUAGE_NAME="EDITORCONFIG"
  # shellcheck disable=SC2034
  local VALIDATE_EDITORCONFIG="true"
  local DEPRECATED_CONFIGURATION_FILE_NAME=".ecrc"
  local DEPRECATED_CONFIGURATION_FILE_PATH
  DEPRECATED_CONFIGURATION_FILE_PATH="$(dirname "${EDITORCONFIG_LINTER_RULES}")/${DEPRECATED_CONFIGURATION_FILE_NAME}"
  if DeprecatedConfigurationFileExists "EDITORCONFIG" "${DEPRECATED_CONFIGURATION_FILE_NAME}" "$(basename "${EDITORCONFIG_LINTER_RULES}")"; then
    fatal "${DEPRECATED_CONFIGURATION_FILE_PATH} should be reported as existing"
  fi

  notice "${FUNCTION_NAME} PASS"
}

ValidateGitShaReferenceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_BEFORE_SHA_TEST=""

  if ValidateGitShaReference "${GITHUB_BEFORE_SHA_TEST}"; then
    fatal "ValidateGitShaReference should have failed for an empty string"
  fi

  GITHUB_BEFORE_SHA_TEST="null"
  if ValidateGitShaReference "${GITHUB_BEFORE_SHA_TEST}"; then
    fatal "ValidateGitShaReference should have failed for ${GITHUB_BEFORE_SHA_TEST}"
  fi

  GITHUB_BEFORE_SHA_TEST="0000000000000000000000000000000000000000"
  if ValidateGitShaReference "${GITHUB_BEFORE_SHA_TEST}"; then
    fatal "ValidateGitShaReference should have failed for ${GITHUB_BEFORE_SHA_TEST}"
  fi

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  initialize_git_repository_contents "${GITHUB_WORKSPACE}" 0 "false" "push" "false" "false" "false" "true"
  local GITHUB_BEFORE_SHA_TEST="${GIT_ROOT_COMMIT_SHA}"
  if ! ValidateGitShaReference "${GITHUB_BEFORE_SHA_TEST}"; then
    fatal "ValidateGitShaReference should have passed for ${GITHUB_BEFORE_SHA_TEST}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InitializeDefaultBranchTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RUN_LOCAL="true"
  local USE_FIND_ALGORITHM="true"
  local GITHUB_EVENT_FILE_PATH="test/data/github-event/github-event-push.json"

  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"
  initialize_git_repository_contents "${GITHUB_WORKSPACE}" 0 "false" "push" "false" "false" "false" "true"

  if ! InitializeDefaultBranch "${USE_FIND_ALGORITHM}" "${GITHUB_EVENT_FILE_PATH}" "${RUN_LOCAL}"; then
    fatal "InitializeDefaultBranch with USE_FIND_ALGORITHM (${USE_FIND_ALGORITHM}), GITHUB_EVENT_FILE_PATH (${GITHUB_EVENT_FILE_PATH}), and RUN_LOCAL (${RUN_LOCAL}) should have passed"
  fi

  USE_FIND_ALGORITHM="false"

  local EXPECTED_DEFAULT_BRANCH="${DEFAULT_BRANCH}"
  if ! InitializeDefaultBranch "${USE_FIND_ALGORITHM}" "${GITHUB_EVENT_FILE_PATH}" "${RUN_LOCAL}"; then
    fatal "InitializeDefaultBranch with USE_FIND_ALGORITHM (${USE_FIND_ALGORITHM}), GITHUB_EVENT_FILE_PATH (${GITHUB_EVENT_FILE_PATH}), and RUN_LOCAL (${RUN_LOCAL}) should have passed"
  fi
  if [[ "${DEFAULT_BRANCH}" != "${EXPECTED_DEFAULT_BRANCH}" ]]; then
    fatal "DEFAULT_BRANCH (${DEFAULT_BRANCH}) doesn't match the expected value: ${EXPECTED_DEFAULT_BRANCH}"
  fi

  RUN_LOCAL="false"

  if ! InitializeDefaultBranch "${USE_FIND_ALGORITHM}" "${GITHUB_EVENT_FILE_PATH}" "${RUN_LOCAL}"; then
    fatal "InitializeDefaultBranch with USE_FIND_ALGORITHM (${USE_FIND_ALGORITHM}), GITHUB_EVENT_FILE_PATH (${GITHUB_EVENT_FILE_PATH}), and RUN_LOCAL (${RUN_LOCAL}) should have passed"
  fi
  if [[ "${DEFAULT_BRANCH}" != "${EXPECTED_DEFAULT_BRANCH}" ]]; then
    fatal "DEFAULT_BRANCH (${DEFAULT_BRANCH}) doesn't match the expected value: ${EXPECTED_DEFAULT_BRANCH}"
  fi

  # Create a local repository to simulate a remote.
  # Create the simulated remote inside ${GITHUB_WORKSPACE} to benefit from automatic cleanup
  local SIMULATED_REMOTE_REPOSITORY_PATH="${GITHUB_WORKSPACE}/simulated-remote"
  mkdir "${SIMULATED_REMOTE_REPOSITORY_PATH}"
  git -C "${SIMULATED_REMOTE_REPOSITORY_PATH}" clone --bare "${GITHUB_WORKSPACE}" "${SIMULATED_REMOTE_REPOSITORY_PATH}.git"
  git -C "${GITHUB_WORKSPACE}" remote add origin "file://${SIMULATED_REMOTE_REPOSITORY_PATH}"
  git -C "${GITHUB_WORKSPACE}" push origin "${DEFAULT_BRANCH}"
  git_log_graph "${GITHUB_WORKSPACE}"
  git -C "${GITHUB_WORKSPACE}" switch --create "${NEW_BRANCH_NAME}"
  git -C "${GITHUB_WORKSPACE}" branch -D "${DEFAULT_BRANCH}"
  git_log_graph "${GITHUB_WORKSPACE}"

  EXPECTED_DEFAULT_BRANCH="origin/${DEFAULT_BRANCH}"

  if ! InitializeDefaultBranch "${USE_FIND_ALGORITHM}" "${GITHUB_EVENT_FILE_PATH}" "${RUN_LOCAL}"; then
    fatal "InitializeDefaultBranch with USE_FIND_ALGORITHM (${USE_FIND_ALGORITHM}), GITHUB_EVENT_FILE_PATH (${GITHUB_EVENT_FILE_PATH}), and RUN_LOCAL (${RUN_LOCAL}) should have passed"
  fi
  if [[ "${DEFAULT_BRANCH}" != "${EXPECTED_DEFAULT_BRANCH}" ]]; then
    fatal "DEFAULT_BRANCH (${DEFAULT_BRANCH}) doesn't match the expected value: ${EXPECTED_DEFAULT_BRANCH}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

InitializeDefaultBranchDefaultValueTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local RUN_LOCAL="true"
  local USE_FIND_ALGORITHM="false"

  local BACKUP_DEFAULT_BRANCH="${DEFAULT_BRANCH}"
  DEFAULT_BRANCH="master"
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"
  initialize_git_repository_contents "${GITHUB_WORKSPACE}" 0 "false" "push" "false" "false" "false" "true"

  local EXPECTED_DEFAULT_BRANCH="${DEFAULT_BRANCH}"
  unset DEFAULT_BRANCH

  if ! InitializeDefaultBranch "${USE_FIND_ALGORITHM}" "" "${RUN_LOCAL}"; then
    fatal "InitializeDefaultBranch with USE_FIND_ALGORITHM (${USE_FIND_ALGORITHM}) and RUN_LOCAL (${RUN_LOCAL}) should have passed"
  fi
  if [[ "${DEFAULT_BRANCH}" != "${EXPECTED_DEFAULT_BRANCH}" ]]; then
    fatal "DEFAULT_BRANCH (${DEFAULT_BRANCH}) doesn't match the expected value: ${EXPECTED_DEFAULT_BRANCH}"
  fi

  DEFAULT_BRANCH="${BACKUP_DEFAULT_BRANCH}"

  notice "${FUNCTION_NAME} PASS"
}

InitializeGitHubWorkspaceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  unset GITHUB_WORKSPACE

  local DEFAULT_WORKSPACE
  DEFAULT_WORKSPACE=
  if InitializeGitHubWorkspace "${DEFAULT_WORKSPACE}"; then
    fatal "InitializeGitHubWorkspace with an empty DEFAULT_WORKSPACE should have failed"
  fi

  DEFAULT_WORKSPACE="/non-existing"
  debug "DEFAULT_WORKSPACE: ${DEFAULT_WORKSPACE}"
  if InitializeGitHubWorkspace "${DEFAULT_WORKSPACE}"; then
    fatal "InitializeGitHubWorkspace with a non-existing DEFAULT_WORKSPACE should have failed"
  fi
  unset GITHUB_WORKSPACE

  DEFAULT_WORKSPACE="/tmp"
  debug "DEFAULT_WORKSPACE: ${DEFAULT_WORKSPACE}"
  if ! InitializeGitHubWorkspace "${DEFAULT_WORKSPACE}"; then
    fatal "InitializeGitHubWorkspace with an existing DEFAULT_WORKSPACE should have passed"
  fi

  local EXPECTED_GITHUB_WORKSPACE="${DEFAULT_WORKSPACE}"
  if [[ "${GITHUB_WORKSPACE}" != "${EXPECTED_GITHUB_WORKSPACE}" ]]; then
    fatal "GITHUB_WORKSPACE (${GITHUB_WORKSPACE}) doesn't match the expected value: ${EXPECTED_GITHUB_WORKSPACE}"
  fi

  local EXPECTED_WORKING_DIRECTORY="${DEFAULT_WORKSPACE}"
  if [[ "$(pwd)" != "${EXPECTED_WORKING_DIRECTORY}" ]]; then
    fatal "WORKING_DIRECTORY ($(pwd)) doesn't match the expected value: ${EXPECTED_WORKING_DIRECTORY}"
  fi
  unset GITHUB_WORKSPACE

  notice "${FUNCTION_NAME} PASS"
}

ValidateConflictingToolsTestCase() {
  local -n FIRST_VARIABLE_NAME="${1}"
  local -n SECOND_VARIABLE_NAME="${2}"

  FIRST_VARIABLE_NAME="true"
  SECOND_VARIABLE_NAME="true"
  if ValidateConflictingTools; then
    fatal "ValidateConflictingTools with ${1} (${FIRST_VARIABLE_NAME}) and ${2} (${SECOND_VARIABLE_NAME}) vars set to false should have failed validation"
  fi
  unset FIRST_VARIABLE_NAME
  unset SECOND_VARIABLE_NAME

  unset -n FIRST_VARIABLE_NAME
  unset -n SECOND_VARIABLE_NAME
}

ValidateConflictingToolsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"

  ValidateConflictingToolsTestCase "VALIDATE_PYTHON_BLACK" "VALIDATE_PYTHON_RUFF_FORMAT"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_CSS_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_GRAPHQL_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_GRAPHQL_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_HTML_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_JAVASCRIPT_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_JSON_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_JSONC_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_JSX_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_TYPESCRIPT_PRETTIER"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_FORMAT" "VALIDATE_VUE_PRETTIER"

  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_CSS"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_JAVASCRIPT_ES"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_JSON"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_JSONC"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_JSX"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_TSX"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_TYPESCRIPT_ES"
  ValidateConflictingToolsTestCase "VALIDATE_BIOME_LINT" "VALIDATE_VUE"

  local VALIDATE_PYTHON_BLACK="false"
  local VALIDATE_PYTHON_RUFF_FORMAT="false"
  if ! ValidateConflictingTools; then
    fatal "ValidateConflictingTools VALIDATE_PYTHON_BLACK (${VALIDATE_PYTHON_BLACK}) and VALIDATE_PYTHON_RUFF_FORMAT (${VALIDATE_PYTHON_RUFF_FORMAT}) vars set to false should have passed validation"
  fi
  unset VALIDATE_PYTHON_BLACK
  unset VALIDATE_PYTHON_RUFF_FORMAT

  if ! ValidateConflictingTools; then
    fatal "ValidateConflictingTools all VALIDATE_ vars not set should have passed validation"
  fi

  info "${FUNCTION_NAME} start"
  notice "${FUNCTION_NAME} PASS"
}

IsUnsignedIntegerTest
ValidateDeprecatedVariablesTest
ValidateGitHubUrlsTest
ValidateSuperLinterSummaryOutputPathTest
ValidateFindModeTest
ValidateAnsibleDirectoryTest
ValidateValidationVariablesTest
ValidationVariablesExportTest
ValidateCheckModeAndFixModeVariablesTest
CheckIfFixModeIsEnabledTest
ValidateCommitlintConfigurationTest
InitializeGitBeforeShaReferenceFastForwardPushTest
InitializeGitBeforeShaReferenceMergeCommitPullRequestTest
InitializeGitBeforeShaReferenceMergeCommitPullRequestTargetGroupTest
InitializeGitBeforeShaReferenceMergeCommitMergeGroupTest
InitializeGitBeforeShaReferenceMergeDefaultBranchInPullRequestBranchTest
ValidateGitShaReferenceTest
InitializeRootCommitShaTest
DeprecatedConfigurationFileExistsTest
InitializeDefaultBranchTest
InitializeDefaultBranchDefaultValueTest
InitializeGitHubWorkspaceTest
ValidateConflictingToolsTest
