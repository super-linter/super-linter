#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SUPER_LINTER_TEST_CONTAINER_URL="${1}"
TEST_FUNCTION_NAME="${2}"
SUPER_LINTER_CONTAINER_IMAGE_TYPE="${3}"
echo "Super-linter container image type: ${SUPER_LINTER_CONTAINER_IMAGE_TYPE}"

DEFAULT_BRANCH="main"

COMMAND_TO_RUN=(docker run -t -e DEFAULT_BRANCH="${DEFAULT_BRANCH}" -e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true)

LEFTOVERS_TO_CLEAN=()

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
  EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH="test/data/super-linter-summary/markdown/table/expected-summary-test-linters-expect-failure-${SUPER_LINTER_CONTAINER_IMAGE_TYPE}.md"
}

run_test_cases_expect_success() {
  configure_linters_for_test_cases
  COMMAND_TO_RUN+=(-e ANSIBLE_DIRECTORY="/test/linters/ansible/good" -e CHECKOV_FILE_NAME=".checkov-test-linters-success.yaml" -e FILTER_REGEX_INCLUDE=".*good.*")
  EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH="test/data/super-linter-summary/markdown/table/expected-summary-test-linters-expect-success-${SUPER_LINTER_CONTAINER_IMAGE_TYPE}.md"
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

initialize_git_repository_and_test_args() {
  local GIT_REPOSITORY_PATH="${1}"
  # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
  trap "rm -fr '${GIT_REPOSITORY_PATH}'" EXIT

  local GITHUB_EVENT_FILE_PATH="${2}"

  git -C "${GIT_REPOSITORY_PATH}" init --initial-branch="${DEFAULT_BRANCH}"
  git -C "${GIT_REPOSITORY_PATH}" config user.name "Super-linter Test"
  git -C "${GIT_REPOSITORY_PATH}" config user.email "super-linter-test@example.com"
  # Put an arbitrary JSON file in the repository to trigger some validation
  cp -v "${GITHUB_EVENT_FILE_PATH}" "${GIT_REPOSITORY_PATH}/"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: initial commit"

  RUN_LOCAL=false
  SUPER_LINTER_WORKSPACE="${GIT_REPOSITORY_PATH}"
  COMMAND_TO_RUN+=(-e GITHUB_WORKSPACE="/tmp/lint")
  COMMAND_TO_RUN+=(-e GITHUB_EVENT_NAME="push")
  COMMAND_TO_RUN+=(-e GITHUB_EVENT_PATH="/tmp/lint/$(basename "${GITHUB_EVENT_FILE_PATH}")")
  COMMAND_TO_RUN+=(-e MULTI_STATUS=false)
  COMMAND_TO_RUN+=(-e VALIDATE_ALL_CODEBASE=false)
  COMMAND_TO_RUN+=(-e VALIDATE_JSON=true)
}

run_test_case_git_initial_commit() {
  local GIT_REPOSITORY_PATH
  GIT_REPOSITORY_PATH="$(mktemp -d)"

  initialize_git_repository_and_test_args "${GIT_REPOSITORY_PATH}" "test/data/github-event/github-event-push.json"

  local TEST_GITHUB_SHA
  TEST_GITHUB_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
  COMMAND_TO_RUN+=(-e GITHUB_SHA="${TEST_GITHUB_SHA}")
}

run_test_case_merge_commit_push() {
  local GIT_REPOSITORY_PATH
  GIT_REPOSITORY_PATH="$(mktemp -d)"

  initialize_git_repository_and_test_args "${GIT_REPOSITORY_PATH}" "test/data/github-event/github-event-push-merge-commit.json"

  local NEW_BRANCH_NAME="branch-1"
  git -C "${GIT_REPOSITORY_PATH}" switch --create "${NEW_BRANCH_NAME}"
  cp -v "test/data/github-event/github-event-push-merge-commit.json" "${GIT_REPOSITORY_PATH}/new-file-1.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 1"
  cp -v "test/data/github-event/github-event-push-merge-commit.json" "${GIT_REPOSITORY_PATH}/new-file-2.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 2"
  cp -v "test/data/github-event/github-event-push-merge-commit.json" "${GIT_REPOSITORY_PATH}/new-file-3.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 3"
  git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"
  # Force the creation of a merge commit
  git -C "${GIT_REPOSITORY_PATH}" merge \
    -m "Merge commit" \
    --no-ff \
    "${NEW_BRANCH_NAME}"
  git -C "${GIT_REPOSITORY_PATH}" branch -d "${NEW_BRANCH_NAME}"

  git -C "${GIT_REPOSITORY_PATH}" log --all --graph --abbrev-commit --decorate --format=oneline

  local TEST_GITHUB_SHA
  TEST_GITHUB_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
  COMMAND_TO_RUN+=(-e GITHUB_SHA="${TEST_GITHUB_SHA}")
}

run_test_case_use_find_and_ignore_gitignored_files() {
  ignore_test_cases
  COMMAND_TO_RUN+=(-e IGNORE_GITIGNORED_FILES=true)
  COMMAND_TO_RUN+=(-e USE_FIND_ALGORITHM=true)
}

run_test_cases_save_super_linter_output() {
  run_test_cases_expect_success
  SAVE_SUPER_LINTER_OUTPUT="true"
}

run_test_cases_save_super_linter_output_custom_path() {
  run_test_cases_save_super_linter_output
  SUPER_LINTER_OUTPUT_DIRECTORY_NAME="custom-super-linter-output-directory-name"
}

run_test_case_custom_summary() {
  run_test_cases_expect_success
  SUPER_LINTER_SUMMARY_FILE_NAME="custom-github-step-summary.md"
}

# Run the test setup function
${TEST_FUNCTION_NAME}

CREATE_LOG_FILE="${CREATE_LOG_FILE:-false}"
SAVE_SUPER_LINTER_OUTPUT="${SAVE_SUPER_LINTER_OUTPUT:-false}"

if [ -n "${SUPER_LINTER_OUTPUT_DIRECTORY_NAME:-}" ]; then
  COMMAND_TO_RUN+=(-e SUPER_LINTER_OUTPUT_DIRECTORY_NAME="${SUPER_LINTER_OUTPUT_DIRECTORY_NAME}")
fi
SUPER_LINTER_OUTPUT_DIRECTORY_NAME="${SUPER_LINTER_OUTPUT_DIRECTORY_NAME:-"super-linter-output"}"
SUPER_LINTER_MAIN_OUTPUT_PATH="$(pwd)/${SUPER_LINTER_OUTPUT_DIRECTORY_NAME}"
echo "Super-linter main output path: ${SUPER_LINTER_MAIN_OUTPUT_PATH}"
SUPER_LINTER_OUTPUT_PATH="${SUPER_LINTER_MAIN_OUTPUT_PATH}/super-linter"
echo "Super-linter output path: ${SUPER_LINTER_OUTPUT_PATH}"

COMMAND_TO_RUN+=(-e CREATE_LOG_FILE="${CREATE_LOG_FILE}")
COMMAND_TO_RUN+=(-e LOG_LEVEL="${LOG_LEVEL:-"DEBUG"}")
COMMAND_TO_RUN+=(-e RUN_LOCAL="${RUN_LOCAL:-true}")
COMMAND_TO_RUN+=(-e SAVE_SUPER_LINTER_OUTPUT="${SAVE_SUPER_LINTER_OUTPUT}")
COMMAND_TO_RUN+=(-v "${SUPER_LINTER_WORKSPACE:-$(pwd)}":"/tmp/lint")

SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH="$(pwd)/github-step-summary.md"
# We can't put this inside SUPER_LINTER_MAIN_OUTPUT_PATH because it doesn't exist
# before Super-linter creates it, and we want to verify that as well.
echo "SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH: ${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}"

if [ -n "${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH:-}" ]; then
  echo "Expected Super-linter step summary file path: ${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH}"
  ENABLE_GITHUB_ACTIONS_STEP_SUMMARY="true"
  SAVE_SUPER_LINTER_SUMMARY="true"

  COMMAND_TO_RUN+=(-e GITHUB_STEP_SUMMARY="${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}")
  COMMAND_TO_RUN+=(-v "${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}":"${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}")
fi

ENABLE_GITHUB_ACTIONS_STEP_SUMMARY="${ENABLE_GITHUB_ACTIONS_STEP_SUMMARY:-"false"}"
COMMAND_TO_RUN+=(-e ENABLE_GITHUB_ACTIONS_STEP_SUMMARY="${ENABLE_GITHUB_ACTIONS_STEP_SUMMARY}")
COMMAND_TO_RUN+=(-e SAVE_SUPER_LINTER_SUMMARY="${SAVE_SUPER_LINTER_SUMMARY:-"false"}")

if [ -n "${SUPER_LINTER_SUMMARY_FILE_NAME:-}" ]; then
  COMMAND_TO_RUN+=(-e SUPER_LINTER_SUMMARY_FILE_NAME="${SUPER_LINTER_SUMMARY_FILE_NAME}")
fi
SUPER_LINTER_SUMMARY_FILE_NAME="${SUPER_LINTER_SUMMARY_FILE_NAME:-"super-linter-summary.md"}"
echo "SUPER_LINTER_SUMMARY_FILE_NAME: ${SUPER_LINTER_SUMMARY_FILE_NAME}"

SUPER_LINTER_SUMMARY_FILE_PATH="${SUPER_LINTER_MAIN_OUTPUT_PATH}/${SUPER_LINTER_SUMMARY_FILE_NAME}"
echo "Super-linter summary output path: ${SUPER_LINTER_SUMMARY_FILE_PATH}"

LOG_FILE_PATH="$(pwd)/super-linter.log"

COMMAND_TO_RUN+=("${SUPER_LINTER_TEST_CONTAINER_URL}")

declare -i EXPECTED_EXIT_CODE
EXPECTED_EXIT_CODE=${EXPECTED_EXIT_CODE:-0}

echo "Cleaning eventual leftovers before running tests: ${LEFTOVERS_TO_CLEAN[*]}"
LEFTOVERS_TO_CLEAN+=("${LOG_FILE_PATH}")
LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}")
LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_MAIN_OUTPUT_PATH}")
LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_SUMMARY_FILE_PATH}")
sudo rm -rfv "${LEFTOVERS_TO_CLEAN[@]}"

if [[ "${ENABLE_GITHUB_ACTIONS_STEP_SUMMARY}" == "true" ]]; then
  echo "Creating GitHub Actions step summary file: ${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}"
  touch "${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}"
fi

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
  if [ ! -e "${LOG_FILE_PATH}" ]; then
    echo "Log file was requested but it's not available at ${LOG_FILE_PATH}"
    exit 1
  else
    sudo chown -R "$(id -u)":"$(id -g)" "${LOG_FILE_PATH}"
    echo "Log file contents:"
    cat "${LOG_FILE_PATH}"
  fi
else
  echo "Log file was not requested. CREATE_LOG_FILE: ${CREATE_LOG_FILE}"
fi

if [[ "${SAVE_SUPER_LINTER_OUTPUT}" == true ]]; then
  if [ ! -d "${SUPER_LINTER_OUTPUT_PATH}" ]; then
    echo "Super-linter output was requested but it's not available at ${SUPER_LINTER_OUTPUT_PATH}"
    exit 1
  else
    sudo chown -R "$(id -u)":"$(id -g)" "${SUPER_LINTER_OUTPUT_PATH}"
    echo "Super-linter output path (${SUPER_LINTER_OUTPUT_PATH}) contents:"
    ls -alhR "${SUPER_LINTER_OUTPUT_PATH}"
  fi
else
  echo "Super-linter output was not requested. SAVE_SUPER_LINTER_OUTPUT: ${SAVE_SUPER_LINTER_OUTPUT}"

  if [ -e "${SUPER_LINTER_OUTPUT_PATH}" ]; then
    echo "Super-linter output was not requested but it's available at ${SUPER_LINTER_OUTPUT_PATH}"
    exit 1
  fi
fi

if [ -n "${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH:-}" ]; then
  # Remove eventual HTML comments from the expected file because we use them to disable certain linter rules
  if ! diff "${SUPER_LINTER_SUMMARY_FILE_PATH}" <(grep -vE '^\s*<!--' "${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH}"); then
    echo "Super-linter summary (${SUPER_LINTER_SUMMARY_FILE_PATH}) contents don't match with the expected contents (${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH})"
    exit 1
  else
    echo "Super-linter summary (${SUPER_LINTER_SUMMARY_FILE_PATH}) contents match with the expected contents (${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH})"
  fi

  if ! diff "${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}" <(grep -vE '^\s*<!--' "${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH}"); then
    echo "Super-linter GitHub step summary (${SUPER_LINTER_SUMMARY_FILE_PATH}) contents don't match with the expected contents (${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH})"
    exit 1
  else
    echo "Super-linter GitHub step summary (${SUPER_LINTER_SUMMARY_FILE_PATH}) contents match with the expected contents (${EXPECTED_SUPER_LINTER_SUMMARY_FILE_PATH})"
  fi
else
  echo "Super-linter summary output was not requested."

  if [ -e "${SUPER_LINTER_SUMMARY_FILE_PATH}" ]; then
    echo "Super-linter summary was not requested but it's available at ${SUPER_LINTER_SUMMARY_FILE_PATH}"
    exit 1
  fi

  if [ -e "${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}" ]; then
    echo "Super-linter GitHub step summary was not requested but it's available at ${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}"
    exit 1
  fi
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
