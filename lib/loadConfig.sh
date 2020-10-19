#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter Validation Functions @admiralawkbar ###################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function LoadConfigFile ###################################################
function LoadConfigFile() {
  ############################################
  # Print headers for user provided env vars #
  ############################################
  info "--------------------------------------------"
  info "Validation and extraction of config file:[${SUPER_LINTER_CONFIG_FILE}]..."

  ##################################
  # Check if file exists on system #
  ##################################
  if [ ! -f "${SUPER_LINTER_CONFIG_FILE}" ]; then
    # Does not exist
    warn "Config file:[${SUPER_LINTER_CONFIG_FILE}] not found in repository, will use ENV vars only!"
    warn "This will be deprecated in v4+!"
  fi

  ##################
  # Get Debug Vars #
  ##################
  GetConfigVars "DEBUG"

  #########################
  # Get Super-Linter Vars #
  #########################
  GetConfigVars "SUPERLINTER"

  #####################
  # Get Language Vars #
  #####################
  GetConfigVars "LANGUAGES"
}
################################################################################
#### Function GetConfigVars ####################################################
function GetConfigVars() {

  ################
  # Pull in vars #
  ################
  SECTION="$1"

  # yq will return data in array iun format:
  # bash-5.0# yq -r  ".SUPERLINTER" config.yml
  # {
  #   "DEFAULT_BRANCH": "master",
  #   "DEFAULT_WORKSPACE": "/tmp/lint",
  #   "DISABLE_ERRORS": false,
  #   "FILTER_REGEX_EXCLUDE": null,
  #   "FILTER_REGEX_INCLUDE": null,
  #   "LINTER_RULES_PATH": ".github/linters",
  #   "LOG_FILE": "super-linter.log",
  #   "LOG_LEVEL": "VERBOSE",
  #   "MULTI_STATUS": true,
  #   "OUTPUT_FORMAT": "none",
  #   "OUTPUT_FOLDER": "super-linter.report",
  #   "OUTPUT_DETAILS": "simpler",
  #   "VALIDATE_ALL_CODEBASE": true
  # }

  ########################################
  # Grab all vars from config in section #
  ########################################
  mapfile -t GET_ALL_VARS_CMD < <(yq -r ".${SECTION}" "${SUPER_LINTER_CONFIG_FILE}" 2>&1)

  ###################
  # Load error code #
  ###################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Error
    error "Failed to parse Section:[${SECTION}] of:[${SUPER_LINTER_CONFIG_FILE}]"
  fi

  ##############################################
  # Check we have data to validate for section #
  ##############################################
  if [ "${#GET_ALL_VARS_CMD}" -eq 0 ]; then
    # No vars to load for section
    info "No vars defined for:[${SECTION}]"
  else
    ########################
    # Need to Set the Vars #
    ########################
    mapfile -t CLEANED_VAR_ARRAY < <(CleanVarArray "${GET_ALL_VARS_CMD[@]}")
  fi
}
################################################################################
#### Function CleanVarArray ####################################################
function CleanVarArray() {

  #####################
  # Pull in the array #
  #####################
  ARRAY=("$@")

  ##########################################
  # Need to clean up the array for parsing #
  ##########################################
  if [ "${ARRAY[0]}" == "{" ]; then
    ARRAY=("${ARRAY[@]:1}") #removed the 1st element
  fi


}
################################################################################
################################################################################
