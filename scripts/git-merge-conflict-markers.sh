#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

GIT_MERGE_CONFLICT_START='^<{7} .+$'
GIT_MERGE_CONFLICT_MIDST='^={7}$'
GIT_MERGE_CONFLICT_END='^>{7} .+$'

if [[ "$*" == "--version" ]]; then
  echo "1.0.0"
  exit 0
fi

declare -i errors=0

for file in "$@"; do
  if grep -q -E "${GIT_MERGE_CONFLICT_START}" "$file" &&
    grep -q -E "${GIT_MERGE_CONFLICT_MIDST}" "$file" &&
    grep -q -E "${GIT_MERGE_CONFLICT_END}" "$file"; then
    echo "Found Git merge conflict markers: \"$file\""
    errors=$((errors + 1))
  fi
done

if [[ $errors -gt 0 ]]; then
  exit 1
else
  echo "No merge conflicts found in $*"
fi
