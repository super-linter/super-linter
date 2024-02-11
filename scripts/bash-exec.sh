#!/usr/bin/env bash

set -euo pipefail

FILE="${1}"
IGNORE_LIBRARY="${2:-false}"

if [[ "${IGNORE_LIBRARY}" == "true" ]] && HasNoShebang "${FILE}"; then
  echo "${FILE} is being ignored because IGNORE_LIBRARY is set to ${IGNORE_LIBRARY}"
  exit 0
fi

if ! [[ -x "${FILE}" ]]; then
  echo "Error: File:[${FILE}] is not executable"
  exit 1
fi
