#!/usr/bin/env bash

LinterRulesLocation() {
  # We need to see if the user has set the rules location to the root
  # directory, or to some nested folder
  if [ "${LINTER_RULES_PATH}" == '.' ] || [ "${LINTER_RULES_PATH}" == '/' ]; then
    LINTER_RULES_PATH=''
  fi
}

GetLinterRules() {
  LANGUAGE_NAME="${1}"
  DEFAULT_RULES_LOCATION="${2}"

  LANGUAGE_FILE_NAME="${LANGUAGE_NAME}_FILE_NAME"
  LANGUAGE_LINTER_RULES="${LANGUAGE_NAME}_LINTER_RULES"
  debug "Initializing linter configuration file for ${LANGUAGE_NAME}. Variable names for language file name: ${LANGUAGE_FILE_NAME}, language linter rules: ${LANGUAGE_LINTER_RULES}"

  # Check if the language rules variables are defined
  if [ -z "${!LANGUAGE_FILE_NAME+x}" ]; then
    debug "${LANGUAGE_FILE_NAME} is not set. Skipping loading configuration file for ${LANGUAGE_NAME}..."
    return
  fi

  eval "${LANGUAGE_LINTER_RULES}="

  SET_RULES=0

  #####################################
  # Validate we have the linter rules #
  #####################################
  LANGUAGE_FILE_PATH=''
  if [ -z "${LINTER_RULES_PATH}" ]; then
    LANGUAGE_FILE_PATH="${GITHUB_WORKSPACE}/${!LANGUAGE_FILE_NAME}"
  else
    LANGUAGE_FILE_PATH="${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${!LANGUAGE_FILE_NAME}"
  fi

  debug "Checking if the user-provided ${!LANGUAGE_FILE_NAME} configuration file exists at ${LANGUAGE_FILE_PATH}"
  if [ -f "${LANGUAGE_FILE_PATH}" ]; then
    info "User-provided configuration file (${LANGUAGE_FILE_PATH}) exists"
    eval "${LANGUAGE_LINTER_RULES}=${LANGUAGE_FILE_PATH}"
    SET_RULES=1
  else
    debug "User-provided configuration file (${LANGUAGE_FILE_PATH}) doesn't exist"
  fi

  if [ "${SET_RULES}" -eq 0 ]; then
    eval "${LANGUAGE_LINTER_RULES}=${DEFAULT_RULES_LOCATION}/${!LANGUAGE_FILE_NAME}"
    debug "Using the default configuration file for ${LANGUAGE_NAME} at: ${!LANGUAGE_LINTER_RULES}"
    SET_RULES=1
  fi
  debug "Configuration file path variable (${LANGUAGE_LINTER_RULES}) value is: ${!LANGUAGE_LINTER_RULES}"

  if [ -e "${!LANGUAGE_LINTER_RULES}" ]; then
    debug "${LANGUAGE_LINTER_RULES} configuration file (${!LANGUAGE_LINTER_RULES}) exists"
  else
    local LANGUAGE_LINTER_RULES_BASENAME
    LANGUAGE_LINTER_RULES_BASENAME="$(basename "${!LANGUAGE_LINTER_RULES}")"
    debug "LANGUAGE_LINTER_RULES_BASENAME: ${LANGUAGE_LINTER_RULES_BASENAME}"
    # checkstyle embeds some configuration files, such as google_checks.xml and sun_checks.xml.
    # If we or the user specified one of those files and the file is missing, fall back to
    # the embedded one.
    if [[ "${LANGUAGE_NAME}" == "JAVA" && ("${LANGUAGE_LINTER_RULES_BASENAME}" == "google_checks.xml" || "${LANGUAGE_LINTER_RULES_BASENAME}" == "sun_checks.xml") ]]; then
      debug "${!LANGUAGE_LINTER_RULES} for ${LANGUAGE_NAME} doesn't exist. Falling back to ${LANGUAGE_LINTER_RULES_BASENAME} that the linter ships."
      eval "${LANGUAGE_LINTER_RULES}=/${LANGUAGE_LINTER_RULES_BASENAME}"
      debug "Updated ${LANGUAGE_LINTER_RULES}: ${!LANGUAGE_LINTER_RULES}"
    else
      # Here we expect a rules file, so fail if not available.
      fatal "${LANGUAGE_LINTER_RULES} rules file (${!LANGUAGE_LINTER_RULES}) doesn't exist. Terminating..."
    fi
  fi
  eval "export ${LANGUAGE_LINTER_RULES}"
}
