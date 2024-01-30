#!/usr/bin/env bash

GetLinterVersions() {
  debug "WRITE_LINTER_VERSIONS_FILE: ${WRITE_LINTER_VERSIONS_FILE}"

  if [ "${WRITE_LINTER_VERSIONS_FILE}" = "true" ]; then
    debug "Building linter version file: ${VERSION_FILE}"
    if BuildLinterVersions "${VERSION_FILE}" "${LINTER_NAMES_ARRAY[@]}"; then
      info "Linter version file built correctly."
      exit
    else
      fatal "Error while building the versions file."
    fi
  else
    debug "Skipping versions file build..."
  fi

  if ! cat "${VERSION_FILE}"; then
    fatal "Failed to view version file: ${VERSION_FILE}"
  fi
}
################################################################################
#### Function BuildLinterVersions ##############################################
BuildLinterVersions() {
  VERSION_FILE="${1}" && shift
  LINTER_ARRAY=("$@")

  # Start with an empty file. We might have built this file in a previous build
  # stage, so we start fresh here.
  rm -rfv "${VERSION_FILE}"

  debug "Building linter version file ${VERSION_FILE} for the following linters: ${LINTER_ARRAY[*]}..."

  ##########################################################
  # Go through the array of linters and print version info #
  ##########################################################
  for LINTER in "${LINTER_ARRAY[@]}"; do
    if [ -n "${LINTER}" ]; then

      # Some linters need to account for special commands to get their version

      if [[ ${LINTER} == "arm-ttk" ]]; then
        GET_VERSION_CMD="$(grep -iE 'version' "/usr/bin/arm-ttk" | xargs 2>&1)"
      # Some linters don't support a "get version" command
      elif [[ ${LINTER} == "bash-exec" ]] || [[ ${LINTER} == "gherkin-lint" ]]; then
        GET_VERSION_CMD="Version command not supported"
      elif [[ ${LINTER} == "checkstyle" ]] || [[ ${LINTER} == "google-java-format" ]]; then
        GET_VERSION_CMD="$(java -jar "/usr/bin/${LINTER}" --version 2>&1)"
      elif [[ ${LINTER} == "clippy" ]]; then
        GET_VERSION_CMD="$(cargo-clippy --version 2>&1)"
      elif [[ ${LINTER} == "editorconfig-checker" ]]; then
        GET_VERSION_CMD="$(${LINTER} -version)"
      elif [[ ${LINTER} == "kubeconform" ]]; then
        GET_VERSION_CMD="$(${LINTER} -v)"
      elif [[ ${LINTER} == "lintr" ]]; then
        # Need specific command for lintr (--slave is deprecated in R 4.0 and replaced by --no-echo)
        GET_VERSION_CMD="$(R --slave -e "r_ver <- R.Version()\$version.string; \
                    lintr_ver <- packageVersion('lintr'); \
                    glue::glue('lintr { lintr_ver } on { r_ver }')")"
      elif [[ ${LINTER} == "protolint" ]] || [[ ${LINTER} == "gitleaks" ]]; then
        GET_VERSION_CMD="$(${LINTER} version)"
      elif [[ ${LINTER} == "lua" ]]; then
        GET_VERSION_CMD="$("${LINTER}" -v 2>&1)"
      elif [[ ${LINTER} == "renovate-config-validator" ]]; then
        GET_VERSION_CMD="$(renovate --version 2>&1)"
      elif [[ ${LINTER} == "terrascan" ]]; then
        GET_VERSION_CMD="$("${LINTER}" version 2>&1)"
      else
        # Unset TF_LOG_LEVEL so that the version file doesn't contain debug log when running
        # commands that read TF_LOG_LEVEL or TFLINT_LOG, which are likely set to DEBUG when
        # building the versions file
        GET_VERSION_CMD="$(
          unset TF_LOG_LEVEL
          unset TFLINT_LOG
          "${LINTER}" --version 2>&1
        )"
      fi

      ERROR_CODE=$?

      if [ ${ERROR_CODE} -ne 0 ]; then
        fatal "[${LINTER}]: Failed to get version info. Exit code: ${ERROR_CODE}. Output: ${GET_VERSION_CMD}"
      else
        info "Successfully found version for ${LINTER}: ${GET_VERSION_CMD}"
        if ! echo "${LINTER}: ${GET_VERSION_CMD}" >>"${VERSION_FILE}" 2>&1; then
          fatal "Failed to write data to file!"
        fi
      fi
    fi
  done
}
