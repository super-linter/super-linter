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

BUILD_DATE="${BUILD_DATE:-"$(GetBuildDate)"}"
export BUILD_DATE
BUILD_REVISION="${BUILD_REVISION:-"$(GetBuildRevision)"}"
export BUILD_REVISION
BUILD_VERSION="${BUILD_VERSION:-"$(GetBuildVersion "${BUILD_REVISION}")"}"
export BUILD_VERSION

echo "Build date: ${BUILD_DATE}"
echo "Build revision: ${BUILD_REVISION}"
echo "Build version: ${BUILD_VERSION}"
