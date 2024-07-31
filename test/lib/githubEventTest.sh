#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/functions/validation.sh"
# shellcheck source=/dev/null
source "lib/functions/githubEvent.sh"

function GetGithubPushEventCommitCountTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_EVENT_COMMIT_COUNT
  GITHUB_EVENT_COMMIT_COUNT=$(GetGithubPushEventCommitCount "test/data/github-event/github-event-push.json")

  debug "GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"

  if [ "${GITHUB_EVENT_COMMIT_COUNT}" -ne 1 ]; then
    fatal "GITHUB_EVENT_COMMIT_COUNT is not equal to 1: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGithubPushEventCommitCountTest

function GetGithubRepositoryDefaultBranchTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_REPOSITORY_DEFAULT_BRANCH
  GITHUB_REPOSITORY_DEFAULT_BRANCH=$(GetGithubRepositoryDefaultBranch "test/data/github-event/github-event-push.json")

  debug "GITHUB_REPOSITORY_DEFAULT_BRANCH: ${GITHUB_REPOSITORY_DEFAULT_BRANCH}"

  local EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH
  EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH="main"

  if [ "${GITHUB_REPOSITORY_DEFAULT_BRANCH}" != "${EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH}" ]; then
    fatal "GITHUB_REPOSITORY_DEFAULT_BRANCH (${GITHUB_REPOSITORY_DEFAULT_BRANCH}) is not equal to: ${EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGithubRepositoryDefaultBranchTest
