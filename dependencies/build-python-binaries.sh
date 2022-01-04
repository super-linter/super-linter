#!/usr/bin/env bash
set -euo pipefail

mkdir -p venvs
mkdir /stage
pip install pyinstaller virtualenv

while read -r line ; do
    package_name=$(cut -d'=' -f1 <<< "${line}")
    printf "Generating virtualenv for %s\n" "${package_name}"
    virtualenv "venvs/${package_name}"
    pushd "venvs/${package_name}"
    source bin/activate
      pip install "${line}"
    if [[ "${package_name}" == *"["* ]]; then
      pyinstaller --onefile "./bin/$(cut -d'[' -f1 <<< "${line}")"
      mv "./bin/$(cut -d'[' -f1 <<< "${line}")" /stage
    else
      pyinstaller --onefile "./bin/${package_name}"
      mv "./bin/${package_name}" /stage
    fi
    deactivate
    popd
done < requirements.txt

