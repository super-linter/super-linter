#!/usr/bin/env bash

set -o errexit
set -o nounset

CONTAINER_IMAGE_ID="${1}"
shift
BUILD_REVISION="${1}"
shift
BUILD_VERSION="${1}"
shift

BUILD_DATE_LABEL_KEY="org.opencontainers.image.created"

ValidateLabel() {
  CONTAINER_KEY="$1"
  CONTAINER_VALUE="$2"

  LABEL=$(docker inspect --format "{{ index .Config.Labels \"${CONTAINER_KEY}\" }}" "${CONTAINER_IMAGE_ID}")

  if ( [[ "${CONTAINER_KEY}" == "${BUILD_DATE_LABEL_KEY}" ]] && [[ -z "${LABEL}" ]] ) || [[ ${LABEL} != "${CONTAINER_VALUE}" ]]; then
    echo "[ERROR] Assert failed ${CONTAINER_KEY}: ${LABEL}. Expected: ${CONTAINER_VALUE}"
    exit 1
  fi

  echo "${CONTAINER_KEY} is valid: ${CONTAINER_VALUE}. Expected: ${CONTAINER_VALUE}"
}

ValidateLabel "org.opencontainers.image.revision" "${BUILD_REVISION}"
ValidateLabel "org.opencontainers.image.version" "${BUILD_VERSION}"
ValidateLabel "${BUILD_DATE_LABEL_KEY}" "not empty"
