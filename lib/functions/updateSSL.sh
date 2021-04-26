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
  if [ -z "${SSL_CERT_SECRET}" ]; then
    # No cert was passed
    debug "User did not provide a SSL secret, moving on..."
  else
    # User has provided a cert file to upload
    debug "User passed SSL secret:[${SSL_CERT_SECRET}]"
    InstallSSLCert
  fi
}
################################################################################
#### Function InstallSSLCert ###################################################
function InstallSSLCert() {
  #############
  # Base Vars #
  #############
  CERT_FILE='/tmp/cert.crt'
  CERT_ROOT='/usr/local/share/ca-certificates'
  FILE_NAME=$(basename "${CERT_FILE}" 2>&1)

  #########################
  # Echo secret into file #
  #########################
  echo "${SSL_CERT_SECRET}" >>"${CERT_FILE}"

  ########################################
  # Put the cert in the correct location #
  ########################################
  COPY_CMD=$(mv "${CERT_FILE}" "${CERT_ROOT}/${FILE_NAME}" 2>&1)

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
  else
    info "Moved cert into location, adding to trust store..."
  fi

  ##############################################
  # Update ca-certificates to pull in the cert #
  ##############################################
  UPDATE_CMD=$(update-ca-certificates 2>&1)

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
