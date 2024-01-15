#!/usr/bin/env bash

# Background colors:
# Blue
# Cyan
# Green
# Black
# Magenta
# Red
# White
# Yellow
declare -Agr B=(
  [B]=$(echo -e "\e[44m")
  [C]=$(echo -e "\e[46m")
  [G]=$(echo -e "\e[42m")
  [K]=$(echo -e "\e[40m")
  [M]=$(echo -e "\e[45m")
  [R]=$(echo -e "\e[41m")
  [W]=$(echo -e "\e[47m")
  [Y]=$(echo -e "\e[43m")
)

# Foreground colors:
# Blue
# Cyan
# Green
# Black
# Magenta
# Red
# White
# Yellow
declare -Agr F=(
  [B]=$(echo -e "\e[0;34m")
  [C]=$(echo -e "\e[0;36m")
  [G]=$(echo -e "\e[0;32m")
  [K]=$(echo -e "\e[0;30m")
  [M]=$(echo -e "\e[0;35m")
  [R]=$(echo -e "\e[0;31m")
  [W]=$(echo -e "\e[0;37m")
  [Y]=$(echo -e "\e[0;33m")
)

# Reset
NC=$(echo -e "\e[0m")
readonly NC

export B
export F
export NC

LOG_TEMP=$(mktemp) || echo "Failed to create temporary log file."
export LOG_TEMP

log() {
  local TOTERM=${1:-}
  local MESSAGE=${2:-}
  local LOG_LEVEL_LABEL="${3}"

  local LOG_MESSAGE_DATE
  LOG_MESSAGE_DATE="$(date +"%F %T")"
  local COLOR_MARKER
  COLOR_MARKER="${F[B]}"

  if [ "${LOG_LEVEL_LABEL}" == "NOTICE" ]; then
    COLOR_MARKER="${F[G]}"
  elif [ "${LOG_LEVEL_LABEL}" == "WARN" ]; then
    COLOR_MARKER="${F[Y]}"
  elif [ "${LOG_LEVEL_LABEL}" == "ERROR" ] || [ "${LOG_LEVEL_LABEL}" == "FATAL" ]; then
    COLOR_MARKER="${F[R]}"
  fi

  LOG_LEVEL_LABEL="[${LOG_LEVEL_LABEL}]"

  local COLORED_MESSAGE
  COLORED_MESSAGE="${NC}${LOG_MESSAGE_DATE} ${COLOR_MARKER}${LOG_LEVEL_LABEL}${NC}   ${MESSAGE}${NC}"
  local MESSAGE_FOR_LOG_FILE
  MESSAGE_FOR_LOG_FILE="${LOG_MESSAGE_DATE} ${LOG_LEVEL_LABEL}   ${MESSAGE}"

  if [[ -n ${TOTERM} ]]; then
    echo -e "${COLORED_MESSAGE}"
  fi

  if [ "${CREATE_LOG_FILE}" = "true" ]; then
    echo -e "${MESSAGE_FOR_LOG_FILE}" >>"${LOG_TEMP}"
  fi
}

trace() { log "${LOG_TRACE:-}" "$*" "TRACE"; }
debug() { log "${LOG_DEBUG:-}" "$*" "DEBUG"; }
info() { log "${LOG_VERBOSE:-}" "$*" "INFO"; }
notice() { log "${LOG_NOTICE:-}" "$*" "NOTICE"; }
warn() { log "${LOG_WARN:-}" "$*" "WARN"; }
error() { log "${LOG_ERROR:-}" "$*" "ERROR"; }
fatal() {
  log "true" "$*" "FATAL"
  exit 1
}

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
export -f trace
export -f warn
export -f writeGitHubActionsLogGroupMarker
