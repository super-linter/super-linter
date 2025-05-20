#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

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

  initialize_git_repository_contents "${GITHUB_WORKSPACE}" "${COMMITS_TO_CREATE}" "true" "${GITHUB_EVENT_NAME}" "${TEST_FORCE_CREATE_MERGE_COMMIT}" "${SKIP_GITHUB_BEFORE_SHA_INIT}" "${COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE}"

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

BuildFileArraysAnsibleGitHubWorkspaceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck source=/dev/null
  source /action/lib/functions/detectFiles.sh
  # shellcheck source=/dev/null
  source /action/lib/functions/validation.sh

  # shellcheck disable=SC2034
  local FILTER_REGEX_INCLUDE=""
  # shellcheck disable=SC2034
  local FILTER_REGEX_EXCLUDE=""
  # shellcheck disable=SC2034
  local TEST_CASE_RUN=false
  # shellcheck disable=SC2034
  local IGNORE_GENERATED_FILES=false
  local FILE_ARRAYS_DIRECTORY_PATH="/tmp/super-linter-output/super-linter-file-arrays"
  mkdir -p "${FILE_ARRAYS_DIRECTORY_PATH}"

  # shellcheck disable=SC2034
  CHECKOV_LINTER_RULES="$(mktemp)"

  GITHUB_WORKSPACE="/tmp/lint"
  # shellcheck disable=SC2034
  ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}"

  BuildFileArrays "${GITHUB_WORKSPACE}"

  local FILE_ARRAY_ANSIBLE_PATH="${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ANSIBLE"
  if [[ ! -e "${FILE_ARRAY_ANSIBLE_PATH}" ]]; then
    fatal "${FILE_ARRAY_ANSIBLE_PATH} doesn't exist"
  fi

  if ! grep -qxF "${ANSIBLE_DIRECTORY}" "${FILE_ARRAY_ANSIBLE_PATH}"; then
    fatal "${FILE_ARRAY_ANSIBLE_PATH} doesn't contain ${ANSIBLE_DIRECTORY}"
  fi

  notice "${FUNCTION_NAME} PASS"
}
BuildFileArraysAnsibleGitHubWorkspaceTest
