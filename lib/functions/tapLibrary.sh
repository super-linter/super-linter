#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions @admiralawkbar ######################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function IsTap ############################################################
function IsTAP() {
  if [ "${OUTPUT_FORMAT}" == "tap" ]; then
    return 0
  else
    return 1
  fi
}
################################################################################
#### Function TransformTAPDetails ##############################################
function TransformTAPDetails() {
  DATA=${1}
  if [ -n "${DATA}" ] && [ "${OUTPUT_DETAILS}" == "detailed" ]; then
    ############################################################
    # Transform new lines to \\n, remove colours and colons.   #
    # Additionally, remove some dynamic parts from generated   #
    # reports.                                                 #
    ############################################################
    echo "${DATA}" |
      awk 'BEGIN{RS="\n";ORS="\\n"}1' |
      sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" |
      sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' |
      sed -r "s/\s\([0-9]*\sms\)//g" |
      sed -r "s/\s[0-9]*ms//g" |
      sed -r "s/S[0-9]{4}//g" |
      sed -r "s/js:[0-9]*:[0-9]*/js/g" |
      sed -r "s/[.0-9]*\sseconds/seconds/g" |
      sed -r "s/\[terragrunt\]\s[0-9]{4}\/[0-9]{2}\/[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}/[terragrunt]/g" |
      sed -r "s/(after|before)\s[0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{1,6}/before/g" |
      sed -r "s/used\s[0-9]{1,}\.*[0-9]{0,}MB\sof\smemory/used/g" |
      tr ':' ' '
  fi
}
################################################################################
#### Function HeaderTap ########################################################
function HeaderTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"       # File being validated
  OUTPUT_FILE="${2}" # Output location

  ###################
  # Print the goods #
  ###################
  printf "TAP version 13\n1..%s\n" "${INDEX}" >"${OUTPUT_FILE}"
}
################################################################################
#### Function OkTap ############################################################
function OkTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"     # Location
  FILE="${2}"      # File being validated
  TEMP_FILE="${3}" # Temp file location

  ###################
  # Print the goods #
  ###################
  echo "ok ${INDEX} - ${FILE}" >>"${TEMP_FILE}"
}
################################################################################
#### Function NotOkTap #########################################################
function NotOkTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"     # Location
  FILE="${2}"      # File being validated
  TEMP_FILE="${3}" # Temp file location

  ###################
  # Print the goods #
  ###################
  echo "not ok ${INDEX} - ${FILE}" >>"${TEMP_FILE}"
}
################################################################################
#### Function AddDetailedMessageIfEnabled ######################################
function AddDetailedMessageIfEnabled() {
  ################
  # Pull in Vars #
  ################
  LINT_CMD="${1}"  # Linter command
  TEMP_FILE="${2}" # Temp file

  ####################
  # Check the return #
  ####################
  DETAILED_MSG=$(TransformTAPDetails "${LINT_CMD}")
  if [ -n "${DETAILED_MSG}" ]; then
    printf "  ---\n  message: %s\n  ...\n" "${DETAILED_MSG}" >>"${TEMP_FILE}"
  fi
}
################################################################################
#### Function Reports ##########################################################
Reports() {
  info "----------------------------------------------"
  info "----------------------------------------------"
  info "Generated reports:"
  info "----------------------------------------------"
  info "----------------------------------------------"

  ###################################
  # Prints output report if enabled #
  ###################################
  if [ -z "${FORMAT_REPORT}" ]; then
    info "Reports generated in folder ${REPORT_OUTPUT_FOLDER}"
    #############################################
    # Print info on reports that were generated #
    #############################################
    if [ -d "${REPORT_OUTPUT_FOLDER}" ]; then
      info "Contents of report folder:"
      OUTPUT_CONTENTS_CMD=$(ls "${REPORT_OUTPUT_FOLDER}")
      info "$OUTPUT_CONTENTS_CMD"
    else
      warn "Report output folder (${REPORT_OUTPUT_FOLDER}) does NOT exist."
    fi
  fi
}
################################################################################
