#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

GetBuildDate() {
  date -u +'%Y-%m-%dT%H:%M:%SZ'
}

GetBuildRevision() {
  if [[ -v BUILD_REVISION ]]; then
    # BUILD_REVISION is already set, no need to compute it
    echo "${BUILD_REVISION}"
  else
    git rev-parse HEAD
  fi
}

GetBuildVersion() {
  local VERSION_FILE_PATH="version.txt"
  local BUILD_REVISION="${1}"
  # Get the version from the version descriptor if changed in the last commit.
  # This assumes that the last commit was a "release preparation" commit that
  # updated the version descriptor
  if git diff-tree --no-commit-id --name-only -r "${BUILD_REVISION}" | grep -q "${VERSION_FILE_PATH}"; then
    cat "${VERSION_FILE_PATH}"
  else
    # Fallback on the build revision to avoid that a non-release container image
    # has BUILD_VERSION set to a release string
    GetBuildRevision
  fi
}

GetLabelFromContainerImage() {
  local LABEL_KEY="${1}" && shift
  local CONTAINER_IMAGE_ID="${1}" && shift
  docker inspect --format "{{ index .Config.Labels \"${LABEL_KEY}\" }}" "${CONTAINER_IMAGE_ID}"
}

LOADED_BUILD_METADATA_FROM_CONTAINER_IMAGE="false"

if [[ -v CONTAINER_IMAGE_ID ]] &&
  [[ -n "${CONTAINER_IMAGE_ID:-}" ]]; then
  echo "Getting BUILD_DATE, BUILD_REVISION, and BUILD_VERSION from the ${CONTAINER_IMAGE_ID} container image"
  BUILD_DATE="${BUILD_DATE:-"$(GetLabelFromContainerImage "org.opencontainers.image.created" "${CONTAINER_IMAGE_ID}")"}"
  BUILD_REVISION="${BUILD_REVISION:-"$(GetLabelFromContainerImage "org.opencontainers.image.revision" "${CONTAINER_IMAGE_ID}")"}"
  BUILD_VERSION="${BUILD_VERSION:-"$(GetLabelFromContainerImage "org.opencontainers.image.version" "${CONTAINER_IMAGE_ID}")"}"
  LOADED_BUILD_METADATA_FROM_CONTAINER_IMAGE="true"
else
  echo "Initializing BUILD_DATE, BUILD_REVISION, and BUILD_VERSION"
  BUILD_DATE="${BUILD_DATE:-"$(GetBuildDate)"}"
  BUILD_REVISION="${BUILD_REVISION:-"$(GetBuildRevision)"}"
  BUILD_VERSION="${BUILD_VERSION:-"$(GetBuildVersion "${BUILD_REVISION}")"}"
fi

export BUILD_DATE
export BUILD_REVISION
export BUILD_VERSION
export LOADED_BUILD_METADATA_FROM_CONTAINER_IMAGE

echo "Build date: ${BUILD_DATE}"
echo "Build revision: ${BUILD_REVISION}"
echo "Build version: ${BUILD_VERSION}"
echo "Loaded build metadata from container image: ${LOADED_BUILD_METADATA_FROM_CONTAINER_IMAGE}"
