#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

function RecognizeNoShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/noShebang_bad.sh"

  debug "Confirming ${FILE} has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeCommentIsNotShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/comment_bad.sh"

  debug "Confirming ${FILE} starting with a comment has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeIndentedShebangAsCommentTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/indentedShebang_bad.sh"

  debug "Confirming indented shebang in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeSecondLineShebangAsCommentTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/secondLineShebang_bad.sh"

  debug "Confirming shebang on second line in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/shebang_bad.sh"

  debug "Confirming ${FILE} has a shebang"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangWithBlankTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="${TEST_DETECT_FILES_SHEBANG_DIRECTORY}/shebangWithBlank_bad.sh"

  debug "Confirming shebang with blank in ${FILE} is recognized"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function IsAnsibleDirectoryTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  local FILE="${GITHUB_WORKSPACE}/ansible"
  mkdir -p "${FILE}"
  local ANSIBLE_DIRECTORY="/ansible"
  export ANSIBLE_DIRECTORY

  debug "Confirming that ${FILE} is an Ansible directory"

  if ! IsAnsibleDirectory "${FILE}"; then
    fatal "${FILE} is not considered to be an Ansible directory"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeNotSymbolicLink() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/symboliclinks/not_symbolic_link"

  debug "Confirming that ${FILE} is not a symbolic link"

  if ! IsNotSymbolicLink "${FILE}"; then
    fatal "${FILE} is a symbolic link"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeSymbolicLink() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/symboliclinks/symbolic_link"

  debug "Confirming that ${FILE} is a symbolic link"

  if IsNotSymbolicLink "${FILE}"; then
    fatal "${FILE} is not a symbolic link"
  fi

  notice "${FUNCTION_NAME} PASS"
}

DetectGitHubActionsWorkflowsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local VALIDATE_GITHUB_ACTIONS
  local VALIDATE_GITHUB_ACTIONS_ZIZMOR

  VALIDATE_GITHUB_ACTIONS="false"
  VALIDATE_GITHUB_ACTIONS_ZIZMOR=""
  if DetectGitHubActionsWorkflows ""; then
    fatal "${FUNCTION_NAME} should have returned a non-zero exit code when VALIDATE_GITHUB_ACTIONS is ${VALIDATE_GITHUB_ACTIONS}"
  fi

  VALIDATE_GITHUB_ACTIONS=""
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="false"
  if DetectGitHubActionsWorkflows ""; then
    fatal "${FUNCTION_NAME} should have returned a non-zero exit code when VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
  fi

  VALIDATE_GITHUB_ACTIONS="true"
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"
  if DetectGitHubActionsWorkflows ""; then
    fatal "${FUNCTION_NAME} should have failed when passing an empty path"
  fi

  VALIDATE_GITHUB_ACTIONS="true"
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"
  local GITHUB_ACTIONS_TEST_FILE_PATH
  GITHUB_ACTIONS_TEST_FILE_PATH="workspace/.github/workflows/test.yaml"
  if ! DetectGitHubActionsWorkflows "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  VALIDATE_GITHUB_ACTIONS="true"
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"
  GITHUB_ACTIONS_TEST_FILE_PATH="${TEST_CASE_FOLDER}/github_actions/test.yaml"
  if ! DetectGitHubActionsWorkflows "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  unset VALIDATE_GITHUB_ACTIONS
  unset VALIDATE_GITHUB_ACTIONS_ZIZMOR

  notice "${FUNCTION_NAME} PASS"
}

DetectDependabotTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local VALIDATE_GITHUB_ACTIONS_ZIZMOR
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="false"
  if DetectDependabot "test/file/path"; then
    fatal "${FUNCTION_NAME} should have returned a non-zero exit code when VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
  fi

  VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"

  local GITHUB_ACTIONS_TEST_FILE_PATH

  GITHUB_ACTIONS_TEST_FILE_PATH=".github/dependabot.yml"
  if ! DetectDependabot "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH=".github/dependabot.yaml"
  if ! DetectDependabot "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH="workspace/.github/dependabot.yml"
  if ! DetectDependabot "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH="workspace/.github/dependabot.yaml"
  if ! DetectDependabot "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  unset VALIDATE_GITHUB_ACTIONS_ZIZMOR

  notice "${FUNCTION_NAME} PASS"
}

DetectGitHubActionsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local VALIDATE_GITHUB_ACTIONS_ZIZMOR
  VALIDATE_GITHUB_ACTIONS_ZIZMOR="false"
  if DetectGitHubActions "test/file/path"; then
    fatal "${FUNCTION_NAME} should have returned a non-zero exit code when VALIDATE_GITHUB_ACTIONS_ZIZMOR is ${VALIDATE_GITHUB_ACTIONS_ZIZMOR}"
  fi

  VALIDATE_GITHUB_ACTIONS_ZIZMOR="true"

  local GITHUB_ACTIONS_TEST_FILE_PATH

  GITHUB_ACTIONS_TEST_FILE_PATH="action.yml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH="action.yaml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH=".github/action.yml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH=".github/action.yaml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH="workspace/.github/action.yml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  GITHUB_ACTIONS_TEST_FILE_PATH="workspace/.github/action.yaml"
  if ! DetectGitHubActions "${GITHUB_ACTIONS_TEST_FILE_PATH}"; then
    fatal "${FUNCTION_NAME} should have passed when processing ${GITHUB_ACTIONS_TEST_FILE_PATH}"
  fi

  unset VALIDATE_GITHUB_ACTIONS_ZIZMOR

  notice "${FUNCTION_NAME} PASS"
}

RecognizeNoShebangTest
RecognizeCommentIsNotShebangTest
RecognizeIndentedShebangAsCommentTest
RecognizeSecondLineShebangAsCommentTest
RecognizeShebangTest
RecognizeShebangWithBlankTest
RecognizeNotSymbolicLink
RecognizeSymbolicLink

IsAnsibleDirectoryTest

DetectGitHubActionsWorkflowsTest
DetectDependabotTest
DetectGitHubActionsTest
