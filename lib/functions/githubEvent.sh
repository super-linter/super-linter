#!/usr/bin/env bash

# Pull request event payload ref: https://docs.github.com/en/webhooks/webhook-events-and-payloads#pull_request
# Push event payload ref: https://docs.github.com/en/webhooks/webhook-events-and-payloads#push

function GetGithubPushEventCommitCount() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local -i GITHUB_PUSH_COMMIT_COUNT

  GITHUB_PUSH_COMMIT_COUNT="$(jq -r '.commits | length' <"${GITHUB_EVENT_FILE_PATH}")"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_PUSH_COMMIT_COUNT for a push event. Output: ${GITHUB_PUSH_COMMIT_COUNT}"
    return 1
  fi

  if IsUnsignedInteger "${GITHUB_PUSH_COMMIT_COUNT}" && [ -n "${GITHUB_PUSH_COMMIT_COUNT}" ]; then
    echo "${GITHUB_PUSH_COMMIT_COUNT}"
    return 0
  else
    error "GITHUB_PUSH_COMMIT_COUNT is not an unsigned integer: ${GITHUB_PUSH_COMMIT_COUNT}"
    return 1
  fi
}

GetGitHubEventPushBefore() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local -i GITHUB_PUSH_COMMIT_COUNT

  GITHUB_PUSH_BEFORE="$(jq -r '.before' <"${GITHUB_EVENT_FILE_PATH}")"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_PUSH_BEFORE for a push event. Output: ${GITHUB_PUSH_BEFORE}"
    return 1
  fi

  echo "${GITHUB_PUSH_BEFORE}"
}

GetGitHubEventForced() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_FORCED

  GITHUB_FORCED="$(jq -r '.forced' <"${GITHUB_EVENT_FILE_PATH}")"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_FORCED. Output: ${GITHUB_FORCED}"
    return 1
  fi

  echo "${GITHUB_FORCED}"
}

function GetGithubPullRequestEventCommitCount() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_PULL_REQUEST_COMMIT_COUNT

  GITHUB_PULL_REQUEST_COMMIT_COUNT=$(jq -r '.pull_request.commits' <"${GITHUB_EVENT_FILE_PATH}")
  RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_PULL_REQUEST_COMMIT_COUNT for a pull request event."
    return 1
  fi

  if IsUnsignedInteger "${GITHUB_PULL_REQUEST_COMMIT_COUNT}" && [ -n "${GITHUB_PULL_REQUEST_COMMIT_COUNT}" ]; then
    echo "${GITHUB_PULL_REQUEST_COMMIT_COUNT}"
    return 0
  else
    error "GITHUB_PULL_REQUEST_COMMIT_COUNT is not an integer: ${GITHUB_PULL_REQUEST_COMMIT_COUNT}"
    return 1
  fi
}

GetPullRequestNumber() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_PULL_REQUEST_NUMBER

  GITHUB_PULL_REQUEST_NUMBER="$(jq -r '.number' <"${GITHUB_EVENT_FILE_PATH}")"
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_PULL_REQUEST_NUMBER. Output: ${GITHUB_PULL_REQUEST_NUMBER}"
    return 1
  fi

  echo "${GITHUB_PULL_REQUEST_NUMBER}"
}

function GetGithubRepositoryDefaultBranch() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_REPOSITORY_DEFAULT_BRANCH

  GITHUB_REPOSITORY_DEFAULT_BRANCH=$(jq -r '.repository.default_branch' <"${GITHUB_EVENT_FILE_PATH}")
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_REPOSITORY_DEFAULT_BRANCH. Output: ${GITHUB_REPOSITORY_DEFAULT_BRANCH}"
    return 1
  fi

  echo "${GITHUB_REPOSITORY_DEFAULT_BRANCH}"
}

function GetPullRequestHeadSha() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_PULL_REQUEST_HEAD_SHA

  GITHUB_PULL_REQUEST_HEAD_SHA=$(jq -r '.pull_request.head.sha' <"${GITHUB_EVENT_FILE_PATH}")
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_PULL_REQUEST_HEAD_SHA. Output: ${GITHUB_PULL_REQUEST_HEAD_SHA}"
    return 1
  fi

  echo "${GITHUB_PULL_REQUEST_HEAD_SHA}"
}

GetGithubPushFirstPushedCommitHash() {
  local GITHUB_EVENT_FILE_PATH
  GITHUB_EVENT_FILE_PATH="${1}"
  local GITHUB_FIRST_PUSHED_COMMIT_HASH

  GITHUB_FIRST_PUSHED_COMMIT_HASH=$(jq -r '.commits | if length > 0 then .[0].id else "null" end' <"${GITHUB_EVENT_FILE_PATH}")
  local RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Failed to initialize GITHUB_FIRST_PUSHED_COMMIT_HASH. Output: ${GITHUB_FIRST_PUSHED_COMMIT_HASH}"
    return 1
  fi

  echo "${GITHUB_FIRST_PUSHED_COMMIT_HASH}"
}
