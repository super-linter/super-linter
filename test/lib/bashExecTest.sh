#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

BashExecIgnoreLibrariesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local TEST_FILE_PATH="test/linters/bash_exec/libraries/noShebang_bad.sh"

  if scripts/bash-exec.sh "${TEST_FILE_PATH}"; then
    fatal "bash-exec without any option should have failed"
  fi

  if scripts/bash-exec.sh "${TEST_FILE_PATH}" "false"; then
    fatal "bash-exec with 'false' should have failed"
  fi

  if ! scripts/bash-exec.sh "${TEST_FILE_PATH}" "true"; then
    fatal "bash-exec with 'false' should not have failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

BashExecIgnoreLibrariesTest
