#!/usr/bin/env bash
################################################################################
########################### Install Python Dependancies ########################
################################################################################

#####################
# Set fail on error #
#####################
set -euo pipefail

#################################
# Make the dirs to create execs #
#################################
mkdir -p venvs
mkdir /stage

########################################
# Install basic libs to run installers #
########################################
pip install pyinstaller virtualenv

#########################################################
# Itterate through requirments.txt to install bainaries #
#########################################################
while read -r LINE; do
  # split the package name from its version
  PACKAGE_NAME=$(cut -d'=' -f1 <<<"${LINE}")
  echo "-------------------------------------------"
  echo "Generating virtualenv for:[${PACKAGE_NAME}]"
  virtualenv "venvs/${PACKAGE_NAME}"
  pushd "venvs/${PACKAGE_NAME}"
  # shellcheck disable=SC1091
  source bin/activate
  pip install "${LINE}"
  # Check for usecases like "ansible-lint[core]"
  if [[ "${PACKAGE_NAME}" == *"["* ]]; then
    pyinstaller --onefile "./bin/$(cut -d'[' -f1 <<<"${LINE}")"
    mv "./bin/$(cut -d'[' -f1 <<<"${LINE}")" /stage
  else
    pyinstaller --onefile "./bin/${PACKAGE_NAME}"
    mv "./bin/${PACKAGE_NAME}" /stage
  fi
  # deactivate the python virtualenv
  deactivate
  # pop the stack
  popd
done <requirements.txt
