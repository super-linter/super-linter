#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
CREATE_LOG_FILE=false
# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"
# shellcheck disable=SC2034
LOG_DEBUG="true"
# shellcheck disable=SC2034
LOG_VERBOSE="true"
# shellcheck disable=SC2034
LOG_NOTICE="true"
# shellcheck disable=SC2034
LOG_WARN="true"
# shellcheck disable=SC2034
LOG_ERROR="true"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck disable=SC2034
DEFAULT_BRANCH=main

git config --global init.defaultBranch "${DEFAULT_BRANCH}"
git config --global user.email "super-linter@example.com"
git config --global user.name "Super-linter"

function InitGitRepositoryAndCommitFiles() {
  local REPOSITORY_PATH="${1}" && shift
  local FILES_TO_COMMIT="${1}"

  git -C "${REPOSITORY_PATH}" init
  git -C "${REPOSITORY_PATH}" commit --allow-empty -m "Initial commit"
  GITHUB_BEFORE_SHA=$(git -C "${REPOSITORY_PATH}" rev-parse HEAD)
  debug "GITHUB_BEFORE_SHA: ${GITHUB_BEFORE_SHA}"

  git -C "${REPOSITORY_PATH}" checkout -b test-branch

  for ((i = 1; i <= FILES_TO_COMMIT; i++)); do
    local TEST_FILE_PATH="${REPOSITORY_PATH}/test${i}.txt"
    touch "${TEST_FILE_PATH}"
    git -C "${REPOSITORY_PATH}" add .
    git -C "${REPOSITORY_PATH}" commit -m "Add ${TEST_FILE_PATH}"
  done

  GITHUB_SHA=$(git -C "${REPOSITORY_PATH}" rev-parse HEAD)
  debug "GITHUB_SHA: ${GITHUB_SHA}"
  git -C "${REPOSITORY_PATH}" log --oneline "${DEFAULT_BRANCH}...${GITHUB_SHA}"
}

function GenerateFileDiffOneFileTest() {
  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  echo "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"

  InitGitRepositoryAndCommitFiles "${GITHUB_WORKSPACE}" 1

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  RAW_FILE_ARRAY_SIZE=${#RAW_FILE_ARRAY[@]}
  if [ "${RAW_FILE_ARRAY_SIZE}" -ne 1 ]; then
    fatal "RAW_FILE_ARRAY does not have exactly one element: ${RAW_FILE_ARRAY_SIZE}"
  fi

  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  notice "${FUNCTION_NAME} PASS"
}

function GenerateFileDiffOneFilePushEventTest() {
  # shellcheck disable=SC2034
  local GITHUB_EVENT_NAME="push"
  GenerateFileDiffOneFileTest "${FUNCNAME[0]}"
}

function GenerateFileDiffTwoFilesTest() {
  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  debug "GITHUB_WORKSPACE: ${GITHUB_WORKSPACE}"
  local FILES_TO_COMMIT=2

  InitGitRepositoryAndCommitFiles "${GITHUB_WORKSPACE}" ${FILES_TO_COMMIT}

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  RAW_FILE_ARRAY_SIZE=${#RAW_FILE_ARRAY[@]}
  if [ "${RAW_FILE_ARRAY_SIZE}" -ne 2 ]; then
    fatal "RAW_FILE_ARRAY does not have exactly ${FILES_TO_COMMIT} elements: ${RAW_FILE_ARRAY_SIZE}"
  fi

  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  notice "${FUNCTION_NAME} PASS"
}

function GenerateFileDiffTwoFilesPushEventTest() {
  # shellcheck disable=SC2034
  local GITHUB_EVENT_NAME="push"
  GenerateFileDiffTwoFilesTest "${FUNCNAME[0]}"
}

GenerateFileDiffOneFileTest
GenerateFileDiffOneFilePushEventTest
GenerateFileDiffTwoFilesTest
GenerateFileDiffTwoFilesPushEventTest
