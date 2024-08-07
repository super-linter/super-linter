#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

function AssertArraysElementsContentMatch() {
  local ARRAY_1_VARIABLE_NAME="${1}"
  local ARRAY_2_VARIABLE_NAME="${2}"
  local -n ARRAY_1="${ARRAY_1_VARIABLE_NAME}"
  local -n ARRAY_2="${ARRAY_2_VARIABLE_NAME}"
  if [[ "${ARRAY_1[*]}" == "${ARRAY_2[*]}" ]]; then
    debug "${ARRAY_1_VARIABLE_NAME} (${ARRAY_1[*]}) matches the expected value: ${ARRAY_2[*]}"
    RETURN_CODE=0
  else
    error "${ARRAY_1_VARIABLE_NAME} (${ARRAY_1[*]}) doesn't match the expected value: ${ARRAY_2[*]}"
    RETURN_CODE=1
  fi
  unset -n ARRAY_1
  unset -n ARRAY_2
  return ${RETURN_CODE}
}

function CheckUnexpectedGitChanges() {
  local GIT_REPOSITORY_PATH="${1}"
  # Check if there are unexpected changes in the working directory:
  # - Unstaged changes
  # - Changes that are staged but not committed
  # - Untracked files and directories
  if ! git -C "${GIT_REPOSITORY_PATH}" diff --exit-code --quiet ||
    ! git -C "${GIT_REPOSITORY_PATH}" diff --cached --exit-code --quiet ||
    ! git -C "${GIT_REPOSITORY_PATH}" ls-files --others --exclude-standard --directory; then
    echo "There are unexpected changes in the working directory of the ${GIT_REPOSITORY_PATH} Git repository."
    git -C "${GIT_REPOSITORY_PATH}" status
    return 1
  fi
}
