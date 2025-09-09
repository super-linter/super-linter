#!/usr/bin/env bash

InstallCaCert() {
  if [ -z "${SSL_CERT_SECRET:-}" ]; then
    debug "User did not provide a SSL_CERT_SECRET"
    return
  fi

  debug "User configured a SSL_CERT_SECRET"

  local CERT_FILE
  CERT_FILE='/tmp/cert.crt'
  local CERT_ROOT
  CERT_ROOT='/usr/local/share/ca-certificates'
  local FILE_NAME
  local RET_CODE
  FILE_NAME="$(basename "${CERT_FILE}" 2>&1)"
  RET_CODE=$?
  if [[ "${RET_CODE}" -gt 0 ]]; then
    error "Error while getting the file name of the certificate file: ${CERT_FILE}. Output: ${FILE_NAME}"
    return 1
  fi

  echo "${SSL_CERT_SECRET}" >>"${CERT_FILE}"

  local CERT_DESTINATION
  CERT_DESTINATION="${CERT_ROOT}/${FILE_NAME}"
  info "Moving certificate to ${CERT_DESTINATION}"
  local COPY_CMD
  if ! COPY_CMD=$(mv -v "${CERT_FILE}" "${CERT_DESTINATION}" 2>&1); then
    error "Failed to move cert to ${CERT_DESTINATION}. Output: ${COPY_CMD}"
    return 1
  fi
  debug "Move certificate output: ${COPY_CMD}"

  info "Update cert store to consider the new certificate"
  local UPDATE_CMD
  if ! UPDATE_CMD=$(update-ca-certificates 2>&1); then
    error "Failed to add the certificate to the trust store. Output: ${UPDATE_CMD}"
    return 1
  fi
  debug "Cert store update output: ${UPDATE_CMD}"
}
