#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions @admiralawkbar ######################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function CheckSSLCert #####################################################
function CheckSSLCert() {
  if [ -z "${SSL_CERT_FILE}" ]; then
    # No cert was passed
    debug "User did not provide a SSL cert, moving on..."
  else
    # User has provided a cert file to upload
    debug "User passed SSL cert file:[${SSL_CERT_FILE}]"
    info "User provided SSL cert file:[${SSL_CERT_FILE}]"

    ##########################################
    # Check if the file can be found on disk #
    ##########################################
    if [ ! -f "${SSL_CERT_FILE}" ]; then
      # Failed to find cert file
      fatal "ERROR! Failed to find cert at location:[${SSL_CERT_FILE}]"
    else
      # Found the file, need to install it
      InstallSSLCert
    fi
  fi
}
################################################################################
#### Function InstallSSLCert ###################################################
function InstallSSLCert() {
  #############
  # Base Vars #
  #############
  CERT_ROOT='/usr/local/share/ca-certificates'
  FILE_NAME=$(basename "${SSL_CERT_FILE}" 2>&1)

  ########################################
  # Put the cert in the correct location #
  ########################################
  COPY_CMD=$(mv "${SSL_CERT_FILE}" "${CERT_ROOT}/${FILE_NAME}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    error "ERROR! Failed to move cert into location!"
    fatal "ERROR:[${COPY_CMD}]"
  fi

  ##############################################
  # Update ca-certificates to pull in the cert #
  ##############################################
  UPDATE_CMD=$(update ca-certificates 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    error "ERROR! Failed to add cert to trust store!"
    fatal "ERROR:[${UPDATE_CMD}]"
  else
    # Success
    info "Successfully added cert to trust store"
  fi
}
################################################################################
