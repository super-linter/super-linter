#!/bin/bash

################################################################################
################## Scripting Language Linter @admiralawkbar ####################
################################################################################

###########
# GLOBALS #
###########
APT_PACKAGE_ARRAY=()      # Packages to install using APT
GEM_PACKAGE_ARRAY=()      # Packages to install using GEM
NPM_PACKAGE_ARRAY=()      # Packages to install using NPM
PIP_PACKAGE_ARRAY=(
  "ansible-lint==4.0.1")         # Packages to install using PIP

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "------------------------------"
  echo "---- Install Dependancies ----"
  echo "------------------------------"
}
################################################################################
#### Function InstallAptPackages ###############################################
InstallAptPackages()
{
  ######################################################
  # Convert Array to string for single pass to install #
  ######################################################
  INSTALL_PACKAGE_STRING=$(ConvertArray "${APT_PACKAGE_ARRAY[@]}")

  ###############################
  # Check the string for length #
  ###############################
  LENGTH=${#INSTALL_PACKAGE_STRING}

  #############################
  # Skip loop if no variables #
  #############################
  if [ "$LENGTH" -le 1 ]; then
    echo ""
    echo "------------------------------"
    echo "No APT package(s) to install... skipping..."
  else
    ###########
    # Headers #
    ###########
    echo ""
    echo "------------------------------"
    echo "Installing APT package(s)"
    echo "Packages:[$INSTALL_PACKAGE_STRING]"
    echo "This could take several moments..."

    ####################################
    # Need to install all APT packages #
    ####################################
    # shellcheck disable=SC2086
    INSTALL_CMD=$(sudo apt-get install $INSTALL_PACKAGE_STRING -y 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # Error
      echo "ERROR! Failed to install APT packages!"
      echo "ERROR:[$INSTALL_CMD]"
      exit 1
    else
      # Success
      echo "Successfully installed all APT packages"
    fi
  fi
}
################################################################################
#### Function InstallPipPackages ###############################################
InstallPipPackages()
{
  ######################################################
  # Convert Array to string for single pass to install #
  ######################################################
  INSTALL_PACKAGE_STRING=$(ConvertArray "${PIP_PACKAGE_ARRAY[@]}")

  ###############################
  # Check the string for length #
  ###############################
  LENGTH=${#INSTALL_PACKAGE_STRING}

  #############################
  # Skip loop if no variables #
  #############################
  if [ "$LENGTH" -le 1 ]; then
    echo ""
    echo "------------------------------"
    echo "No PIP package(s) to install... skipping..."
  else
    ###########
    # Headers #
    ###########
    echo ""
    echo "------------------------------"
    echo "Installing PIP package(s)"
    echo "Packages:[$INSTALL_PACKAGE_STRING]"
    echo "This could take several moments..."

    ####################################
    # Need to install all APT packages #
    ####################################
    # shellcheck disable=SC2086
    INSTALL_CMD=$(sudo -H pip install $INSTALL_PACKAGE_STRING 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # Error
      echo "ERROR! Failed to install PIP packages!"
      echo "ERROR:[$INSTALL_CMD]"
      exit 1
    else
      # Success
      echo "Successfully installed all PIP packages"
    fi
  fi
}
################################################################################
#### Function InstallGemPackages ###############################################
InstallGemPackages()
{
  ######################################################
  # Convert Array to string for single pass to install #
  ######################################################
  INSTALL_PACKAGE_STRING=$(ConvertArray "${GEM_PACKAGE_ARRAY[@]}")

  ###############################
  # Check the string for length #
  ###############################
  LENGTH=${#INSTALL_PACKAGE_STRING}

  #############################
  # Skip loop if no variables #
  #############################
  if [ "$LENGTH" -le 1 ]; then
    echo ""
    echo "------------------------------"
    echo "No GEM package(s) to install... skipping..."
  else
    ###########
    # Headers #
    ###########
    echo ""
    echo "------------------------------"
    echo "Installing GEM package(s)"
    echo "Packages:[$INSTALL_PACKAGE_STRING]"
    echo "This could take several moments..."

    ####################################
    # Need to install all APT packages #
    ####################################
    # shellcheck disable=SC2086
    INSTALL_CMD=$(gem install $INSTALL_PACKAGE_STRING 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # Error
      echo "ERROR! Failed to install GEM packages!"
      echo "ERROR:[$INSTALL_CMD]"
      exit 1
    else
      # Success
      echo "Successfully installed all GEM packages"
    fi
  fi
}
################################################################################
#### Function InstallNPMPackages ###############################################
InstallNPMPackages()
{
  ######################################################
  # Convert Array to string for single pass to install #
  ######################################################
  INSTALL_PACKAGE_STRING=$(ConvertArray "${NPM_PACKAGE_ARRAY[@]}")

  ###############################
  # Check the string for length #
  ###############################
  LENGTH=${#INSTALL_PACKAGE_STRING}

  #############################
  # Skip loop if no variables #
  #############################
  if [ "$LENGTH" -le 1 ]; then
    echo ""
    echo "------------------------------"
    echo "No NPM package(s) to install... skipping..."
  else
    ###########
    # Headers #
    ###########
    echo ""
    echo "------------------------------"
    echo "Installing NPM package(s)"
    echo "Packages:[$INSTALL_PACKAGE_STRING]"
    echo "This could take several moments..."

    ####################################
    # Need to install all APT packages #
    ####################################
    # shellcheck disable=SC2086
    INSTALL_CMD=$(npm -g install $INSTALL_PACKAGE_STRING 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # Error
      echo "ERROR! Failed to install NPM packages!"
      echo "ERROR:[$INSTALL_CMD]"
      exit 1
    else
      # Success
      echo "Successfully installed all NPM packages"
    fi
  fi
}
################################################################################
#### Function ConvertArray #####################################################
ConvertArray()
{
  #####################
  # Read in the array #
  #####################
  ARRAY=("$@")

  ###################################################
  # Convert the array into a space seperated string #
  ###################################################
  STRING=$(IFS=$' '; echo "${ARRAY[*]}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "ERROR! Failed to create string!"
    echo "ERROR:[$STRING]"
    exit 1
  fi

  ##########################################
  # Need to remove whitespace on the edges #
  ##########################################
  CLEANED_STRING=$(echo "$STRING" | xargs 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "ERROR! Failed to clean string!"
    echo "ERROR:[$STRING]"
    exit 1
  else
    ############################################################
    # Echo the cleaned string back to the master function call #
    ############################################################
    echo "$CLEANED_STRING"
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer()
{
  echo ""
  echo "---------------------------"
  echo "The script has completed"
  echo "---------------------------"
}
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

########################
# Install APT packages #
########################
InstallAptPackages

########################
# Install PIP packages #
########################
InstallPipPackages

########################
# Install GEM packages #
########################
InstallGemPackages

########################
# Install NPM packages #
########################
InstallNPMPackages

##########
# Footer #
##########
Footer
