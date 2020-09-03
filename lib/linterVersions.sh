#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter (Get the linter versions) @admiralawkbar ##############
################################################################################
################################################################################

#########################
# Source Function Files #
#########################
# shellcheck source=/dev/null
source /action/lib/log.sh # Source the function script(s)

###########
# GLOBALS #
###########
MAIN_FILE='/action/lib/linter.sh'               # Main file for super-linter
VERSION_FILE='/action/lib/linter-versions.txt'  # File to store linter versions
LINTER_ARRAY=()                                 # Array of languages to get versions
DEFAULT_IFS="${IFS}"                            # Get the Default IFS for updating
ARM_TTK_PSD1='/usr/bin/arm-ttk'                 # Powershell var

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function GetLinterArray ###################################################
GetLinterArray() {
  ##################################
  # Make sure we can find the file #
  ##################################
  if [ ! -f "${MAIN_FILE}" ]; then
    fatal "Failed to find:[${MAIN_FILE}]"
  fi

  ###############################
  # Get the array from the file #
  ###############################
  RAW_DATA=$(awk '/LINTER_ARRAY=\(/,/\)/' "${MAIN_FILE}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    error "Failed to get data from:[${MAIN_FILE}]"
    fatal "RAW_DATA:[$RAW_DATA]"
  fi

  #################################
  # Split the trash off the front #
  #################################
  CLEANER_DATA=$(echo "${RAW_DATA}" | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n')

  #####################################################
  # Remove first and last "'" for easy breaking apart #
  #####################################################
  MORE_CLEAN=$(echo "${CLEANER_DATA:1:${#CLEANER_DATA}-2}")

  ##########################
  # Set IFS for this event #
  ##########################
  IFS="' '"

  ##################
  # Load the array #
  ##################
  read -r -a LINTER_ARRAY <<< "${MORE_CLEAN}"

  ################
  # Set IFS back #
  ################
  IFS="${DEFAULT_IFS}"
}
################################################################################
#### Function GetLinterVersions ################################################
GetLinterVersions() {
  #########################
  # Print version headers #
  #########################
  info "---------------------------------------------"
  info "Linter Version Info:"

  ##########################################################
  # Go through the array of linters and print version info #
  ##########################################################
  for LINTER in "${LINTER_ARRAY[@]}"; do
    if [ -n "${LINTER}" ]; then
      echo "Linter:[${LINTER}]"
      ####################
      # Get the versions #
      ####################
      if [[ ${LINTER} == "arm-ttk" ]]; then
        # Need specific command for ARM
        mapfile -t GET_VERSION_CMD < <(grep -iE 'version' "${ARM_TTK_PSD1}" | xargs 2>&1)
      elif [[ ${LINTER} == "protolint" ]] || [[ ${LINTER} == "editorconfig-checker" ]] || [[ ${LINTER} == "bash-exec" ]]; then
        # Need specific command for Protolint and editorconfig-checker
        mapfile -t GET_VERSION_CMD < <(echo "--version not supported")
      elif [[ ${LINTER} == "lintr" ]]; then
        # Need specific command for lintr (--slave is deprecated in R 4.0 and replaced by --no-echo)
        mapfile -t GET_VERSION_CMD < <(R --slave -e "r_ver <- R.Version()\$version.string; \
                    lintr_ver <- packageVersion('lintr'); \
                    glue::glue('lintr { lintr_ver } on { r_ver }')")
      elif [[ ${LINTER} == "lua" ]]; then
        # Semi standardversion command
        mapfile -t GET_VERSION_CMD < <("${LINTER}" -v 2>&1)
      elif [[ ${LINTER} == "terrascan" ]]; then
        mapfile -t GET_VERSION_CMD < <("${LINTER}" version 2>&1)
      elif [[ ${LINTER} == "checkstyle" ]]; then
        mapfile -t GET_VERSION_CMD < <("java -jar /usr/bin/${LINTER}" --version 2>&1)
      else
        # Standard version command
        mapfile -t GET_VERSION_CMD < <("${LINTER}" --version 2>&1)
      fi

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ ${ERROR_CODE} -ne 0 ] || [ -z "${GET_VERSION_CMD[*]}" ]; then
        warn "[${LINTER}]: Failed to get version info for:"
        WriteFile "${LINTER}" "Failed to get version info"
      else
        ##########################
        # Print the version info #
        ##########################
        info "Successfully found version for ${F[W]}[${LINTER}]${F[B]}: ${F[W]}${GET_VERSION_CMD[*]}"
        WriteFile "${LINTER}" "${GET_VERSION_CMD}"
      fi
    fi
  done

  #########################
  # Print version footers #
  #########################
  info "---------------------------------------------"
}
################################################################################
#### Function WriteFile ########################################################
WriteFile() {
  ##############
  # Read Input #
  ##############
  LINTER="$1"   # Name of the linter
  VERSION="$2"  # Version returned from check

  #################################
  # Write the data to output file #
  #################################
  WRITE_CMD=$(echo "${LINTER}: ${VERSION}" >> "${VERSION_FILE}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    fatal "Failed to write data to file:[${WRITE_CMD}]"
  fi
}
################################################################################
############################### MAIN ###########################################
################################################################################

###########################
# Get the languages array #
###########################
GetLinterArray

#####################
# GetLinterVersions #
#####################
GetLinterVersions
