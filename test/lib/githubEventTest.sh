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

function GetGithubPullRequestEventCommitCountTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_EVENT_COMMIT_COUNT
  set +o errexit
  GITHUB_EVENT_COMMIT_COUNT=$(GetGithubPullRequestEventCommitCount "test/data/github-event/github-event-pull-request-multiple-commits.json")
  RET_CODE=$?
  set -o errexit
  if [[ "${RET_CODE}" -gt 0 ]]; then
    fatal "Failed to get commit count from GitHub pull request event. Output: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  debug "GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"

  if [ "${GITHUB_EVENT_COMMIT_COUNT}" -ne 3 ]; then
    fatal "GITHUB_EVENT_COMMIT_COUNT is not equal to 3: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGithubPullRequestEventCommitCountTest

function GetGithubRepositoryDefaultBranchTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_REPOSITORY_DEFAULT_BRANCH
  if ! GITHUB_REPOSITORY_DEFAULT_BRANCH=$(GetGithubRepositoryDefaultBranch "test/data/github-event/github-event-push.json"); then
    fatal "Error while setting GITHUB_REPOSITORY_DEFAULT_BRANCH"
  fi

  debug "GITHUB_REPOSITORY_DEFAULT_BRANCH: ${GITHUB_REPOSITORY_DEFAULT_BRANCH}"

  local EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH
  EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH="main"

  if [ "${GITHUB_REPOSITORY_DEFAULT_BRANCH}" != "${EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH}" ]; then
    fatal "GITHUB_REPOSITORY_DEFAULT_BRANCH (${GITHUB_REPOSITORY_DEFAULT_BRANCH}) is not equal to: ${EXPECTED_GITHUB_REPOSITORY_DEFAULT_BRANCH}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGithubRepositoryDefaultBranchTest

function GetPullRequestHeadShaTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_PULL_REQUEST_HEAD_SHA
  GITHUB_PULL_REQUEST_HEAD_SHA=$(GetPullRequestHeadSha "test/data/github-event/github-event-pull-request-multiple-commits.json")

  debug "GITHUB_PULL_REQUEST_HEAD_SHA: ${GITHUB_PULL_REQUEST_HEAD_SHA}"

  local EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA
  EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA="fa386af5d523fabb5df5d1bae53b8984dfbf4ff0"

  if [ "${GITHUB_PULL_REQUEST_HEAD_SHA}" != "${EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA}" ]; then
    fatal "GITHUB_PULL_REQUEST_HEAD_SHA (${GITHUB_PULL_REQUEST_HEAD_SHA}) is not equal to: ${EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetPullRequestHeadShaTest
