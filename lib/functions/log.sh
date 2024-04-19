#!/usr/bin/env bash

# GitHub Actions variables to enable workflow debug logging
# Ref: https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging
# Ref: https://github.com/actions/runner/pull/253
declare -l ACTIONS_RUNNER_DEBUG
ACTIONS_RUNNER_DEBUG="${ACTIONS_RUNNER_DEBUG:-"false"}"
declare -l ACTIONS_STEPS_DEBUG
ACTIONS_STEPS_DEBUG="${ACTIONS_STEPS_DEBUG:-"false"}"
declare -i RUNNER_DEBUG
RUNNER_DEBUG="${RUNNER_DEBUG:-0}"

# Default log file name (located in GITHUB_WORKSPACE folder)
LOG_FILE="${LOG_FILE:-"super-linter.log"}"
LOG_LEVEL="${LOG_LEVEL:-"INFO"}"
declare -l CREATE_LOG_FILE
CREATE_LOG_FILE="${CREATE_LOG_FILE:-"false"}"
export CREATE_LOG_FILE

if [[ ${ACTIONS_RUNNER_DEBUG} == true ]] ||
  [[ ${ACTIONS_STEPS_DEBUG} == true ]] ||
  [[ ${RUNNER_DEBUG} -eq 1 ]]; then
  LOG_LEVEL="DEBUG"
  echo "ACTIONS_RUNNER_DEBUG: ${ACTIONS_RUNNER_DEBUG}. ACTIONS_STEPS_DEBUG: ${ACTIONS_STEPS_DEBUG}. RUNNER_DEBUG: ${RUNNER_DEBUG}. Setting LOG_LEVEL to: ${LOG_LEVEL}"
fi

declare -l LOG_DEBUG
LOG_DEBUG="false"
declare -l LOG_VERBOSE
LOG_VERBOSE="false"
declare -l LOG_NOTICE
LOG_NOTICE="false"
declare -l LOG_WARN
LOG_WARN="false"
declare -l LOG_ERROR
LOG_ERROR="false"

if [[ ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then
  LOG_DEBUG="true"
  LOG_VERBOSE="true"
  LOG_NOTICE="true"
  LOG_WARN="true"
  LOG_ERROR="true"
fi

if [[ ${LOG_LEVEL} == "INFO" || ${LOG_LEVEL} == "VERBOSE" ]]; then
  LOG_VERBOSE="true"
  LOG_NOTICE="true"
  LOG_WARN="true"
  LOG_ERROR="true"
fi

if [[ ${LOG_LEVEL} == "NOTICE" ]]; then
  LOG_NOTICE="true"
  LOG_WARN="true"
  LOG_ERROR="true"
fi

if [[ ${LOG_LEVEL} == "WARN" ]]; then
  LOG_WARN="true"
  LOG_ERROR="true"
fi

if [[ ${LOG_LEVEL} == "ERROR" ]]; then
  LOG_ERROR="true"
fi

export LOG_DEBUG
export LOG_VERBOSE
export LOG_NOTICE
export LOG_WARN
export LOG_ERROR

LOG_TEMP=$(mktemp) || echo "Failed to create temporary log file."
export LOG_TEMP

log() {
  local EMIT_LOG_MESSAGE="${1}"
  local MESSAGE="${2}"
  local LOG_LEVEL_LABEL="${3}"

  local LOG_MESSAGE_DATE
  LOG_MESSAGE_DATE="$(date +"%F %T")"
  local COLOR_MARKER
  # Set foreground color to blue
  COLOR_MARKER=$(echo -e "\e[0;34m")

  # Reset colors
  local NC
  NC=$(echo -e "\e[0m")

  if [ "${LOG_LEVEL_LABEL}" == "NOTICE" ]; then
    # Set foreground color to green
    COLOR_MARKER=$(echo -e "\e[0;32m")
  elif [ "${LOG_LEVEL_LABEL}" == "WARN" ]; then
    # Set foreground color to yellow
    COLOR_MARKER=$(echo -e "\e[0;33m")
  elif [ "${LOG_LEVEL_LABEL}" == "ERROR" ] || [ "${LOG_LEVEL_LABEL}" == "FATAL" ]; then
    # Set foreground color to red
    COLOR_MARKER=$(echo -e "\e[0;31m")
  fi

  LOG_LEVEL_LABEL="[${LOG_LEVEL_LABEL}]"

  local COLORED_MESSAGE
  COLORED_MESSAGE="${NC}${LOG_MESSAGE_DATE} ${COLOR_MARKER}${LOG_LEVEL_LABEL}${NC}   ${MESSAGE}${NC}"
  local MESSAGE_FOR_LOG_FILE
  MESSAGE_FOR_LOG_FILE="${LOG_MESSAGE_DATE} ${LOG_LEVEL_LABEL}   ${MESSAGE}"

  if [[ "${EMIT_LOG_MESSAGE}" == "true" ]]; then
    # Emit colors only if there's a terminal
    if [ -t 0 ]; then
      echo -e "${COLORED_MESSAGE}"
    else
      echo -e "${MESSAGE_FOR_LOG_FILE}"
    fi

    if [ "${CREATE_LOG_FILE}" = "true" ]; then
      echo -e "${MESSAGE_FOR_LOG_FILE}" >>"${LOG_TEMP}"
    fi
  fi
}

debug() { log "${LOG_DEBUG}" "$*" "DEBUG"; }
info() { log "${LOG_VERBOSE}" "$*" "INFO"; }
notice() { log "${LOG_NOTICE}" "$*" "NOTICE"; }
warn() { log "${LOG_WARN}" "$*" "WARN"; }
error() { log "${LOG_ERROR}" "$*" "ERROR"; }
fatal() {
  log "true" "$*" "FATAL"
  exit 1
}

debug "LOG_LEVEL is set to: ${LOG_LEVEL}"
debug "Log level variables. LOG_DEBUG: ${LOG_DEBUG}, LOG_VERBOSE: ${LOG_VERBOSE}, LOG_NOTICE: ${LOG_NOTICE}. LOG_WARN: ${LOG_WARN}, LOG_ERROR: ${LOG_ERROR}"

# shellcheck disable=SC2034  # Variable is referenced in other files
SUPER_LINTER_INITIALIZATION_LOG_GROUP_TITLE="Super-Linter initialization"
export SUPER_LINTER_INITIALIZATION_LOG_GROUP_TITLE
GITHUB_ACTIONS_LOG_GROUP_MARKER_START="start"
export GITHUB_ACTIONS_LOG_GROUP_MARKER_START
GITHUB_ACTIONS_LOG_GROUP_MARKER_END="end"
export GITHUB_ACTIONS_LOG_GROUP_MARKER_END

writeGitHubActionsLogGroupMarker() {
  local LOG_GROUP_MARKER_MODE="${1}"
  shift
  local GROUP_TITLE="${1}"

  if [ -z "${GROUP_TITLE}" ]; then
    fatal "GitHub Actions log group title variable is empty."
  fi

  if [ -z "${ENABLE_GITHUB_ACTIONS_GROUP_TITLE}" ]; then
    fatal "GitHub Actions enable log group title variable is empty."
  fi

  if [[ "${LOG_GROUP_MARKER_MODE}" != "${GITHUB_ACTIONS_LOG_GROUP_MARKER_START}" ]] &&
    [[ "${LOG_GROUP_MARKER_MODE}" != "${GITHUB_ACTIONS_LOG_GROUP_MARKER_END}" ]]; then
    fatal "Unsupported LOG_GROUP_MARKER_MODE (${LOG_GROUP_MARKER_MODE}) for group: ${GROUP_TITLE}"
  fi

  if [[ "${ENABLE_GITHUB_ACTIONS_GROUP_TITLE}" == "true" ]]; then
    if [[ "${LOG_GROUP_MARKER_MODE}" == "${GITHUB_ACTIONS_LOG_GROUP_MARKER_START}" ]]; then
      echo "::group::${GROUP_TITLE}"
      debug "Started GitHub Actions log group: ${GROUP_TITLE}"
    elif [[ "${LOG_GROUP_MARKER_MODE}" == "${GITHUB_ACTIONS_LOG_GROUP_MARKER_END}" ]]; then
      debug "Ending GitHub Actions log group: ${GROUP_TITLE}"
      echo "::endgroup::"
    fi
  else
    debug "Skipped GitHub Actions log group ${LOG_GROUP_MARKER_MODE} for group: ${GROUP_TITLE}"
  fi
}

startGitHubActionsLogGroup() {
  writeGitHubActionsLogGroupMarker "${GITHUB_ACTIONS_LOG_GROUP_MARKER_START}" "${1}"
}

endGitHubActionsLogGroup() {
  writeGitHubActionsLogGroupMarker "${GITHUB_ACTIONS_LOG_GROUP_MARKER_END}" "${1}"
}

# We need these functions to be available when using parallel to run subprocesses
export -f debug
export -f endGitHubActionsLogGroup
export -f error
export -f fatal
export -f info
export -f log
export -f notice
export -f startGitHubActionsLogGroup
export -f warn
export -f writeGitHubActionsLogGroupMarker
