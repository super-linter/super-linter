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
