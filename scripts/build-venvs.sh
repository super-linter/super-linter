#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

apk add --no-cache --virtual .python-build-deps \
  gcc \
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

  # Create the virtual environment without its own copy of pip, and install
  # packages into it with the pip of the base interpreter instead. Each copy of
  # pip takes about 13 MB, and the tools don't need it at runtime.
  VENV_OPTIONS=(--without-pip)
  # mypy is the exception: Super-linter runs it with --install-types, which
  # invokes pip from the mypy virtual environment to install missing stubs.
  if [[ "${PACKAGE_NAME}" == "mypy" ]]; then
    VENV_OPTIONS=()
  fi
  python -m venv "${VENV_OPTIONS[@]}" "/venvs/${PACKAGE_NAME}"
  pip --python "/venvs/${PACKAGE_NAME}/bin/python" install \
    --no-cache-dir \
    --requirement "/venvs/${PACKAGE_NAME}/requirements.txt"
done

apk del --no-network --purge .python-build-deps
