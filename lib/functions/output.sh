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
  local HTTP_METHOD="${1:-POST}"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    warn "Provide a GitHub token to call the GitHub API: ${GITHUB_URL}"
    return 1
  fi

  debug "Calling GitHub API (${GITHUB_URL}) with method: ${HTTP_METHOD}, payload: ${PAYLOAD}"

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

  if [[ -n "${PAYLOAD}" ]]; then
    CURL_ARGS+=(-d "${PAYLOAD}")
  fi

  if ! CALL_GITHUB_API_OUT=$(curl "${CURL_ARGS[@]}" 2>&1); then
    warn "Failed to call GitHub API (${GITHUB_URL}): ${CALL_GITHUB_API_OUT}"
    return 1
  fi
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

  if ! CallGitHubApi "${GITHUB_ISSUE_COMMENT_URL}" "${GITHUB_TOKEN}" "${CREATE_ISSUE_COMMENT_API_PAYLOAD}"; then
    warn "Failed to create GitHub issue comment"
    return 1
  fi
}

SUPER_LINTER_SUMMARY_COMMENT_MARKER="<!-- super-linter-summary-comment -->"

# Ref: https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#list-issue-comments
FindExistingSummaryComment() {
  local GITHUB_ISSUE_NUMBER="${1}" && shift

  local GITHUB_ISSUE_COMMENTS_URL
  GITHUB_ISSUE_COMMENTS_URL="${GITHUB_ISSUES_URL}/${GITHUB_ISSUE_NUMBER}/comments"
  debug "Listing comments for issue #${GITHUB_ISSUE_NUMBER} to find existing summary comment"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    warn "Provide a GitHub token to call the GitHub API: ${GITHUB_ISSUE_COMMENTS_URL}"
    return 1
  fi

  local NEXT_URL="${GITHUB_ISSUE_COMMENTS_URL}?per_page=100"
  while [[ -n "${NEXT_URL}" ]]; do
    local RESPONSE_HEADERS
    RESPONSE_HEADERS="$(mktemp)"

    local LIST_COMMENTS_OUT
    if ! LIST_COMMENTS_OUT=$(
      curl \
        --fail \
        --location \
        --request GET \
        --show-error \
        --silent \
        --dump-header "${RESPONSE_HEADERS}" \
        --url "${NEXT_URL}" \
        -H "accept: application/vnd.github+json" \
        -H "authorization: Bearer ${GITHUB_TOKEN}" \
        -H "X-GitHub-Api-Version: 2022-11-28"
    ); then
      rm -f "${RESPONSE_HEADERS}"
      warn "Failed to list comments for issue #${GITHUB_ISSUE_NUMBER}: ${LIST_COMMENTS_OUT}"
      return 1
    fi

    local EXISTING_COMMENT_ID
    if ! EXISTING_COMMENT_ID=$(echo "${LIST_COMMENTS_OUT}" | jq -r --arg marker "${SUPER_LINTER_SUMMARY_COMMENT_MARKER}" '[.[] | select((.body // "") | startswith($marker))] | last | .id // empty'); then
      rm -f "${RESPONSE_HEADERS}"
      warn "Error while parsing comments response"
      return 1
    fi

    if [[ -n "${EXISTING_COMMENT_ID}" ]]; then
      rm -f "${RESPONSE_HEADERS}"
      debug "Found existing summary comment with ID: ${EXISTING_COMMENT_ID}"
      echo "${EXISTING_COMMENT_ID}"
      return 0
    fi

    # Check for next page via Link header
    NEXT_URL=""
    if grep -qi '^link:' "${RESPONSE_HEADERS}"; then
      NEXT_URL=$(grep -i '^link:' "${RESPONSE_HEADERS}" | sed -n 's/.*<\([^>]*\)>; rel="next".*/\1/p')
    fi
    rm -f "${RESPONSE_HEADERS}"
  done

  return 0
}

# Ref: https://docs.github.com/en/rest/issues/comments?apiVersion=2022-11-28#update-an-issue-comment
UpdateGitHubIssueComment() {
  local COMMENT_PAYLOAD="${1}" && shift
  local COMMENT_ID="${1}" && shift

  local UPDATE_ISSUE_COMMENT_API_PAYLOAD
  if ! UPDATE_ISSUE_COMMENT_API_PAYLOAD="$(jq --null-input --arg body "${COMMENT_PAYLOAD}" '{body: $body}')"; then
    warn "Error while loading the contents of COMMENT_PAYLOAD to UPDATE_ISSUE_COMMENT_API_PAYLOAD"
    return 1
  fi

  local GITHUB_ISSUE_COMMENT_URL
  GITHUB_ISSUE_COMMENT_URL="${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues/comments/${COMMENT_ID}"
  debug "Updating GitHub issue comment (URL: ${GITHUB_ISSUE_COMMENT_URL}). COMMENT_ID: ${COMMENT_ID}"

  if ! CallGitHubApi "${GITHUB_ISSUE_COMMENT_URL}" "${GITHUB_TOKEN}" "${UPDATE_ISSUE_COMMENT_API_PAYLOAD}" "PATCH"; then
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
    warn "Error while loading the contents of COMMENT_PAYLOAD to SUMMARY_COMMENT_BODY"
    return 1
  fi

  # Prepend the marker so we can find this comment later
  SUMMARY_COMMENT_BODY="${SUPER_LINTER_SUMMARY_COMMENT_MARKER}
${SUMMARY_COMMENT_BODY}"

  # Check if there's an existing summary comment to update
  local EXISTING_COMMENT_ID
  if ! EXISTING_COMMENT_ID=$(FindExistingSummaryComment "${GITHUB_PULL_REQUEST_NUMBER}"); then
    warn "Error while looking up existing summary comment, falling back to creating a new one"
    if ! CreateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${GITHUB_PULL_REQUEST_NUMBER}"; then
      warn "Error while posting pull request summary"
      return 1
    fi
    return 0
  fi

  if [[ -n "${EXISTING_COMMENT_ID}" ]]; then
    debug "Updating existing summary comment (ID: ${EXISTING_COMMENT_ID}) on PR #${GITHUB_PULL_REQUEST_NUMBER}"
    if ! UpdateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${EXISTING_COMMENT_ID}"; then
      warn "Error while updating pull request summary comment"
      return 1
    fi
  else
    debug "No existing summary comment found, creating a new one"
    if ! CreateGitHubIssueComment "${SUMMARY_COMMENT_BODY}" "${GITHUB_PULL_REQUEST_NUMBER}"; then
      warn "Error while posting pull request summary"
      return 1
    fi
  fi
}
