#!/usr/bin/env bash

set -euo pipefail

# fprettify --diff doesn't return a non-zero exit code when formatting
# differences are found. This wrapper checks for output and exits non-zero
# if there are differences.

DIFF_MODE=false
for arg in "$@"; do
  if [[ "${arg}" == "--diff" ]]; then
    DIFF_MODE=true
    break
  fi
done

if [[ "${DIFF_MODE}" == "true" ]]; then
  output=$(fprettify "$@" 2>&1)
  rc=$?
  if [[ ${rc} -ne 0 ]]; then
    echo "${output}" >&2
    exit ${rc}
  fi
  if [[ -n "${output}" ]]; then
    echo "${output}"
    exit 1
  fi
else
  exec fprettify "$@"
fi
