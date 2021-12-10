#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions @admiralawkbar ######################
################################################################################
################################################################################
#### Function GetLinterVersions ################################################
GetLinterVersions() {
  #########################
  # Print version headers #
  #########################
  debug "---------------------------------------------"
  debug "WRITE_LINTER_VERSIONS_FILE: ${WRITE_LINTER_VERSIONS_FILE}"
  debug "VERSION_FILE: ${VERSION_FILE}"
  debug "Linter Version Info:"

  if [ "${WRITE_LINTER_VERSIONS_FILE}" = "true" ]; then
    debug "Building linter version file..."
    if BuildLinterVersions "${VERSION_FILE}" "${LINTER_NAMES_ARRAY[@]}"; then
      info "Linter version file built correctly."
      exit
    else
      fatal "Error while building the versions file."
    fi
  else
    debug "Skipping versions file build..."
  fi

  ################################
  # Cat the linter versions file #
  ################################
  CAT_CMD=$(cat "${VERSION_FILE}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failure
    fatal "Failed to view version file:[${VERSION_FILE}]"
  else
    # Success
    debug "${CAT_CMD}"
  fi

  #########################
  # Print version footers #
  #########################
  debug "---------------------------------------------"
}
################################################################################
#### Function BuildLinterVersions ##############################################
BuildLinterVersions() {
  VERSION_FILE="${1}" && shift
  LINTER_ARRAY=("$@")

  debug "Building linter version file ${VERSION_FILE} for the following linters: ${LINTER_ARRAY[*]}..."

  ##########################################################
  # Go through the array of linters and print version info #
  ##########################################################
  for LINTER in "${LINTER_ARRAY[@]}"; do
    if [ -n "${LINTER}" ]; then
      ####################
      # Get the versions #
      ####################
      if [[ ${LINTER} == "arm-ttk" ]]; then
        # Need specific command for ARM
        GET_VERSION_CMD="$(grep -iE 'version' "/usr/bin/arm-ttk" | xargs 2>&1)"
      elif [[ ${LINTER} == "bash-exec" ]] || [[ ${LINTER} == "gherkin-lint" ]] || [[ ${LINTER} == "gitleaks" ]]; then
        # Need specific command for Protolint and editorconfig-checker
        GET_VERSION_CMD="$(echo "--version not supported")"
      elif [[ ${LINTER} == "lintr" ]]; then
        # Need specific command for lintr (--slave is deprecated in R 4.0 and replaced by --no-echo)
        GET_VERSION_CMD="$(R --slave -e "r_ver <- R.Version()\$version.string; \
                    lintr_ver <- packageVersion('lintr'); \
                    glue::glue('lintr { lintr_ver } on { r_ver }')")"
      elif [[ ${LINTER} == "lua" ]]; then
        # Semi standardversion command
        GET_VERSION_CMD="$("${LINTER}" -v 2>&1)"
      elif [[ ${LINTER} == "terrascan" ]]; then
        GET_VERSION_CMD="$("${LINTER}" version 2>&1)"
      elif [[ ${LINTER} == "checkstyle" ]] || [[ ${LINTER} == "google-java-format" ]]; then
        GET_VERSION_CMD="$(java -jar "/usr/bin/${LINTER}" --version 2>&1)"
      elif [[ ${LINTER} == "clippy" ]]; then
        GET_VERSION_CMD="$(cargo-clippy --version 2>&1)"
      elif [[ ${LINTER} == "protolint" ]]; then
        GET_VERSION_CMD="$(${LINTER} version)"
      elif [[ ${LINTER} == "editorconfig-checker" ]]; then
        GET_VERSION_CMD="$(${LINTER} -version)"
      else
        # Standard version command
        GET_VERSION_CMD="$("${LINTER}" --version 2>&1)"
      fi

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      debug "Linter version for ${LINTER}: ${GET_VERSION_CMD}. Error code: ${ERROR_CODE}"
      if [ ${ERROR_CODE} -ne 0 ]; then
        fatal "[${LINTER}]: Failed to get version info: ${GET_VERSION_CMD}"
      else
        ##########################
        # Print the version info #
        ##########################
        info "Successfully found version for ${F[W]}[${LINTER}]${F[B]}: ${F[W]}${GET_VERSION_CMD}"
        WriteFile "${LINTER}" "${GET_VERSION_CMD}" "${VERSION_FILE}"
      fi
    fi
  done
}
################################################################################
#### Function WriteFile ########################################################
WriteFile() {
  ##############
  # Read Input #
  ##############
  LINTER="$1"     # Name of the linter
  VERSION="$2"    # Version returned from check
  VERSION_FILE=$3 # Version file path

  #################################
  # Write the data to output file #
  #################################
  echo "${LINTER}: ${VERSION}" >>"${VERSION_FILE}" 2>&1

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    fatal "Failed to write data to file!"
  fi
}
