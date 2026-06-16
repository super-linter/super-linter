#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

pip install pip-audit

OUTPUT_DIR="${1:-}"

for venv_path in /venvs/*; do
  venv_name=$(basename "${venv_path}")
  pushd "${venv_path}"
  # shellcheck disable=SC1091
  source bin/activate
  if [ -n "${OUTPUT_DIR}" ]; then
    mkdir -p "${OUTPUT_DIR}"
    pip-audit --requirement "${venv_path}/requirements.txt" --format json | tee "${OUTPUT_DIR}/pip-audit-${venv_name}.json"
  else
    echo "Checking for known vulnerabilities in ${venv_path}"
    pip-audit --requirement "${venv_path}/requirements.txt"
  fi
  deactivate
  popd
done
