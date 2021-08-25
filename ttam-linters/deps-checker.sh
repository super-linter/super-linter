#!/usr/bin/env bash

declare -A ERROR_CODES

# declaring an hastable for file and its codes
ERROR_CODES["requirements.txt"]="A001"
ERROR_CODES["Pipfile"]="A002"
ERROR_CODES["Dockerfile"]="A003"
ERROR_CODES["package.json"]="A004"
ERROR_CODES["production.txt"]="A005"

# File passed by superlinter
FILE_PATH=$1

# This one is to get file name
FILE_NAME=$(echo "${FILE_PATH}" | rev | cut -d "/" -f1 | rev)

# Checking if files are start with "-r"
POINTER_FILES="$(grep -iE "^-r " "${FILE_PATH}")"

format_output_for_lintly() {

  output=${FILE_PATH}":1:1:${ERROR_CODES[${FILE_NAME}]} does not explicitly point to an approved dependencies repository sources"
  echo "${output}"

}

if [[ -v ERROR_CODES["${FILE_NAME}"] ]] && [[ -z "${POINTER_FILES}" ]]; then
  NON_COMPLIANT_FILES="$(grep -Li "$COMPLIANT_FILTER" "$FILE_PATH")"
  if [[ -n "${NON_COMPLIANT_FILES}" ]]; then
    format_output_for_lintly
  fi
fi
