#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

GenerateFileDiffNoGitHubBeforeShaTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  if GenerateFileDiff; then
    fatal "GenerateFileDiff with an undefined GITHUB_BEFORE_SHA should have failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}
GenerateFileDiffNoGitHubBeforeShaTest

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

  initialize_git_repository_contents "${GITHUB_WORKSPACE}" "${COMMITS_TO_CREATE}" "true" "${GITHUB_EVENT_NAME}" "${TEST_FORCE_CREATE_MERGE_COMMIT}" "${SKIP_GITHUB_BEFORE_SHA_INIT}" "${COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE}" "true" "false"

  # shellcheck source=/dev/null
  source "lib/functions/buildFileList.sh"

  GenerateFileDiff

  debug "RAW_FILE_ARRAY contents:\n${RAW_FILE_ARRAY[*]}"

  # Subtract 1 to account for the initial commit
  local -i EXPECTED_RAW_FILE_ARRAY_SIZE
  local -i EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START
  local -a EXPECTED_RAW_FILE_ARRAY
  EXPECTED_RAW_FILE_ARRAY=()

  if [[ "${COMMITS_TO_CREATE}" -eq 0 ]]; then
    debug "This test considers the initial commit only"
    EXPECTED_RAW_FILE_ARRAY_SIZE=1
    EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START=0
  else
    EXPECTED_RAW_FILE_ARRAY_SIZE="${COMMITS_TO_CREATE}"
    EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START=1
  fi

  for ((i = 0; i < EXPECTED_RAW_FILE_ARRAY_SIZE; i++)); do
    EXPECTED_RAW_FILE_ARRAY+=("${GITHUB_WORKSPACE}/test$((i + EXPECTED_RAW_FILE_ARRAY_SCAN_INDEX_START)).json")
  done

  if [[ "${COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE}" == "true" ]]; then
    EXPECTED_RAW_FILE_ARRAY_SIZE=$((EXPECTED_RAW_FILE_ARRAY_SIZE + 1))
    EXPECTED_RAW_FILE_ARRAY=(
      "${GITHUB_WORKSPACE}/test-bad0.json"
      "${EXPECTED_RAW_FILE_ARRAY[@]}"
    )
  fi

  if ! AssertArraysElementsContentMatch "RAW_FILE_ARRAY" "EXPECTED_RAW_FILE_ARRAY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

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
  local VALIDATE_SHELL_SHELLHARDEN="true"
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

BuildFileListValidateAllCodeBaseTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${1:-${FUNCNAME[0]}}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_git_repository "${GITHUB_WORKSPACE}"

  local -a TEST_FILES
  # Keep this alphabetically sorted
  TEST_FILES=(
    "parentheses and spaces in the name (test).json"
    "spaces in the name.json"
    "test-file.json"
  )

  local -a EXPECTED_RAW_FILE_ARRAY
  EXPECTED_RAW_FILE_ARRAY=()

  local TEST_FILE_PATH

  for test_file in "${TEST_FILES[@]}"; do
    debug "Creating test file: ${test_file}"
    TEST_FILE_PATH="${GITHUB_WORKSPACE}/${test_file}"
    touch "${TEST_FILE_PATH}"

    EXPECTED_RAW_FILE_ARRAY+=(
      "${TEST_FILE_PATH}"
    )
  done
  EXPECTED_RAW_FILE_ARRAY+=(
    "${GITHUB_WORKSPACE}"
  )

  git -C "${GITHUB_WORKSPACE}" add .
  git -C "${GITHUB_WORKSPACE}" commit -m "init"
  GIT_ROOT_COMMIT_SHA="$(git -C "${GITHUB_WORKSPACE}" rev-parse HEAD)"
  debug "GIT_ROOT_COMMIT_SHA: ${GIT_ROOT_COMMIT_SHA}"

  git_log_graph "${GITHUB_WORKSPACE}"

  initialize_github_sha "${GITHUB_WORKSPACE}"

  # shellcheck disable=SC2034
  local USE_FIND_ALGORITHM="false"
  # shellcheck disable=SC2034
  local SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH="${GITHUB_WORKSPACE}"
  BuildFileList "true" "false"

  debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"

  if ! AssertArraysElementsContentMatch "RAW_FILE_ARRAY" "EXPECTED_RAW_FILE_ARRAY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}
BuildFileListValidateAllCodeBaseTest

CheckFileTypeTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_temp_directory_cleanup_traps "${GITHUB_WORKSPACE}"

  FILE_ARRAYS_DIRECTORY_PATH="$(mktemp -d)"
  export FILE_ARRAYS_DIRECTORY_PATH
  initialize_temp_directory_cleanup_traps "${FILE_ARRAYS_DIRECTORY_PATH}"

  # shellcheck disable=SC2034
  local SUPPRESS_FILE_TYPE_WARN="true"

  # Create test files
  local PYTHON_SCRIPT_PATH="${GITHUB_WORKSPACE}/python-script"
  echo "#!/usr/bin/env python3" >"${PYTHON_SCRIPT_PATH}"
  chmod +x "${PYTHON_SCRIPT_PATH}"

  local PERL_SCRIPT_PATH="${GITHUB_WORKSPACE}/perl-script"
  echo "#!/usr/bin/env perl" >"${PERL_SCRIPT_PATH}"
  chmod +x "${PERL_SCRIPT_PATH}"

  local RUBY_SCRIPT_PATH="${GITHUB_WORKSPACE}/ruby-script"
  echo "#!/usr/bin/env ruby" >"${RUBY_SCRIPT_PATH}"
  chmod +x "${RUBY_SCRIPT_PATH}"

  local POSIX_SHELL_SCRIPT_PATH="${GITHUB_WORKSPACE}/posix-shell-script"
  echo "#!/bin/sh" >"${POSIX_SHELL_SCRIPT_PATH}"
  chmod +x "${POSIX_SHELL_SCRIPT_PATH}"

  local BASH_SHELL_SCRIPT_PATH="${GITHUB_WORKSPACE}/bash-shell-script"
  echo "#!/bin/bash" >"${BASH_SHELL_SCRIPT_PATH}"
  chmod +x "${BASH_SHELL_SCRIPT_PATH}"

  local DASH_SHELL_SCRIPT_PATH="${GITHUB_WORKSPACE}/dash-shell-script"
  echo "#!/bin/dash" >"${DASH_SHELL_SCRIPT_PATH}"
  chmod +x "${DASH_SHELL_SCRIPT_PATH}"

  local KSH_SHELL_SCRIPT_PATH="${GITHUB_WORKSPACE}/ksh-shell-script"
  echo "#!/bin/ksh" >"${KSH_SHELL_SCRIPT_PATH}"
  chmod +x "${KSH_SHELL_SCRIPT_PATH}"

  local ENV_SH_SCRIPT_PATH="${GITHUB_WORKSPACE}/env-sh-script"
  echo "#!/usr/bin/env sh" >"${ENV_SH_SCRIPT_PATH}"
  chmod +x "${ENV_SH_SCRIPT_PATH}"

  local ENV_BASH_SCRIPT_PATH="${GITHUB_WORKSPACE}/env-bash-script"
  echo "#!/usr/bin/env bash" >"${ENV_BASH_SCRIPT_PATH}"
  chmod +x "${ENV_BASH_SCRIPT_PATH}"

  local ENV_DASH_SCRIPT_PATH="${GITHUB_WORKSPACE}/env-dash-script"
  echo "#!/usr/bin/env dash" >"${ENV_DASH_SCRIPT_PATH}"
  chmod +x "${ENV_DASH_SCRIPT_PATH}"

  local ENV_KSH_SCRIPT_PATH="${GITHUB_WORKSPACE}/env-ksh-script"
  echo "#!/usr/bin/env ksh" >"${ENV_KSH_SCRIPT_PATH}"
  chmod +x "${ENV_KSH_SCRIPT_PATH}"

  local UNKNOWN_FILE_PATH="${GITHUB_WORKSPACE}/unknown-file"
  echo "some text" >"${UNKNOWN_FILE_PATH}"

  local -a ALL_SCRIPTS=(
    "${PYTHON_SCRIPT_PATH}"
    "${PERL_SCRIPT_PATH}"
    "${RUBY_SCRIPT_PATH}"
    "${POSIX_SHELL_SCRIPT_PATH}"
    "${BASH_SHELL_SCRIPT_PATH}"
    "${DASH_SHELL_SCRIPT_PATH}"
    "${KSH_SHELL_SCRIPT_PATH}"
    "${ENV_SH_SCRIPT_PATH}"
    "${ENV_BASH_SCRIPT_PATH}"
    "${ENV_DASH_SCRIPT_PATH}"
    "${ENV_KSH_SCRIPT_PATH}"
  )

  # Run CheckFileType on created files
  for script_path in "${ALL_SCRIPTS[@]}"; do
    if ! CheckFileType "${script_path}"; then
      fatal "CheckFileType with ${script_path} should have passed"
    fi
  done

  if CheckFileType "${UNKNOWN_FILE_PATH}"; then
    fatal "CheckFileType with ${UNKNOWN_FILE_PATH} should have failed"
  fi

  # Assertions for Python script
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_BLACK" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_FLAKE8" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_ISORT" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_PYLINT" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_MYPY" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF" "${PYTHON_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF_FORMAT" "${PYTHON_SCRIPT_PATH}"

  # Assertions for Perl script
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PERL" "${PERL_SCRIPT_PATH}"

  # Assertions for Ruby script
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUBY" "${RUBY_SCRIPT_PATH}"

  # Assertions for all Shell scripts (direct and env variants)
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${POSIX_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${POSIX_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${POSIX_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${POSIX_SHELL_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${BASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${BASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${BASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${BASH_SHELL_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${DASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${DASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${DASH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${DASH_SHELL_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${KSH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${KSH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${KSH_SHELL_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${KSH_SHELL_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${ENV_SH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${ENV_SH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${ENV_SH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${ENV_SH_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${ENV_BASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${ENV_BASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${ENV_BASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${ENV_BASH_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${ENV_DASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${ENV_DASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${ENV_DASH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${ENV_DASH_SCRIPT_PATH}"

  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH" "${ENV_KSH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC" "${ENV_KSH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHELLHARDEN" "${ENV_KSH_SCRIPT_PATH}"
  AssertFileContains "${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT" "${ENV_KSH_SCRIPT_PATH}"

  unset SUPPRESS_FILE_TYPE_WARN
  notice "${FUNCTION_NAME} PASS"
}
CheckFileTypeTest
