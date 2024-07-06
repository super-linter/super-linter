#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

apk add --no-cache --virtual .python-build-deps \
  gcc \
  libffi-dev \
  linux-headers \
  musl-dev \
  python3-dev

# Otherwise, pytries/datrie doesn't build using gcc14
# Ref: https://github.com/pytries/datrie/issues/101
export CFLAGS="-Wno-error=incompatible-pointer-types"
export CXXFLAGS="-Wno-error=incompatible-pointer-types"

############################
# Create staging directory #
############################
mkdir -p /venvs

#######################################################
# Iterate through requirements.txt to install binaries #
#######################################################
for DEP_FILE in *.txt; do
  # split the package name from its version
  PACKAGE_NAME=${DEP_FILE%.txt}
  echo "-------------------------------------------"
  mkdir -p "/venvs/${PACKAGE_NAME}"
  cp "${DEP_FILE}" "/venvs/${PACKAGE_NAME}/requirements.txt"
  echo "Generating virtualenv for: [${PACKAGE_NAME}]"
  pushd "/venvs/${PACKAGE_NAME}"
  python -m venv .
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
