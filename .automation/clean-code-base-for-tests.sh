#!/usr/bin/env bash

################################################################################
############# Clean all code base for additonal testing @admiralawkbar #########
################################################################################

###########
# Globals #
###########
((LOG_TRACE = LOG_DEBUG = LOG_VERBOSE = LOG_NOTICE = LOG_WARN = LOG_ERROR = "true")) # Enable all loging
export LOG_TRACE LOG_DEBUG LOG_VERBOSE LOG_NOTICE LOG_WARN LOG_ERROR

############################
# Source additonal scripts #
############################
# shellcheck source=/dev/null
source "${GITHUB_WORKSPACE}/lib/functions/log.sh" # Source the function script(s)

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  info "-------------------------------------------------------"
  info "------- GitHub Clean code base of error tests ---------"
  info "-------------------------------------------------------"
}
################################################################################
#### Function CheckShellErrors #################################################
CheckShellErrors() {
  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    error "$1"
    fatal "$2"
  fi
}
################################################################################
#### Function CleanTestFiles ###################################################
CleanTestFiles() {
  info "-------------------------------------------------------"
  info "Finding all tests that are supposed to fail... and removing them..."

  ##################
  # Find the files #
  ##################
  mapfile -t FIND_CMD < <(
    cd "${GITHUB_WORKSPACE}" || exit 1
    find "${GITHUB_WORKSPACE}" -type f -name "*_bad_*" -o -path "*javascript_prettier*" -name "*javascript_good*" 2>&1
  )

  CheckShellErrors "ERROR! failed to get list of all files!" "ERROR:[${FIND_CMD[*]}]"

  ############################################################
  # Get the directory and validate it came from tests folder #
  ############################################################
  for FILE in "${FIND_CMD[@]}"; do
    #####################
    # Get the directory #
    #####################
    FILE_DIR=$(dirname "$FILE" 2>&1)

    ##################################
    # Check if from the tests folder #
    ##################################
    if [[ $FILE_DIR == **".automation/test"** ]]; then
      ################################
      # Its a test, we can delete it #
      ################################
      REMOVE_FILE_CMD=$(
        cd "${GITHUB_WORKSPACE}" || exit 1
        sudo rm -f "$FILE" 2>&1
      )

      CheckShellErrors "ERROR! failed to remove file:[${FILE}]!" "ERROR:[${REMOVE_FILE_CMD[*]}]"
    fi
  done
}
################################################################################
#### Function CleanTestDockerFiles #############################################
CleanTestDockerFiles() {
  info "-------------------------------------------------------"
  info "Finding all tests that are supposed to fail for Docker... and removing them..."

  ##################
  # Find the files #
  ##################
  mapfile -t FIND_CMD < <(
    cd "${GITHUB_WORKSPACE}" || exit 1
    find "${GITHUB_WORKSPACE}" -type f -name "*Dockerfile" -o -name "*.dockerignore" 2>&1
  )

  CheckShellErrors "ERROR! failed to get list of all file for Docker!" "ERROR:[${FIND_CMD[*]}]"

  ############################################################
  # Get the directory and validate it came from tests folder #
  ############################################################
  for FILE in "${FIND_CMD[@]}"; do
    #####################
    # Get the directory #
    #####################
    FILE_DIR=$(dirname "$FILE" 2>&1)

    ##################################
    # Check if from the tests folder #
    ##################################
    if [[ $FILE_DIR != **".automation/test/docker/good"** ]]; then
      ################################
      # Its a test, we can delete it #
      ################################
      REMOVE_FILE_CMD=$(
        cd "${GITHUB_WORKSPACE}" || exit 1
        sudo rm -f "$FILE" 2>&1
      )

      CheckShellErrors "ERROR! failed to remove file:[${FILE}]!" "ERROR:[${REMOVE_FILE_CMD[*]}]"
    fi
  done
}
################################################################################
#### Function CleanSHAFolder ###################################################
CleanSHAFolder() {
  info "-------------------------------------------------------"
  info "Cleaning folder named:[${GITHUB_SHA}] if it exists"

  ##################
  # Find the files #
  ##################
  REMOVE_CMD=$(
    cd "${GITHUB_WORKSPACE}" || exit 1
    sudo rm -rf "${GITHUB_SHA}" 2>&1
  )

  CheckShellErrors "ERROR! Failed to remove folder:[${GITHUB_SHA}]!" "ERROR:[${REMOVE_CMD}]"
}
################################################################################
#### Function CleanPowershell ##################################################
CleanPowershell() {
  # Need to remove the .psd1 templates as they are formally parsed,
  # and will fail with missing modules

  info "-------------------------------------------------------"
  info "Finding powershell template files... and removing them..."

  ##################
  # Find the files #
  ##################
  mapfile -t FIND_CMD < <(
    cd "${GITHUB_WORKSPACE}" || exit 1
    find "${GITHUB_WORKSPACE}" -type f -name "*.psd1" 2>&1
  )

  CheckShellErrors "ERROR! failed to get list of all file for *.psd1!" "ERROR:[${FIND_CMD[*]}]"

  ############################################################
  # Get the directory and validate it came from tests folder #
  ############################################################
  for FILE in "${FIND_CMD[@]}"; do
    #####################
    # Get the directory #
    #####################
    FILE_DIR=$(dirname "$FILE" 2>&1)

    ##################################
    # Check if from the tests folder #
    ##################################
    if [[ $FILE_DIR == **"TEMPLATES"** ]]; then
      ################################
      # Its a test, we can delete it #
      ################################
      REMOVE_FILE_CMD=$(
        cd "${GITHUB_WORKSPACE}" || exit 1
        sudo rm -f "$FILE" 2>&1
      )

      CheckShellErrors "ERROR! failed to remove file:[${FILE}]!" "ERROR:[${REMOVE_FILE_CMD[*]}]"
    fi
  done
}
################################################################################
################################## MAIN ########################################
################################################################################

##########
# Header #
##########
Header

####################
# Clean test files #
####################
CleanTestFiles

###############################
# Clean the test docker files #
###############################
CleanTestDockerFiles

###############################
# Remove sha folder if exists #
###############################
CleanSHAFolder

##############################
# Clean Powershell templates #
##############################
CleanPowershell
