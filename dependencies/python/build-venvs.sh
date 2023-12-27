#!/usr/bin/env bash
################################################################################
########################### Install Python Dependancies ########################
################################################################################

#####################
# Set fail on error #
#####################
set -euo pipefail

apk add --no-cache --virtual .python-build-deps \
  gcc \
  linux-headers \
  musl-dev \
  python3-dev

############################
# Create staging directory #
############################
mkdir -p /venvs

########################################
# Install basic libs to run installers #
########################################
pip install virtualenv

#######################################################
# Iterate through requirments.txt to install binaries #
#######################################################
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
  pip install \
    --no-cache-dir \
    --requirement requirements.txt
  # deactivate the python virtualenv
  deactivate
  # pop the stack
  popd
done

apk del --no-network --purge .python-build-deps
