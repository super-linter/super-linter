#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

if [[ "$#" -lt 1 ]]; then
  echo "Usage: shellharden-wrapper [--check|--replace] <file...>" >&2
  exit 1
fi

mode="$1"
shift

case "${mode}" in
  --check)
    set +o errexit
    shellharden --check "$@"
    status=$?
    set -o errexit

    if [[ "${status}" -eq 0 ]]; then
      exit 0
    fi
    if [[ "${status}" -eq 2 ]]; then
      shellharden --suggest "$@"
    fi
    exit "${status}"
    ;;
  --replace)
    exec shellharden --replace "$@"
    ;;
  *)
    exec shellharden "${mode}" "$@"
    ;;
esac
