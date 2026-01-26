#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

pip install pip-audit

for venv_path in /venvs/*; do
  pushd "${venv_path}"
  echo "Checking for known vulnerabilities in ${venv_path}"
  # shellcheck disable=SC1091
  source bin/activate
  pip-audit --requirement "${venv_path}/requirements.txt"
  deactivate
  popd
done
