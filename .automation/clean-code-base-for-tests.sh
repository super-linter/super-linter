#!/usr/bin/env bash

################################################################################
############# Clean all code base for additonal testing @admiralawkbar #########
################################################################################

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}" # GitHub Workspace
TEST_FOLDER='.automation/test'
CLEAN_FOLDER'.automation/automation'
# shellcheck source=/dev/null
source "${GITHUB_WORKSPACE}/lib/log.sh" # Source the function script(s)

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
#### Function CleanTestFiles ###################################################
CleanTestFiles() {
  info "-------------------------------------------------------"
  info "Finding all tests that are supposed to fail... and removing them..."

  ##################
  # Find the files #
  ##################
  mapfile -t FIND_CMD < <(cd "${GITHUB_WORKSPACE}" || exit 1 ; find "${GITHUB_WORKSPACE}" -type f -name "*_bad_*" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    error "ERROR! failed to get list of all files!"
    fatal "ERROR:[${FIND_CMD[*]}]"
  fi

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
      REMOVE_FILE_CMD=$(cd "${GITHUB_WORKSPACE}" || exit 1; rm -f "$FILE" 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ $ERROR_CODE -ne 0 ]; then
        error "ERROR! failed to remove file:[${FILE}]!"
        fatal "ERROR:[${REMOVE_FILE_CMD[*]}]"
      fi
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
  mapfile -t FIND_CMD < <(cd "${GITHUB_WORKSPACE}" || exit 1 ; find "${GITHUB_WORKSPACE}" -type f -name "*Dockerfile" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    error "ERROR! failed to get list of all file for Docker!"
    fatal "ERROR:[${FIND_CMD[*]}]"
  fi

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
    if [[ $FILE_DIR == **".automation/test/docker/bad"** ]]; then
      ################################
      # Its a test, we can delete it #
      ################################
      REMOVE_FILE_CMD=$(cd "${GITHUB_WORKSPACE}" || exit 1; rm -f "$FILE" 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ $ERROR_CODE -ne 0 ]; then
        error "ERROR! failed to remove file:[${FILE}]!"
        fatal "ERROR:[${REMOVE_FILE_CMD[*]}]"
      fi
    fi
  done
}
################################################################################
#### Function RenameTestFolder #################################################
RenameTestFolder() {
  info "-------------------------------------------------------"
  info "Need to rename [tests] folder as it will be ignored..."

  #####################
  # Rename the folder #
  #####################
  RENAME_FOLDER_CMD=$(cd "${GITHUB_WORKSPACE}" || exit 1; mv "${TEST_FOLDER}" "${CLEAN_FOLDER}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    error "ERROR! failed to move test folder!"
    fatal "ERROR:[${RENAME_FOLDER_CMD[*]}]"
  fi
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

##################
# Re Name folder #
##################
RenameTestFolder
