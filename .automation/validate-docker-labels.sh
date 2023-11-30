#!/usr/bin/env bash

set -o errexit
set -o nounset

CONTAINER_IMAGE_ID="${1}"
shift
BUILD_REVISION="${1}"
shift
BUILD_VERSION="${1}"
shift

ValidateLabel() {
  CONTAINER_KEY="$1"   # Example: org.opencontainers.image.created
  CONTAINER_VALUE="$2" # Example: 1985-04-12T23:20:50.52Z

  LABEL=$(docker inspect --format "{{ index .Config.Labels \"${CONTAINER_KEY}\" }}" "${CONTAINER_IMAGE_ID}")

  if [[ ${LABEL} != "${CONTAINER_VALUE}" ]]; then
    echo "[ERROR] Assert failed [${CONTAINER_KEY} - '${LABEL}' != '${CONTAINER_VALUE}']"
    exit 1
  else
    echo "Assert passed [${CONTAINER_KEY}]"
  fi
}

ValidateLabel "org.opencontainers.image.revision" "${BUILD_REVISION}"
ValidateLabel "org.opencontainers.image.version" "${BUILD_VERSION}"
