#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

function InitGitRepositoryAndCommitFiles() {
  local REPOSITORY_PATH="${1}" && shift
  local FILES_TO_COMMIT="${1}" && shift
  local COMMIT_FILE_INITIAL_COMMIT="${1}"

  initialize_git_repository "${REPOSITORY_PATH}"

  if [[ "${COMMIT_FILE_INITIAL_COMMIT}" == "true" ]]; then
    debug "Adding a test file to the initial commit"
    touch "${REPOSITORY_PATH}/test-initial-commit.txt"
    git -C "${REPOSITORY_PATH}" add .
  fi
  git -C "${REPOSITORY_PATH}" commit --allow-empty -m "Initial commit"
  # shellcheck disable=SC2034
  GIT_ROOT_COMMIT_SHA="$(git -C "${REPOSITORY_PATH}" rev-parse HEAD)"
  debug "GIT_ROOT_COMMIT_SHA: ${GIT_ROOT_COMMIT_SHA}"

  if [[ "${FILES_TO_COMMIT}" -gt 0 ]]; then
    GITHUB_BEFORE_SHA=$(git -C "${REPOSITORY_PATH}" rev-parse HEAD)
    debug "GITHUB_BEFORE_SHA: ${GITHUB_BEFORE_SHA}"
  else
    debug "Unsetting GITHUB_BEFORE_SHA because if we only have the initial commit, there is no previous commit to compare to"
    unset GITHUB_BEFORE_SHA
  fi

  git -C "${REPOSITORY_PATH}" checkout -b test-branch

  for ((i = 1; i <= FILES_TO_COMMIT; i++)); do
    local TEST_FILE_PATH="${REPOSITORY_PATH}/test${i}.txt"
    touch "${TEST_FILE_PATH}"
    git -C "${REPOSITORY_PATH}" add .
    git -C "${REPOSITORY_PATH}" commit -m "Add ${TEST_FILE_PATH}"
  done

  GITHUB_SHA=$(git -C "${REPOSITORY_PATH}" rev-parse HEAD)
  debug "GITHUB_SHA: ${GITHUB_SHA}"
  git_log_graph "${REPOSITORY_PATH}"
}

function GenerateFileDiffOneFileTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"

  local FILES_TO_COMMIT="${FILES_TO_COMMIT:-1}"
  local COMMIT_FILE_INITIAL_COMMIT="${COMMIT_FILE_INITIAL_COMMIT:-"false"}"
  InitGitRepositoryAndCommitFiles "${GITHUB_WORKSPACE}" "${FILES_TO_COMMIT}" "${COMMIT_FILE_INITIAL_COMMIT}"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  RAW_FILE_ARRAY_SIZE=${#RAW_FILE_ARRAY[@]}
  if [ "${RAW_FILE_ARRAY_SIZE}" -ne 1 ]; then
    fatal "RAW_FILE_ARRAY does not have exactly one element: ${RAW_FILE_ARRAY_SIZE}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function GenerateFileDiffOneFilePushEventTest() {
  FILES_TO_COMMIT=1
  COMMIT_FILE_INITIAL_COMMIT="false"
  GenerateFileDiffOneFileTest "${FUNCNAME[0]}"
}

function GenerateFileDiffInitialCommitPushEventTest() {
  FILES_TO_COMMIT=0
  COMMIT_FILE_INITIAL_COMMIT="true"
  GITHUB_EVENT_NAME="push"
  GenerateFileDiffOneFileTest "${FUNCNAME[0]}"
  unset GITHUB_EVENT_NAME
}

function GenerateFileDiffTwoFilesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  local FILES_TO_COMMIT=2

  InitGitRepositoryAndCommitFiles "${GITHUB_WORKSPACE}" ${FILES_TO_COMMIT} "false"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  RAW_FILE_ARRAY_SIZE=${#RAW_FILE_ARRAY[@]}
  if [ "${RAW_FILE_ARRAY_SIZE}" -ne 2 ]; then
    fatal "RAW_FILE_ARRAY does not have exactly ${FILES_TO_COMMIT} elements: ${RAW_FILE_ARRAY_SIZE}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function GenerateFileDiffTwoFilesPushEventTest() {
  # shellcheck disable=SC2034
  local GITHUB_EVENT_NAME="push"
  GenerateFileDiffTwoFilesTest "${FUNCNAME[0]}"
}

function BuildFileArraysAnsibleGitHubWorkspaceTest() {
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

GenerateFileDiffOneFileTest
GenerateFileDiffOneFilePushEventTest
GenerateFileDiffTwoFilesTest
GenerateFileDiffTwoFilesPushEventTest
GenerateFileDiffInitialCommitPushEventTest

BuildFileArraysAnsibleGitHubWorkspaceTest
