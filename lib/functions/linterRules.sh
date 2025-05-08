#!/usr/bin/env bash

LinterRulesLocation() {
  # We need to see if the user has set the rules location to the root
  # directory, or to some nested folder
  if [ "${LINTER_RULES_PATH}" == '.' ] || [ "${LINTER_RULES_PATH}" == '/' ]; then
    LINTER_RULES_PATH=''
  fi
}
################################################################################
#### Function GetLinterRules ###################################################
GetLinterRules() {
  # Need to validate the rules files exist

  ################
  # Pull in vars #
  ################
  LANGUAGE_NAME="${1}" # Name of the language were looking for
  debug "Getting linter rules for ${LANGUAGE_NAME}..."

  DEFAULT_RULES_LOCATION="${2}"
  debug "Default rules location: ${DEFAULT_RULES_LOCATION}..."

  #######################################################
  # Need to create the variables for the real variables #
  #######################################################
  LANGUAGE_FILE_NAME="${LANGUAGE_NAME}_FILE_NAME"
  LANGUAGE_LINTER_RULES="${LANGUAGE_NAME}_LINTER_RULES"
  debug "Variable names for language file name: ${LANGUAGE_FILE_NAME}, language linter rules: ${LANGUAGE_LINTER_RULES}"

  #####################################################
  # Check if the language rules variables are defined #
  #####################################################
  if [ -z "${!LANGUAGE_FILE_NAME+x}" ]; then
    debug "${LANGUAGE_FILE_NAME} is not set. Skipping loading rules for ${LANGUAGE_NAME}..."
    return
  fi

  debug "Initializing LANGUAGE_LINTER_RULES value to an empty string..."
  eval "${LANGUAGE_LINTER_RULES}="

  ###############################
  # Set Flag for set Rules File #
  ###############################
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

  debug "Checking if the user-provided:[${!LANGUAGE_FILE_NAME}] and exists at:[${LANGUAGE_FILE_PATH}]"
  if [ -f "${LANGUAGE_FILE_PATH}" ]; then
    info "----------------------------------------------"
    info "User provided file:[${LANGUAGE_FILE_PATH}] exists, setting rules file..."

    ########################################
    # Update the path to the file location #
    ########################################
    eval "${LANGUAGE_LINTER_RULES}=${LANGUAGE_FILE_PATH}"
    ######################
    # Set the rules flag #
    ######################
    SET_RULES=1
  else
    # Failed to find the primary rules file
    debug "  -> Codebase does NOT have file:[${LANGUAGE_FILE_PATH}]."
  fi

  ##############################################################
  # We didnt find rules from user, setting to default template #
  ##############################################################
  if [ "${SET_RULES}" -eq 0 ]; then
    ########################################################
    # No user default provided, using the template default #
    ########################################################
    eval "${LANGUAGE_LINTER_RULES}=${DEFAULT_RULES_LOCATION}/${!LANGUAGE_FILE_NAME}"
    debug "  -> Codebase does NOT have file:[${LANGUAGE_FILE_PATH}], using default rules at:[${!LANGUAGE_LINTER_RULES}]"
    ######################
    # Set the rules flag #
    ######################
    SET_RULES=1
  fi

  ####################
  # Debug Print info #
  ####################
  debug "  -> Language rules file variable (${LANGUAGE_LINTER_RULES}) value is:[${!LANGUAGE_LINTER_RULES}]"

  ############################
  # Validate the file exists #
  ############################
  if [ -e "${!LANGUAGE_LINTER_RULES}" ]; then
    # Found the rules file
    debug "  -> ${LANGUAGE_LINTER_RULES} rules file (${!LANGUAGE_LINTER_RULES}) exists."
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
      fatal "  -> ${LANGUAGE_LINTER_RULES} rules file (${!LANGUAGE_LINTER_RULES}) doesn't exist. Terminating..."
    fi
  fi

  ######################
  # Export the results #
  ######################
  eval "export ${LANGUAGE_LINTER_RULES}"
}
