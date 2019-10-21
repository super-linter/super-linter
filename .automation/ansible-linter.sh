#!/bin/bash

################################################################################
################## Ansible Linter @admiralawkbar ###############################
################################################################################

###########
# GLOBALS #
###########
BUILD_DIR=$(pwd 2>&1)                                 # Current Build dir
ANSIBLE_LINTER_FILE=".automation/.ansible-lint"     # Name of the Linter file
ANSIBLE_DIR="$BUILD_DIR/ansible"                      # Ansible directory

############
# Counters #
############
ERRORS_FOUND_ANSIBLE=0     # Count of errors found

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "-----------------------------------"
  echo "---------- Ansible Linter ---------"
  echo "-----------------------------------"
  echo ""
}
################################################################################
#### Function LintAnsibleFiles #################################################
LintAnsibleFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "--------------------------------"
  echo "Linting Ansible files..."
  echo "--------------------------------"
  echo ""

  ##########################################
  # Validate we have the linter rules file #
  ##########################################
  if [ ! -f "$ANSIBLE_LINTER_FILE" ]; then
    # Error
    echo "ERROR! Failed to find rules file at:[$ANSIBLE_LINTER_FILE]"
    exit 1
  fi

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="ansible-lint"

  ###########################################
  # Validate we have ansible-lint installed #
  ###########################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(which "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2164,SC2010
  LIST_FILES=($(cd "$ANSIBLE_DIR"; ls -I vault.yml -I galaxy.yml | grep ".yml" 2>&1))

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$ANSIBLE_DIR/$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" -v -c "$ANSIBLE_LINTER_FILE" "$ANSIBLE_DIR/$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_ANSIBLE++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function Footer ###########################################################
Footer()
{
  echo ""
  echo "---------------------------"
  echo "The script has completed"
  echo "---------------------------"
  echo "ERRORS FOUND in ANSIBLE:[$ERRORS_FOUND_ANSIBLE]"
  echo ""

  ###############################
  # Exit with 1 if errors found #
  ###############################
  if [ $ERRORS_FOUND_ANSIBLE -ne 0 ]; then
    # Failed exit
    echo "Exiting with errors found!"
    exit 1
  else
    # Successful exit
    exit 0
  fi
}
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

##########################
# Lint the Ansible files #
##########################
LintAnsibleFiles

##########
# Footer #
##########
Footer
