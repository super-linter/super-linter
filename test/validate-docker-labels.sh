#!/usr/bin/env bash

set -o errexit
set -o nounset

CONTAINER_IMAGE_ID="${1}"
shift
BUILD_DATE="${1}"
shift
BUILD_REVISION="${1}"
shift
BUILD_VERSION="${1}"
shift

ValidateLabel() {
  local LABEL_KEY="$1"
  local CONTAINER_VALUE="$2"

  LABEL="$(docker inspect --format "{{ index .Config.Labels \"${LABEL_KEY}\" }}" "${CONTAINER_IMAGE_ID}")"

  if [[ "${LABEL}" != "${CONTAINER_VALUE}" ]]; then
    echo "[ERROR] Invalid container image label: ${LABEL_KEY}: ${LABEL}. Expected: ${CONTAINER_VALUE}"
    exit 1
  else
    echo "${LABEL_KEY} is valid: ${LABEL}. Expected: ${CONTAINER_VALUE}"
  fi
}

ValidateLabel "org.opencontainers.image.created" "${BUILD_DATE}"
ValidateLabel "org.opencontainers.image.revision" "${BUILD_REVISION}"
ValidateLabel "org.opencontainers.image.version" "${BUILD_VERSION}"
