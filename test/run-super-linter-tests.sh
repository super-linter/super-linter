#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SUPER_LINTER_TEST_CONTAINER_URL="${1}"
TEST_FUNCTION_NAME="${2}"

DEFAULT_BRANCH="main"

COMMAND_TO_RUN=(docker run -t -e DEFAULT_BRANCH="${DEFAULT_BRANCH}" -e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true)

ignore_test_cases() {
  COMMAND_TO_RUN+=(-e FILTER_REGEX_EXCLUDE=".*(/test/linters/|CHANGELOG.md).*")
}

configure_linters_for_test_cases() {
  COMMAND_TO_RUN+=(-e TEST_CASE_RUN=true -e JSCPD_CONFIG_FILE=".jscpd-test-linters.json" -e RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES="default.json,hoge.json" -e TYPESCRIPT_STANDARD_TSCONFIG_FILE=".github/linters/tsconfig.json")
}

run_test_cases_expect_failure() {
  configure_linters_for_test_cases
  COMMAND_TO_RUN+=(-e ANSIBLE_DIRECTORY="/test/linters/ansible/bad" -e CHECKOV_FILE_NAME=".checkov-test-linters-failure.yaml" -e FILTER_REGEX_INCLUDE=".*bad.*")
  EXPECTED_EXIT_CODE=1
}

run_test_cases_expect_success() {
  configure_linters_for_test_cases
  COMMAND_TO_RUN+=(-e ANSIBLE_DIRECTORY="/test/linters/ansible/good" -e CHECKOV_FILE_NAME=".checkov-test-linters-success.yaml" -e FILTER_REGEX_INCLUDE=".*good.*")
}

run_test_cases_log_level() {
  run_test_cases_expect_success
  CREATE_LOG_FILE="true"
  LOG_LEVEL="NOTICE"
}

run_test_cases_expect_failure_notice_log() {
  run_test_cases_expect_failure
  LOG_LEVEL="NOTICE"
}

run_test_cases_non_default_home() {
  run_test_cases_expect_success
  COMMAND_TO_RUN+=(-e HOME=/tmp)
}

run_test_case_bash_exec_library_expect_failure() {
  run_test_cases_expect_failure
  COMMAND_TO_RUN+=(-e BASH_EXEC_IGNORE_LIBRARIES="true")
}

run_test_case_bash_exec_library_expect_success() {
  run_test_cases_expect_success
  COMMAND_TO_RUN+=(-e BASH_EXEC_IGNORE_LIBRARIES="true")
}

run_test_case_git_initial_commit() {
  local GIT_REPOSITORY_PATH
  GIT_REPOSITORY_PATH="$(mktemp -d)"
  # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
  trap "rm -fr '${GIT_REPOSITORY_PATH}'" EXIT

  git -C "${GIT_REPOSITORY_PATH}" init --initial-branch="${DEFAULT_BRANCH}"
  git -C "${GIT_REPOSITORY_PATH}" config user.name "Super-linter Test"
  git -C "${GIT_REPOSITORY_PATH}" config user.email "super-linter-test@example.com"
  cp -v test/data/github-event/github-event-push.json "${GIT_REPOSITORY_PATH}/"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: initial commit"

  local TEST_GITHUB_SHA
  TEST_GITHUB_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"

  RUN_LOCAL=false
  SUPER_LINTER_WORKSPACE="${GIT_REPOSITORY_PATH}"
  COMMAND_TO_RUN+=(-e GITHUB_WORKSPACE="/tmp/lint")
  COMMAND_TO_RUN+=(-e GITHUB_EVENT_NAME="push")
  COMMAND_TO_RUN+=(-e GITHUB_EVENT_PATH="/tmp/lint/github-event-push.json")
  COMMAND_TO_RUN+=(-e GITHUB_SHA="${TEST_GITHUB_SHA}")
  COMMAND_TO_RUN+=(-e MULTI_STATUS=false)
  COMMAND_TO_RUN+=(-e VALIDATE_ALL_CODEBASE=false)
  COMMAND_TO_RUN+=(-e VALIDATE_JSON=true)
}

run_test_case_use_find_and_ignore_gitignored_files() {
  ignore_test_cases
  COMMAND_TO_RUN+=(-e IGNORE_GITIGNORED_FILES=true)
  COMMAND_TO_RUN+=(-e USE_FIND_ALGORITHM=true)
}

# Run the test setup function
${TEST_FUNCTION_NAME}

CREATE_LOG_FILE="${CREATE_LOG_FILE:-false}"

COMMAND_TO_RUN+=(-e CREATE_LOG_FILE="${CREATE_LOG_FILE}")
COMMAND_TO_RUN+=(-e LOG_LEVEL="${LOG_LEVEL:-"DEBUG"}")
COMMAND_TO_RUN+=(-e RUN_LOCAL="${RUN_LOCAL:-true}")
COMMAND_TO_RUN+=(-v "${SUPER_LINTER_WORKSPACE:-$(pwd)}:/tmp/lint")
COMMAND_TO_RUN+=("${SUPER_LINTER_TEST_CONTAINER_URL}")

declare -i EXPECTED_EXIT_CODE
EXPECTED_EXIT_CODE=${EXPECTED_EXIT_CODE:-0}

if [ ${EXPECTED_EXIT_CODE} -ne 0 ]; then
  echo "Disable failures on error because the expected exit code is ${EXPECTED_EXIT_CODE}"
  set +o errexit
fi

echo "Command to run: ${COMMAND_TO_RUN[*]}"

"${COMMAND_TO_RUN[@]}"
SUPER_LINTER_EXIT_CODE=$?
# Enable the errexit option in case we disabled it
set -o errexit

echo "Super-linter exit code: ${SUPER_LINTER_EXIT_CODE}"

if [[ "${CREATE_LOG_FILE}" == true ]]; then
  LOG_FILE_PATH="$(pwd)/super-linter.log"
  if [ ! -e "${LOG_FILE_PATH}" ]; then
    echo "Log file was requested but it's not available"
    exit 1
  else
    sudo chown -R "$(id -u)":"$(id -g)" "${LOG_FILE_PATH}"
    echo "Log file contents:"
    cat "${LOG_FILE_PATH}"
  fi
else
  echo "Log file was not requested. CREATE_LOG_FILE: ${CREATE_LOG_FILE}"
fi

if [ ${SUPER_LINTER_EXIT_CODE} -ne ${EXPECTED_EXIT_CODE} ]; then
  echo "Super-linter exited with an unexpected code: ${SUPER_LINTER_EXIT_CODE}"
  exit 1
else
  echo "Super-linter exited with the expected code: ${SUPER_LINTER_EXIT_CODE}"
fi

# Check if super-linter leaves leftovers behind
declare -a TEMP_ITEMS_TO_CLEAN
TEMP_ITEMS_TO_CLEAN=()
TEMP_ITEMS_TO_CLEAN+=("$(pwd)/.lintr")
TEMP_ITEMS_TO_CLEAN+=("$(pwd)/.mypy_cache")
TEMP_ITEMS_TO_CLEAN+=("$(pwd)/.ruff_cache")
TEMP_ITEMS_TO_CLEAN+=("$(pwd)/logback.log")

for item in "${TEMP_ITEMS_TO_CLEAN[@]}"; do
  echo "Check if ${item} exists"
  if [[ -e "${item}" ]]; then
    echo "Error: ${item} exists and it should have been deleted"
    exit 1
  else
    echo "${item} does not exist as expected"
  fi
done
