#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
LOG_DEBUG="true"
# shellcheck disable=SC2034
LOG_VERBOSE="true"
# shellcheck disable=SC2034
LOG_NOTICE="true"
# shellcheck disable=SC2034
LOG_WARN="true"
# shellcheck disable=SC2034
LOG_ERROR="true"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck disable=SC2034
CREATE_LOG_FILE=false

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

function RecognizeNoShebangTest() {
  local FILE="test/linters/bash_exec/libraries/noShebang_bad.sh"

  debug "Confirming ${FILE} has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

RecognizeCommentIsNotShebangTest() {
  local FILE="test/linters/bash_exec/libraries/comment_bad.sh"

  debug "Confirming ${FILE} starting with a comment has no shebang"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

RecognizeIndentedShebangAsCommentTest() {
  local FILE="test/linters/bash_exec/libraries/indentedShebang_bad.sh"

  debug "Confirming indented shebang in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

RecognizeSecondLineShebangAsCommentTest() {
  local FILE="test/linters/bash_exec/libraries/secondLineShebang_bad.sh"

  debug "Confirming shebang on second line in ${FILE} is considered a comment"

  if ! HasNoShebang "${FILE}"; then
    fatal "${FILE} with a comment is mis-classified as having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangTest() {
  local FILE="test/linters/bash_exec/libraries/shebang_bad.sh"

  debug "Confirming ${FILE} has a shebang"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

function RecognizeShebangWithBlankTest() {
  local FILE="test/linters/bash_exec/libraries/shebangWithBlank_bad.sh"

  debug "Confirming shebang with blank in ${FILE} is recognized"

  if HasNoShebang "${FILE}"; then
    fatal "${FILE} is mis-classified as not having a shebang"
  fi

  FUNCTION_NAME="${FUNCNAME[0]}"
  notice "${FUNCTION_NAME} PASS"
}

RecognizeNoShebangTest
RecognizeCommentIsNotShebangTest
RecognizeIndentedShebangAsCommentTest
RecognizeSecondLineShebangAsCommentTest
RecognizeShebangTest
RecognizeShebangWithBlankTest
