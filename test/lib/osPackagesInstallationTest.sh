#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/runtimeDependencies.sh"

# shellcheck source=/dev/null
source /action/lib/globals/runtimeDependencies.sh

InstallOsPackagesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local -a EXPECTED_OS_PACKAGES_TO_INSTALL
  EXPECTED_OS_PACKAGES_TO_INSTALL=("restic" "rsync")

  local LINTER_RULES_PATH
  # shellcheck disable=SC2034
  LINTER_RULES_PATH="test/data/install-dependencies/os-packages"
  if InstallOsPackages; then
    debug "OS packages installed"
  else
    fatal "Error while installing OS packages"
  fi

  for package in "${EXPECTED_OS_PACKAGES_TO_INSTALL[@]}"; do
    if apk info -vv --no-network --no-cache | grep "${package}"; then
      debug "Package ${package} is installed as expected"
    else
      fatal "Package ${package} is not installed as expected"
    fi
  done

  notice "${FUNCTION_NAME} PASS"

  unset LINTER_RULES_PATH
}
InstallOsPackagesTest
