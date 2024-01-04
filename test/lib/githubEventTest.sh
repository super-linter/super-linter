#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
LOG_TRACE="true"
# shellcheck disable=SC2034
LOG_DEBUG="true"
# shellcheck disable=SC2034
LOG_VERBOSE="true"
# shellcheck disable=SC2034
LOG_NOTICE="true"
# shellcheck disable=SC2034
LOG_WARN="true"
# shellcheck disable=SC2034
LOG_ERROR="true"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck disable=SC2034
CREATE_LOG_FILE=false

# shellcheck source=/dev/null
source "lib/functions/validation.sh"
# shellcheck source=/dev/null
source "lib/functions/githubEvent.sh"

function GetGithubPushEventCommitCountTest() {
  local GITHUB_EVENT_COMMIT_COUNT
  GITHUB_EVENT_COMMIT_COUNT=$(GetGithubPushEventCommitCount "test/data/github-event/github-event-push.json")

  debug "GITHUB_EVENT_COMMIT_COUNT: ${GITHUB_EVENT_COMMIT_COUNT}"

  if [ "${GITHUB_EVENT_COMMIT_COUNT}" -ne 1 ]; then
    fatal "GITHUB_EVENT_COMMIT_COUNT is not equal to 1: ${GITHUB_EVENT_COMMIT_COUNT}"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

GetGithubPushEventCommitCountTest
