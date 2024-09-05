#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

GIT_MERGE_CONFLICT_EXPRESSION='^(<<<<<<<|=======|>>>>>>>)'

if [[ "$*" == "--version" ]]; then
  echo "1.0.0"
  exit 0
fi

if grep -l -E "${GIT_MERGE_CONFLICT_EXPRESSION}" "$@"; then
  echo "Found Git merge conflict markers"
  exit 1
else
  echo "No merge conflicts found in $*"
fi
