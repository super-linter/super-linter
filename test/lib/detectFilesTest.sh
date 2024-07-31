#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

function RecognizeNoShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/noShebang_bad.sh"

  debug "Confirming ${FILE} has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeCommentIsNotShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/comment_bad.sh"

  debug "Confirming ${FILE} starting with a comment has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeIndentedShebangAsCommentTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/indentedShebang_bad.sh"

  debug "Confirming indented shebang in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeSecondLineShebangAsCommentTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/secondLineShebang_bad.sh"

  debug "Confirming shebang on second line in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/shebang_bad.sh"

  debug "Confirming ${FILE} has a shebang"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangWithBlankTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"
  local FILE="test/linters/bash_exec/libraries/shebangWithBlank_bad.sh"

  debug "Confirming shebang with blank in ${FILE} is recognized"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function IsAnsibleDirectoryTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  local FILE="${GITHUB_WORKSPACE}/ansible"
  mkdir -p "${FILE}"
  local ANSIBLE_DIRECTORY="/ansible"
  export ANSIBLE_DIRECTORY

  debug "Confirming that ${FILE} is an Ansible directory"

  if ! IsAnsibleDirectory "${FILE}"; then
    fatal "${FILE} is not considered to be an Ansible directory"
  fi

  notice "${FUNCTION_NAME} PASS"
}

RecognizeNoShebangTest
RecognizeCommentIsNotShebangTest
RecognizeIndentedShebangAsCommentTest
RecognizeSecondLineShebangAsCommentTest
RecognizeShebangTest
RecognizeShebangWithBlankTest

IsAnsibleDirectoryTest
