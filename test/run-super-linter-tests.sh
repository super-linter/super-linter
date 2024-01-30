#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SUPER_LINTER_TEST_CONTAINER_URL="${1}"
TEST_FUNCTION_NAME="${2}"

COMMAND_TO_RUN=(docker run -e ACTIONS_RUNNER_DEBUG=true -e DEFAULT_BRANCH=main -e ENABLE_GITHUB_ACTIONS_GROUP_TITLE=true -e JSCPD_CONFIG_FILE=".jscpd-test-linters.json" -e RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES="default.json,hoge.json" -e RUN_LOCAL=true -e TEST_CASE_RUN=true -e TYPESCRIPT_STANDARD_TSCONFIG_FILE=".github/linters/tsconfig.json" -v "$(pwd):/tmp/lint")

run_test_cases_expect_failure() {
  COMMAND_TO_RUN+=(-e ANSIBLE_DIRECTORY="/test/linters/ansible/bad" -e CHECKOV_FILE_NAME=".checkov-test-linters-failure.yaml" -e FILTER_REGEX_INCLUDE=".*bad.*")
  EXPECTED_EXIT_CODE=1
}

run_test_cases_expect_success() {
  COMMAND_TO_RUN+=(-e ANSIBLE_DIRECTORY="/test/linters/ansible/good" -e CHECKOV_FILE_NAME=".checkov-test-linters-success.yaml" -e FILTER_REGEX_INCLUDE=".*good.*")
}

# Run the test setup function
${TEST_FUNCTION_NAME}

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

if [ ${SUPER_LINTER_EXIT_CODE} -ne ${EXPECTED_EXIT_CODE} ]; then
  echo "Super-linter exited with an unexpected code: ${SUPER_LINTER_EXIT_CODE}"
  exit 1
else
  echo "Super-linter exited with the expected code: ${SUPER_LINTER_EXIT_CODE}"
fi
