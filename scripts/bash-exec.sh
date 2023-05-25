#!/usr/bin/env bash

set -euo pipefail

if ! [[ -x "$1" ]]; then
  echo "Error: File:[$1] is not executable"
  exit 1
fi
