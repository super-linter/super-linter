#!/usr/bin/env bash

set -o errexit
set -o nounset

CONTAINER_IMAGE_ID="${1}"
shift
BUILD_REVISION="${1}"
shift
BUILD_VERSION="${1}"
shift

GetContainerImageLabel() {
  echo "$(docker inspect --format "{{ index .Config.Labels \"${1}\" }}" "${2}")"
}

ValidateLabel() {
  local LABEL_KEY="$1"
  local CONTAINER_VALUE="$2"

  LABEL="$(GetContainerImageLabel "${LABEL_KEY}" "${CONTAINER_IMAGE_ID}")"

  if [[ "${LABEL}" != "${CONTAINER_VALUE}" ]]; then
    echo "[ERROR] Invalid container image label: ${LABEL_KEY}: ${LABEL}. Expected: ${CONTAINER_VALUE}"
    exit 1
  else
    echo "${LABEL_KEY} is valid: ${LABEL}. Expected: ${CONTAINER_VALUE}"
  fi
}

ValidateLabel "org.opencontainers.image.revision" "${BUILD_REVISION}"
ValidateLabel "org.opencontainers.image.version" "${BUILD_VERSION}"
