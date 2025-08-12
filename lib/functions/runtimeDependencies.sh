#!/usr/bin/env bash

InstallOsPackages() {
  OS_PACKAGES_TO_INSTALL_FILE_PATH="${LINTER_RULES_PATH}/${OS_PACKAGES_CONFIG_FILE_NAME}"
  debug "Installing OS packages at runtime. OS packages config file name: ${OS_PACKAGES_CONFIG_FILE_NAME}. OS packages file path: ${OS_PACKAGES_TO_INSTALL_FILE_PATH}"

  if [ ! -f "${OS_PACKAGES_TO_INSTALL_FILE_PATH}" ]; then
    debug "${OS_PACKAGES_TO_INSTALL_FILE_PATH} doesn't exist. Skip installing OS packages at runtime."
    return
  fi

  local -a OS_PACKAGES_TO_INSTALL

  readarray -d '' OS_PACKAGES_TO_INSTALL < <(jq --raw-output0 '.[]' "${OS_PACKAGES_TO_INSTALL_FILE_PATH}")
  debug "OS packages to install: ${OS_PACKAGES_TO_INSTALL[*]}"

  if [ "${#OS_PACKAGES_TO_INSTALL[@]}" -eq 0 ]; then
    debug "No OS packages to install. Skip installing OS packages at runtime."
    return
  fi

  local APK_INSTALL
  local RET_CODE
  APK_INSTALL=(apk add --no-cache "${OS_PACKAGES_TO_INSTALL[@]}")
  "${APK_INSTALL[@]}"
  RET_CODE=$?
  if [ ${RET_CODE} -eq 0 ]; then
    debug "Installed ${OS_PACKAGES_TO_INSTALL[*]} OS packages. Output:\n${APK_INSTALL[*]}"
  else
    fatal "Failed to install ${OS_PACKAGES_TO_INSTALL[*]} OS packages. Output:\n${APK_INSTALL[*]}"
  fi
}
