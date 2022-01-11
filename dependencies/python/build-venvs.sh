#!/usr/bin/env bash
################################################################################
########################### Install Python Dependancies ########################
################################################################################

#####################
# Set fail on error #
#####################
set -euo pipefail

############################
# Create staging directory #
############################
mkdir -p /venvs

########################################
# Install basic libs to run installers #
########################################
pip install virtualenv

#########################################################
# Itterate through requirments.txt to install bainaries #
#########################################################
for DEP_FILE in *.txt; do
  # split the package name from its version
  PACKAGE_NAME=${DEP_FILE%.txt}
  echo "-------------------------------------------"
  mkdir -p "/venvs/${PACKAGE_NAME}"
  cp "${DEP_FILE}" "/venvs/${PACKAGE_NAME}/requirements.txt"
  echo "Generating virtualenv for: [${PACKAGE_NAME}]"
  pushd "/venvs/${PACKAGE_NAME}"
  virtualenv .
  # shellcheck disable=SC1091
  source bin/activate
  pip install -r requirements.txt
  # deactivate the python virtualenv
  deactivate
  # pop the stack
  popd
done
