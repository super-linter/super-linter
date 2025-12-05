#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

GenerateFileDiffMergeDefaultBranchInPullRequestBranchTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  debug "Simulate the push of a merge commit to a non-default branch. The merge commit merges the default branch in the non-default branch"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  debug "Create the first commit in ${DEFAULT_BRANCH}"
  local INIT_COMMIT_FILE_NAME="init-commit.txt"
  touch "${GITHUB_WORKSPACE}/${INIT_COMMIT_FILE_NAME}"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "${INIT_COMMIT_FILE_NAME}"
  GIT_ROOT_COMMIT_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse HEAD)"
  debug "GIT_ROOT_COMMIT_SHA: ${GIT_ROOT_COMMIT_SHA}"

  debug "Switch to ${NEW_BRANCH_NAME} branch"
  git -C "${GITHUB_WORKSPACE}" switch --create "${NEW_BRANCH_NAME}"
  local FEATURE_BRANCH_FILE_NAME="feature-branch.txt"
  touch "${GITHUB_WORKSPACE}/${FEATURE_BRANCH_FILE_NAME}"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "${FEATURE_BRANCH_FILE_NAME}"
  GITHUB_BEFORE_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse HEAD)"
  debug "Setting GITHUB_BEFORE_SHA to ${GITHUB_BEFORE_SHA}"

  debug "Switch to ${DEFAULT_BRANCH} branch"
  git -C "${GITHUB_WORKSPACE}" switch "${DEFAULT_BRANCH}"
  local MAIN_BRANCH_NEW_FILE_NAME="main-new-file.txt"
  touch "${GITHUB_WORKSPACE}/${MAIN_BRANCH_NEW_FILE_NAME}"
  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "${MAIN_BRANCH_NEW_FILE_NAME}"

  debug "Switch to ${NEW_BRANCH_NAME} branch"
  git -C "${GITHUB_WORKSPACE}" switch "${NEW_BRANCH_NAME}"
  git -C "${GITHUB_WORKSPACE}" merge "${DEFAULT_BRANCH}"

  git_log_graph "${GITHUB_WORKSPACE}"

  initialize_github_sha "${GITHUB_WORKSPACE}"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"

  # shellcheck disable=SC2034
  local EXPECTED_RAW_FILE_ARRAY=(
    "${GITHUB_WORKSPACE}/${MAIN_BRANCH_NEW_FILE_NAME}"
  )

  if ! AssertArraysElementsContentMatch "RAW_FILE_ARRAY" "EXPECTED_RAW_FILE_ARRAY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}
GenerateFileDiffMergeDefaultBranchInPullRequestBranchTest

GenerateFileDiffTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  local COMMITS_TO_CREATE="${2}"
  local GITHUB_EVENT_NAME="${3}"
  local SKIP_GITHUB_BEFORE_SHA_INIT="${4}"
  local COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE="${5}"

  local TEST_FORCE_CREATE_MERGE_COMMIT
  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
    TEST_FORCE_CREATE_MERGE_COMMIT="true"
  else
    TEST_FORCE_CREATE_MERGE_COMMIT="false"
  fi

  initialize_git_repository_contents "${GITHUB_WORKSPACE}" "${COMMITS_TO_CREATE}" "true" "${GITHUB_EVENT_NAME}" "${TEST_FORCE_CREATE_MERGE_COMMIT}" "${SKIP_GITHUB_BEFORE_SHA_INIT}" "${COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE}" "true"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  RAW_FILE_ARRAY_SIZE=${#RAW_FILE_ARRAY[@]}

  debug "RAW_FILE_ARRAY contents:\n${RAW_FILE_ARRAY[*]}"

  # Subtract 1 to account for the initial commit
  local -i EXPECTED_RAW_FILE_ARRAY_SIZE
  local -i EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START
  if [[ "${COMMITS_TO_CREATE}" -eq 0 ]]; then
    debug "This test considers the initial commit only"
    EXPECTED_RAW_FILE_ARRAY_SIZE=1
    EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START=0
  else
    EXPECTED_RAW_FILE_ARRAY_SIZE="${COMMITS_TO_CREATE}"
    EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START=1
  fi

  if [ "${RAW_FILE_ARRAY_SIZE}" -ne "${EXPECTED_RAW_FILE_ARRAY_SIZE}" ]; then
    fatal "RAW_FILE_ARRAY_SIZE does not have exactly ${EXPECTED_RAW_FILE_ARRAY_SIZE} elements, but rather: ${RAW_FILE_ARRAY_SIZE}"
  else
    debug "RAW_FILE_ARRAY_SIZE (${RAW_FILE_ARRAY_SIZE}) matches the expected value"
  fi

  local EXPECTED_FILE_PATH
  for ((i = 0; i < RAW_FILE_ARRAY_SIZE; i++)); do
    EXPECTED_FILE_PATH="${GITHUB_WORKSPACE}/test$((i + EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START)).json"
    if [[ "${RAW_FILE_ARRAY[${i}]}" != "${EXPECTED_FILE_PATH}" ]]; then
      fatal "${RAW_FILE_ARRAY[${i}]} does not match the expected value: ${EXPECTED_FILE_PATH}"
    else
      debug "${RAW_FILE_ARRAY[${i}]} matches the expected value"
    fi
  done

  notice "${FUNCTION_NAME} PASS"
}

GenerateFileDiffOneFilePushEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 1 "push" "false" "false"
}
GenerateFileDiffOneFilePushEventTest

GenerateFileDiffTwoFilesPushEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 2 "push" "false" "false"
}
GenerateFileDiffTwoFilesPushEventTest

GenerateFileDiffInitialCommitPushEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 0 "push" "false" "false"
}
GenerateFileDiffInitialCommitPushEventTest

GenerateFileDiffPushEventNoGitHubBeforeShaTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 2 "push" "true" "false"
}
GenerateFileDiffPushEventNoGitHubBeforeShaTest

GenerateFileDiffOneFilePullRequestEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 1 "pull_request" "false" "false"
}
GenerateFileDiffOneFilePullRequestEventTest

GenerateFileDiffTwoFilesPullRequestEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 2 "pull_request" "false" "false"
}
GenerateFileDiffTwoFilesPullRequestEventTest

GenerateFileDiffInitialCommitPullRequestEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 0 "pull_request" "false" "false"
}
GenerateFileDiffTwoFilesPullRequestEventTest

GenerateFileDiffMergeDefaultBranchInPullRequestBranchPullRequestEventTest() {
  GenerateFileDiffTest "${FUNCNAME[0]}" 1 "pull_request" "false" "true"
}
GenerateFileDiffMergeDefaultBranchInPullRequestBranchPullRequestEventTest

BuildFileArraysTest() {
  local GITHUB_WORKSPACE="${1}" && shift
  # shellcheck disable=SC2034
  local FILTER_REGEX_INCLUDE="${1}" && shift
  # shellcheck disable=SC2034
  local FILTER_REGEX_EXCLUDE="${1}" && shift
  local FILE_ARRAYS_DIRECTORY_PATH="${1}" && shift
  # shellcheck disable=SC2034
  local STRIP_DEFAULT_WORKSPACE_FOR_REGEX="${1}" && shift

  initialize_temp_directory_cleanup_traps "${FILE_ARRAYS_DIRECTORY_PATH}"

  # shellcheck source=/dev/null
  source "lib/functions/detectFiles.sh"
  # shellcheck source=/dev/null
  source "lib/functions/validation.sh"

  # validation and detection functions depend on these values
  # shellcheck disable=SC2034
  local TEST_CASE_RUN=false
  # shellcheck disable=SC2034
  local IGNORE_GENERATED_FILES=false
  # shellcheck disable=SC2034
  local IGNORE_GITIGNORED_FILES=false
  # shellcheck disable=SC2034
  local VALIDATE_BASH="true"
  # shellcheck disable=SC2034
  local VALIDATE_BASH_EXEC="true"
  # shellcheck disable=SC2034
  local VALIDATE_CLOUDFORMATION="true"
  # shellcheck disable=SC2034
  local VALIDATE_GITHUB_ACTIONS="true"
  # shellcheck disable=SC2034
  local VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"
  # shellcheck disable=SC2034
  local VALIDATE_KUBERNETES_KUBECONFORM="true"
  # shellcheck disable=SC2034
  local VALIDATE_OPENAPI="true"
  # shellcheck disable=SC2034
  local VALIDATE_SHELL_SHFMT="true"

  local CHECKOV_LINTER_RULES
  # shellcheck disable=SC2034
  CHECKOV_LINTER_RULES="$(mktemp)"
  initialize_temp_directory_cleanup_traps "${CHECKOV_LINTER_RULES}"

  local -a RAW_FILE_ARRAY_TEST
  RAW_FILE_ARRAY_TEST=()
  if [ $# -gt 0 ]; then
    RAW_FILE_ARRAY_TEST+=("$@")
  fi

  ValidateAnsibleDirectory

  BuildFileArrays "${GITHUB_WORKSPACE}" "${RAW_FILE_ARRAY_TEST[@]}"
}

BuildFileArraysAnsibleGitHubWorkspaceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE="${DEFAULT_SUPER_LINTER_WORKSPACE}"
  # shellcheck disable=SC2034
  ANSIBLE_DIRECTORY="."

  local FILE_ARRAYS_DIRECTORY_PATH
  FILE_ARRAYS_DIRECTORY_PATH="$(mktemp -d)"

  BuildFileArraysTest "${GITHUB_WORKSPACE}" "" "" "${FILE_ARRAYS_DIRECTORY_PATH}" "false"

  local FILE_ARRAY_ANSIBLE_PATH="${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ANSIBLE"
  if [[ ! -e "${FILE_ARRAY_ANSIBLE_PATH}" ]]; then
    fatal "${FILE_ARRAY_ANSIBLE_PATH} doesn't exist"
  fi

  if ! AssertFileContains "${FILE_ARRAY_ANSIBLE_PATH}" "${ANSIBLE_DIRECTORY}"; then
    fatal "${FILE_ARRAY_ANSIBLE_PATH} should contain ${ANSIBLE_DIRECTORY}"
  fi

  unset ANSIBLE_DIRECTORY

  notice "${FUNCTION_NAME} PASS"
}
BuildFileArraysAnsibleGitHubWorkspaceTest

BuildFileArraysFilterRegexExcludeStartOfStringTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local FILTER_REGEX_EXCLUDE
  # Use a regex that looks for matches from the beginning of the string
  # shellcheck disable=SC2034
  FILTER_REGEX_EXCLUDE="^action\.yml$"

  local FILE_ARRAYS_DIRECTORY_PATH
  FILE_ARRAYS_DIRECTORY_PATH="$(mktemp -d)"

  local GITHUB_WORKSPACE="${DEFAULT_SUPER_LINTER_WORKSPACE}"

  local TEST_FILE_PATH="${GITHUB_WORKSPACE}/action.yml"
  local TEST_FILE_PATHS=()
  TEST_FILE_PATHS+=("${TEST_FILE_PATH}")
  TEST_FILE_PATHS+=("${GITHUB_WORKSPACE}/.github/dependabot.yml")

  BuildFileArraysTest "${GITHUB_WORKSPACE}" "" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAYS_DIRECTORY_PATH}" "${TEST_FILE_PATHS[@]}" "true"

  local FILE_ARRAY_YAML_PATH="${FILE_ARRAYS_DIRECTORY_PATH}/file-array-YAML"
  if [[ ! -e "${FILE_ARRAY_YAML_PATH}" ]]; then
    fatal "${FILE_ARRAY_YAML_PATH} doesn't exist"
  fi

  if AssertFileContains "${FILE_ARRAY_YAML_PATH}" "${TEST_FILE_PATH}"; then
    fatal "${FILE_ARRAY_YAML_PATH} should not contain ${TEST_FILE_PATH}"
  fi

  unset FILTER_REGEX_EXCLUDE

  notice "${FUNCTION_NAME} PASS"
}
BuildFileArraysFilterRegexExcludeStartOfStringTest
