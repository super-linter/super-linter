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
  set +o errexit
  GITHUB_EVENT_COMMIT_COUNT="$(GetGithubPushEventCommitCount "test/data/github-event/github-event-push.json")"
  RET_CODE=$?
  set -o errexit
  if [[ "${RET_CODE}" -gt 0 ]]; then
    fatal "Failed to get commit count from GitHub push event. Output: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  debug "GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"

  if [ "${GITHUB_EVENT_COMMIT_COUNT}" -ne 1 ]; then
    fatal "GITHUB_EVENT_COMMIT_COUNT is not equal to 1: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGithubPushEventCommitCountTest

GetGitHubEventPushBeforeTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_PUSH_BEFORE
  if ! GITHUB_PUSH_BEFORE=$(GetGitHubEventPushBefore "test/data/github-event/github-event-push.json"); then
    fatal "Error while setting GITHUB_PUSH_BEFORE"
  fi

  debug "GITHUB_PUSH_BEFORE: ${GITHUB_PUSH_BEFORE}"

  local EXPECTED_GITHUB_PUSH_BEFORE
  EXPECTED_GITHUB_PUSH_BEFORE="0000000000000000000000000000000000000000"

  if [ "${GITHUB_PUSH_BEFORE}" != "${EXPECTED_GITHUB_PUSH_BEFORE}" ]; then
    fatal "GITHUB_PUSH_BEFORE (${GITHUB_PUSH_BEFORE}) is not equal to: ${EXPECTED_GITHUB_PUSH_BEFORE}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetGitHubEventPushBeforeTest

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
  if ! GITHUB_PULL_REQUEST_HEAD_SHA=$(GetPullRequestHeadSha "test/data/github-event/github-event-pull-request-multiple-commits.json"); then
    fatal "Failed to get pull request HEAD SHA"
  fi

  debug "GITHUB_PULL_REQUEST_HEAD_SHA: ${GITHUB_PULL_REQUEST_HEAD_SHA}"

  local EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA
  EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA="pull-request-head-sha"

  if [ "${GITHUB_PULL_REQUEST_HEAD_SHA}" != "${EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA}" ]; then
    fatal "GITHUB_PULL_REQUEST_HEAD_SHA (${GITHUB_PULL_REQUEST_HEAD_SHA}) is not equal to: ${EXPECTED_GITHUB_PULL_REQUEST_HEAD_SHA}"
  fi

  notice "${FUNCTION_NAME} PASS"
}

GetPullRequestHeadShaTest
