#!/usr/bin/env bash

WriteSummaryHeader() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"

  {
    echo "# Super-linter summary"
    echo ""
    echo "| Language | Validation result |"
    echo "| -------- | ----------------- |"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryLineSuccess() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local LANGUAGE_NAME="${2}"
  echo "| ${LANGUAGE_NAME} | Pass ✅ |" >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryLineFailure() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local LANGUAGE_NAME="${2}"
  echo "| ${LANGUAGE_NAME} | Fail ❌ |" >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryFooterSuccess() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  {
    echo ""
    echo "All files and directories linted successfully"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryFooterFailure() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  {
    echo ""
    echo "Super-linter detected linting errors"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteSummaryFooterMoreInfo() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"

  if [[ -v GITHUB_WORKFLOW_RUN_URL ]]; then
    {
      echo ""
      echo "For more information, see the [GitHub Actions workflow run](${GITHUB_WORKFLOW_RUN_URL})"
    } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
  elif [[ "${SAVE_SUPER_LINTER_SUMMARY:-}" == "true" ]]; then
    {
      echo ""
      echo "For more information, see the Super-linter summary (${SUPER_LINTER_SUMMARY_OUTPUT_PATH#"${GITHUB_WORKSPACE}/"}) and the Super-linter log (${LOG_FILE_PATH#"${GITHUB_WORKSPACE}/"})"
    } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
  else
    {
      echo ""
      echo "For more information, see the Super-linter log (${LOG_FILE_PATH#"${GITHUB_WORKSPACE}/"})"
    } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
  fi
}

WriteSummaryFooterSuperLinterInfo() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  {
    echo ""
    echo "Powered by [Super-linter](https://github.com/super-linter/super-linter)"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteMarkdownCollapsedSection() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}" && shift
  local SUMMARY="${1}" && shift
  local BODY="${1}" && shift

  {
    echo ""
    echo "<details>"
    echo ""
    echo "<summary>${SUMMARY}</summary>"
    echo ""
    echo "${BODY}"
    echo ""
    echo "</details>"
  } >>"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}"
}

WriteMarkdownCodeBlock() {
  local CONTENT="${1}"
  local LANGUAGE="${2:-}"
  echo "\`\`\`${LANGUAGE}"
  echo "${CONTENT}"
  echo "\`\`\`"
  echo ""
}

FormatSuperLinterSummaryFile() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}"
  local SUPER_LINTER_SUMMARY_FORMAT_COMMAND=(prettier --write)

  # Avoid emitting output except of warnings and errors if debug logging is
  # disabled.
  if [[ "${LOG_DEBUG}" != "true" ]]; then
    SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=(--log-level warn)
  fi
  # Override the default prettier ignore paths (.gitignore, .prettierignore) to
  # avoid considering their defaults because prettier will skip formatting
  # the summary report file if the summary report file is ignored in those
  # ignore files, which is usually the case for generated files.
  # Ref: https://prettier.io/docs/en/cli#--ignore-path
  SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=(--ignore-path /dev/null)
  SUPER_LINTER_SUMMARY_FORMAT_COMMAND+=("${SUPER_LINTER_SUMMARY_OUTPUT_PATH}")
  debug "Formatting the Super-linter summary file by running: ${SUPER_LINTER_SUMMARY_FORMAT_COMMAND[*]}"
  if ! "${SUPER_LINTER_SUMMARY_FORMAT_COMMAND[@]}"; then
    error "Error while formatting the Super-linter summary file."
    return 1
  fi
}

# 0x1B (= ^[) is the control code that starts all ANSI color codes escape sequences
# Ref: https://en.wikipedia.org/wiki/ANSI_escape_code#C0_control_codes
ANSI_COLOR_CODES_SEARCH_PATTERN='\x1b\[[0-9;]*m'
export ANSI_COLOR_CODES_SEARCH_PATTERN
RemoveAnsiColorCodesFromFile() {
  local FILE_PATH="${1}"
  debug "Removing ANSI color codes from ${FILE_PATH}"
  if ! sed -i "s/${ANSI_COLOR_CODES_SEARCH_PATTERN}//g" "${FILE_PATH}"; then
    error "Error while removing ANSI color codes from ${FILE_PATH}"
    return 1
  fi
}

CallGitHubApi() {
  local GITHUB_URL="${1}" && shift
  local GITHUB_TOKEN="${1}" && shift
  local PAYLOAD="${1}" && shift
  local HTTP_METHOD="${1:-POST}" && shift
  local INCLUDE_RESPONSE_HEADERS="${1:-false}"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    error "Provide a GitHub token to call the GitHub API: ${GITHUB_URL}"
    return 1
  fi

  local CURL_ARGS=(
    --fail
    --location
    --request "${HTTP_METHOD}"
    --show-error
    --silent
    --url "${GITHUB_URL}"
    -H "accept: application/vnd.github+json"
    -H "authorization: Bearer ${GITHUB_TOKEN}"
    -H "content-type: application/json"
    -H "X-GitHub-Api-Version: 2022-11-28"
  )

  if [[ "${INCLUDE_RESPONSE_HEADERS}" == "true" ]]; then
    CURL_ARGS+=(--include)
  fi

  if [[ -n "${PAYLOAD}" ]]; then
    CURL_ARGS+=(-d "${PAYLOAD}")
  fi

  local CALL_GITHUB_API_OUT
  if ! CALL_GITHUB_API_OUT=$(curl "${CURL_ARGS[@]}" 2>&1); then
    error "Failed to call GitHub API (${GITHUB_URL}) with ${HTTP_METHOD} HTTP method: ${CALL_GITHUB_API_OUT}"
    return 1
  fi
  echo "${CALL_GITHUB_API_OUT}"
}

# Ref: https://docs.github.com/en/rest/commits/statuses?apiVersion=2022-11-28#create-a-commit-status
CreateGitHubCommitStatus() {
  local LANGUAGE="${1}"
  local STATUS="${2}"

  debug "Calling Multi-Status API for event: ${GITHUB_EVENT_NAME}, language: $LANGUAGE, status: $STATUS"

  local MESSAGE=""
  if [ "${STATUS}" == "success" ]; then
    MESSAGE="No linting or formatting errors"
  else
    MESSAGE="Detected linting or formatting errors"
  fi

  if [ "${DISABLE_ERRORS}" == "true" ]; then
    STATUS="success"
  fi

  local GITHUB_STATUS_API_PAYLOAD="{
    \"state\": \"${STATUS}\",
    \"target_url\": \"${GITHUB_WORKFLOW_RUN_URL}\",
    \"description\": \"${MESSAGE}\",
    \"context\": \"--> Linted: ${LANGUAGE}\"
  }"

  debug "Calling GitHub API (${GITHUB_STATUS_URL}), payload: ${GITHUB_STATUS_API_PAYLOAD}"
  if ! CallGitHubApi "${GITHUB_STATUS_URL}" "${GITHUB_TOKEN}" "${GITHUB_STATUS_API_PAYLOAD}"; then
    warn "Failed to create GitHub Commit Status"
    return 1
  fi
}

# Ref: https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#create-an-issue-comment
CreateGitHubIssueComment() {
  local COMMENT_PAYLOAD="${1}" && shift
  local GITHUB_ISSUE_NUMBER="${1}" && shift

  local CREATE_ISSUE_COMMENT_API_PAYLOAD
  if ! CREATE_ISSUE_COMMENT_API_PAYLOAD="$(jq --null-input --arg body "${COMMENT_PAYLOAD}" '{body: $body}')"; then
    warn "Error while loading the contents of COMMENT_PAYLOAD to CREATE_ISSUE_COMMENT_API_PAYLOAD"
    return 1
  fi

  local GITHUB_ISSUE_COMMENT_URL
  GITHUB_ISSUE_COMMENT_URL="${GITHUB_ISSUES_URL}/${GITHUB_ISSUE_NUMBER}/comments"
  debug "Setting GITHUB_ISSUE_COMMENT_URL to: ${GITHUB_ISSUE_COMMENT_URL}"

  debug "Creating GitHub issue comment (URL: ${GITHUB_ISSUE_COMMENT_URL}). GITHUB_ISSUE_NUMBER: ${GITHUB_ISSUE_NUMBER}, payload: ${CREATE_ISSUE_COMMENT_API_PAYLOAD}"

  debug "Calling GitHub API (${GITHUB_ISSUE_COMMENT_URL}), payload: ${CREATE_ISSUE_COMMENT_API_PAYLOAD}"
  if ! CallGitHubApi "${GITHUB_ISSUE_COMMENT_URL}" "${GITHUB_TOKEN}" "${CREATE_ISSUE_COMMENT_API_PAYLOAD}"; then
    warn "Failed to create GitHub issue comment"
    return 1
  fi
}

# Ref: https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#list-issue-comments
# Echoes the ID of the existing super-linter summary comment, or empty string if not found.
FindExistingSummaryComment() {
  local GITHUB_ISSUE_NUMBER="${1}" && shift

  local EXISTING_SUMMARY_COMMENT_ID=""

  local GITHUB_ISSUE_COMMENTS_URL
  GITHUB_ISSUE_COMMENTS_URL="${GITHUB_ISSUES_URL}/${GITHUB_ISSUE_NUMBER}/comments"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    warn "Provide a GitHub token to call the GitHub API: ${GITHUB_ISSUE_COMMENTS_URL}"
    return 1
  fi

  local NEXT_URL="${GITHUB_ISSUE_COMMENTS_URL}?per_page=100"
  while [[ -n "${NEXT_URL}" ]]; do
    local CALL_GITHUB_API_OUT
    local GITHUB_API_HTTP_METHOD
    GITHUB_API_HTTP_METHOD="GET"
    if ! CALL_GITHUB_API_OUT="$(CallGitHubApi "${NEXT_URL}" "${GITHUB_TOKEN}" "" "${GITHUB_API_HTTP_METHOD}" "true")"; then
      debug "Calling GitHub API (${NEXT_URL}), HTTP method: ${GITHUB_API_HTTP_METHOD}"
      error "Failed to list comments for issue #${GITHUB_ISSUE_NUMBER}: ${CALL_GITHUB_API_OUT}"
      return 1
    fi

    # Extract the response body from the last HTTP response block.
    # curl --include --location can produce multiple header blocks (one per redirect);
    # reset on each new HTTP/ status line so we only parse the final response body.
    local RESPONSE_BODY
    if ! RESPONSE_BODY=$(
      set -o pipefail
      printf '%s' "${CALL_GITHUB_API_OUT}" | awk '
        /^HTTP\//{in_headers=1; body=""; next}
        in_headers && /^\r?$/{in_headers=0; next}
        !in_headers{body = body ? body "\n" $0 : $0}
        END{print body}
      ' 2>&1
    ); then
      error "Error while extracting response body from API response"
      return 1
    fi

    local EXISTING_COMMENT_ID
    if ! EXISTING_COMMENT_ID=$(
      set -o pipefail
      printf '%s' "${RESPONSE_BODY}" | jq -r --arg marker "${SUPER_LINTER_SUMMARY_COMMENT_MARKER}" '[.[] | select((.body // "") | startswith($marker))] | last | .id // empty' 2>&1
    ); then
      error "Error while parsing comments response"
      return 1
    fi

    if [[ -n "${EXISTING_COMMENT_ID:-}" ]]; then
      echo "${EXISTING_COMMENT_ID}"
      return 0
    fi

    # Parse the Link header from the last response block for the next page URL
    if ! NEXT_URL=$(
      set -o pipefail
      printf '%s' "${CALL_GITHUB_API_OUT}" | awk '
        /^HTTP\//{link=""; next}
        /^[Ll]ink:/{link=$0}
        END{print link}
      ' | sed -n 's/^[Ll]ink:.*<\([^>]*\)>; rel="next".*/\1/p' | tr -d '\r' 2>&1
    ); then
      error "Error while parsing next page URL from API response"
      return 1
    fi
  done

  echo "${EXISTING_SUMMARY_COMMENT_ID}"
  return 0
}

# Ref: https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#update-an-issue-comment
UpdateGitHubIssueComment() {
  local COMMENT_PAYLOAD="${1}" && shift
  local COMMENT_ID="${1}" && shift

  local UPDATE_ISSUE_COMMENT_API_PAYLOAD
  if ! UPDATE_ISSUE_COMMENT_API_PAYLOAD="$(jq --null-input --arg body "${COMMENT_PAYLOAD}" '{body: $body}' 2>&1)"; then
    warn "Error while loading the contents of COMMENT_PAYLOAD to UPDATE_ISSUE_COMMENT_API_PAYLOAD: ${UPDATE_ISSUE_COMMENT_API_PAYLOAD}"
    return 1
  fi

  local GITHUB_ISSUE_COMMENT_URL
  GITHUB_ISSUE_COMMENT_URL="${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues/comments/${COMMENT_ID}"
  debug "Updating GitHub issue comment (URL: ${GITHUB_ISSUE_COMMENT_URL}). COMMENT_ID: ${COMMENT_ID}"

  local GITHUB_API_HTTP_METHOD
  GITHUB_API_HTTP_METHOD="PATCH"
  debug "Calling GitHub API (${GITHUB_ISSUE_COMMENT_URL}), HTTP method: ${GITHUB_API_HTTP_METHOD}, payload: ${UPDATE_ISSUE_COMMENT_API_PAYLOAD}"
  if ! CallGitHubApi "${GITHUB_ISSUE_COMMENT_URL}" "${GITHUB_TOKEN}" "${UPDATE_ISSUE_COMMENT_API_PAYLOAD}" "${GITHUB_API_HTTP_METHOD}"; then
    warn "Failed to update GitHub issue comment"
    return 1
  fi
}

CreateGitHubPullRequestSummaryComment() {
  local SUPER_LINTER_SUMMARY_OUTPUT_PATH="${1}" && shift
  local GITHUB_PULL_REQUEST_NUMBER="${1}" && shift

  debug "Creating GitHub pull request summary comment. SUPER_LINTER_SUMMARY_OUTPUT_PATH: ${SUPER_LINTER_SUMMARY_OUTPUT_PATH}, GITHUB_PULL_REQUEST_NUMBER: ${GITHUB_PULL_REQUEST_NUMBER}"

  local SUMMARY_COMMENT_BODY
  if ! SUMMARY_COMMENT_BODY="$(<"${SUPER_LINTER_SUMMARY_OUTPUT_PATH}")"; then
    error "Error while loading the contents of COMMENT_PAYLOAD to SUMMARY_COMMENT_BODY: ${SUMMARY_COMMENT_BODY}"
    return 1
  fi

  # Prepend the marker so we can find this comment later
  SUMMARY_COMMENT_BODY="${SUPER_LINTER_SUMMARY_COMMENT_MARKER}
${SUMMARY_COMMENT_BODY}"

  if [[ "${UPDATE_EXISTING_GITHUB_PULL_REQUEST_SUMMARY_COMMENT}" == "true" ]]; then
    # Check if there's an existing summary comment to update
    local SUPER_LINTER_EXISTING_SUMMARY_COMMENT_ID
    debug "Listing comments for issue #${GITHUB_PULL_REQUEST_NUMBER} to find existing summary comment"
    if ! SUPER_LINTER_EXISTING_SUMMARY_COMMENT_ID="$(FindExistingSummaryComment "${GITHUB_PULL_REQUEST_NUMBER}")"; then
      error "Error while looking up existing summary comment, falling back to creating a new one"
      if ! CreateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${GITHUB_PULL_REQUEST_NUMBER}"; then
        error "Error while posting pull request summary"
        return 1
      fi
      return 0
    fi

    if [[ -n "${SUPER_LINTER_EXISTING_SUMMARY_COMMENT_ID:-}" ]]; then
      debug "Updating existing summary comment (ID: ${SUPER_LINTER_EXISTING_SUMMARY_COMMENT_ID}) on PR #${GITHUB_PULL_REQUEST_NUMBER}"
      if ! UpdateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${SUPER_LINTER_EXISTING_SUMMARY_COMMENT_ID}"; then
        error "Error while updating pull request summary comment"
        return 1
      fi
    else
      debug "No existing summary comment found, creating a new one"
      if ! CreateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${GITHUB_PULL_REQUEST_NUMBER}"; then
        error "Error while posting pull request summary"
        return 1
      fi
    fi
  else
    debug "UPDATE_EXISTING_GITHUB_PULL_REQUEST_SUMMARY_COMMENT is false, creating a new comment"
    if ! CreateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${GITHUB_PULL_REQUEST_NUMBER}"; then
      error "Error while posting pull request summary"
      return 1
    fi
  fi
}
