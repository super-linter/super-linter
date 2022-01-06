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
while read -r LINE; do
  # split the package name from its version
  PACKAGE_NAME=$(cut -d'=' -f1 <<<"${LINE}")
  if [[ "${PACKAGE_NAME}" == *"["* ]]; then
    PACKAGE_NAME=$(cut -d'[' -f1 <<<"${PACKAGE_NAME}")
  fi
  echo "-------------------------------------------"
  mkdir -p "/venvs/${PACKAGE_NAME}"
  cp "${PACKAGE_NAME}/requirements.txt" "/venvs/${PACKAGE_NAME}/requirements.txt"
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
done <packages.txt
