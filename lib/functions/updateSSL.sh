#!/usr/bin/env bash

function CheckSSLCert() {
  if [ -z "${SSL_CERT_SECRET:-}" ]; then
    # No cert was passed
    debug "User did not provide a SSL_CERT_SECRET"
  else
    # User has provided a cert file to upload
    debug "User configured a SSL_CERT_SECRET"
    InstallSSLCert
  fi
}

function InstallSSLCert() {
  local CERT_FILE
  CERT_FILE='/tmp/cert.crt'
  local CERT_ROOT
  CERT_ROOT='/usr/local/share/ca-certificates'
  local FILE_NAME
  FILE_NAME=$(basename "${CERT_FILE}" 2>&1)

  echo "${SSL_CERT_SECRET}" >>"${CERT_FILE}"

  local CERT_DESTINATION
  CERT_DESTINATION="${CERT_ROOT}/${FILE_NAME}"
  info "Moving certificate to ${CERT_DESTINATION}"
  local COPY_CMD
  if ! COPY_CMD=$(mv -v "${CERT_FILE}" "${CERT_DESTINATION}" 2>&1); then
    fatal "Failed to move cert to ${CERT_DESTINATION}. Output: ${COPY_CMD}"
  fi
  debug "Move certificate output: ${COPY_CMD}"

  info "Update cert store to consider the new certificate"
  local UPDATE_CMD
  if ! UPDATE_CMD=$(update-ca-certificates 2>&1); then
    fatal "Failed to add the certificate to the trust store. Output: ${UPDATE_CMD}"
  fi
  debug "Cert store update output: ${UPDATE_CMD}"
}
