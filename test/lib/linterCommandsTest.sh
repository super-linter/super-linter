#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# linterCommands.sh needs these

# shellcheck source=/dev/null
source "lib/globals/languages.sh"
# shellcheck source=/dev/null
source "lib/globals/linterRules.sh"
# shellcheck source=/dev/null
source "lib/functions/linterRules.sh"
# shellcheck source=/dev/null
source "lib/functions/validation.sh"

# Initialize the environment
# shellcheck disable=SC2034
BASH_EXEC_IGNORE_LIBRARIES="false"
# shellcheck disable=SC2034
ENABLE_COMMITLINT_EDIT_MODE="false"
# shellcheck disable=SC2034
GITHUB_WORKSPACE="$(pwd)"
# shellcheck disable=SC2034
GROOVY_FAILON_LEVEL="warning"
# shellcheck disable=SC2034
GROOVY_LOG_LEVEL="info"
# shellcheck disable=SC2034
IGNORE_GITIGNORED_FILES="false"
# shellcheck disable=SC2034
YAML_ERROR_ON_WARNING="false"

for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  GetLinterRules "${LANGUAGE}" "TEMPLATES"
done
ValidateValidationVariables

# Now we can load linter command options because they have
# dependencies on linter rules
# shellcheck source=/dev/null
source lib/globals/linterCommandsOptions.sh

# The slim image might not have this variable defined
if [[ ! -v ARM_TTK_PSD1 ]]; then
  ARM_TTK_PSD1="/usr/lib/microsoft/arm-ttk/arm-ttk.psd1"
fi

# Source the file so we can load commands to compare them without redefining
# each command. We're not interested in the actual values of those commands, but
# only in how we eventually modify them.

# shellcheck source=/dev/null
source "lib/functions/linterCommands.sh"

# Initialize the variables we're going to use to verify tests before running tests
# because some tests modify LINTER_COMMANDS_xxx variables
BASE_LINTER_COMMANDS_ARRAY_ANSIBLE=("${LINTER_COMMANDS_ARRAY_ANSIBLE[@]}")
BASE_LINTER_COMMANDS_ARRAY_BASH_EXEC=("${LINTER_COMMANDS_ARRAY_BASH_EXEC[@]}")
BASE_LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS=("${LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS[@]}")
BASE_LINTER_COMMANDS_ARRAY_GIT_COMMITLINT=("${LINTER_COMMANDS_ARRAY_GIT_COMMITLINT[@]}")
BASE_LINTER_COMMANDS_ARRAY_GITLEAKS=("${LINTER_COMMANDS_ARRAY_GITLEAKS[@]}")
BASE_LINTER_COMMANDS_ARRAY_GO_MODULES=("${LINTER_COMMANDS_ARRAY_GO_MODULES[@]}")
BASE_LINTER_COMMANDS_ARRAY_JAVA=("${LINTER_COMMANDS_ARRAY_JAVA[@]}")
BASE_LINTER_COMMANDS_ARRAY_JSCPD=("${LINTER_COMMANDS_ARRAY_JSCPD[@]}")
BASE_LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM=("${LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM[@]}")
BASE_LINTER_COMMANDS_ARRAY_PERL=("${LINTER_COMMANDS_ARRAY_PERL[@]}")
BASE_LINTER_COMMANDS_ARRAY_PRETTIER=("${PRETTIER_COMMAND[@]}")
BASE_LINTER_COMMANDS_ARRAY_RUST_CLIPPY=("${LINTER_COMMANDS_ARRAY_RUST_CLIPPY[@]}")
BASE_LINTER_COMMANDS_ARRAY_XML=("${LINTER_COMMANDS_ARRAY_XML[@]}")

function LinterCommandPresenceTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local LINTER_COMMAND_ARRAY_VARIABLE_NAME="LINTER_COMMANDS_ARRAY_${LANGUAGE}"
    debug "Check if ${LINTER_COMMAND_ARRAY_VARIABLE_NAME} has at least one element"
    local -n LINTER_COMMAND_ARRAY="${LINTER_COMMAND_ARRAY_VARIABLE_NAME}"
    if [ ${#LINTER_COMMAND_ARRAY[@]} -eq 0 ]; then
      fatal "LINTER_COMMAND_ARRAY for ${LANGUAGE} is empty."
    else
      debug "LINTER_COMMAND_ARRAY for ${LANGUAGE} has ${#LINTER_COMMAND_ARRAY[@]} elements: ${LINTER_COMMAND_ARRAY[*]}"
    fi
    unset -n LINTER_COMMAND_ARRAY
  done

  notice "${FUNCTION_NAME} PASS"
}

function IgnoreGitIgnoredFilesJscpdCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local IGNORE_GITIGNORED_FILES="true"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  local EXPECTED_COMMAND=("${BASE_LINTER_COMMANDS_ARRAY_JSCPD[@]}" "${JSCPD_GITIGNORE_OPTION}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_JSCPD" "EXPECTED_COMMAND"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function JscpdCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local IGNORE_GITIGNORED_FILES="false"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  # shellcheck disable=SC2034
  local EXPECTED_COMMAND=("${BASE_LINTER_COMMANDS_ARRAY_JSCPD[@]}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_JSCPD" "EXPECTED_COMMAND"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

EnableCommitlintEditModeCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local ENABLE_COMMITLINT_EDIT_MODE="true"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  local EXPECTED_COMMAND=("${BASE_LINTER_COMMANDS_ARRAY_GIT_COMMITLINT[@]}")
  # remove the last argument because we replace it with COMMITLINT_EDIT_MODE_OPTIONS
  unset "EXPECTED_COMMAND[-1]"
  EXPECTED_COMMAND+=("${COMMITLINT_EDIT_MODE_OPTIONS[@]}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GIT_COMMITLINT" "EXPECTED_COMMAND"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

EnableCommitlintStrictModeCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local ENABLE_COMMITLINT_STRICT_MODE="true"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  local EXPECTED_COMMAND=("${BASE_LINTER_COMMANDS_ARRAY_GIT_COMMITLINT[@]}" "${COMMITLINT_STRICT_MODE_OPTIONS[@]}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GIT_COMMITLINT" "EXPECTED_COMMAND"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function GitleaksCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local EXPECTED_COMMAND=("${BASE_LINTER_COMMANDS_ARRAY_GITLEAKS[@]}")

  if [[ "${EXPECTED_GITLEAKS_LOG_LEVEL:-}" ]]; then
    # shellcheck disable=SC2034
    local GITLEAKS_LOG_LEVEL="${EXPECTED_GITLEAKS_LOG_LEVEL}"
    EXPECTED_COMMAND+=("${GITLEAKS_LOG_LEVEL_OPTIONS[@]}" "${EXPECTED_GITLEAKS_LOG_LEVEL}")
  fi

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  if [[ ! -v GITLEAKS_LOG_LEVEL_OPTIONS ]]; then
    fatal "GITLEAKS_LOG_LEVEL_OPTIONS is not defined"
  fi

  if [[ "${#GITLEAKS_LOG_LEVEL_OPTIONS[@]}" -eq 0 ]]; then
    fatal "GITLEAKS_LOG_LEVEL_OPTIONS is empty"
  fi

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GITLEAKS" "EXPECTED_COMMAND"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function GitleaksCommandCustomLogLevelTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local EXPECTED_GITLEAKS_LOG_LEVEL="debug"
  GitleaksCommandTest

  notice "${FUNCTION_NAME} PASS"
}

function InitInputConsumeCommandsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_ANSIBLE=("${BASE_LINTER_COMMANDS_ARRAY_ANSIBLE[@]}" "${INPUT_CONSUME_COMMAND[@]}")
  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_GO_MODULES=("${BASE_LINTER_COMMANDS_ARRAY_GO_MODULES[@]}" "${INPUT_CONSUME_COMMAND[@]}")

  # Add some custom options to the Rust command to ensure that they are added before the "input consume" command
  # shellcheck disable=SC2034
  local RUST_CLIPPY_COMMAND_OPTIONS_ARRAY=("--verbose --help")
  RUST_CLIPPY_COMMAND_OPTIONS="${RUST_CLIPPY_COMMAND_OPTIONS_ARRAY[*]}"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_RUST_CLIPPY=("${BASE_LINTER_COMMANDS_ARRAY_RUST_CLIPPY[@]}" "${RUST_CLIPPY_COMMAND_OPTIONS_ARRAY[@]}" "${INPUT_CONSUME_COMMAND[@]}")

  if ! InitInputConsumeCommands; then
    fatal "Error while initializing GNU parallel input consume commands"
  fi

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_ANSIBLE" "EXPECTED_LINTER_COMMANDS_ARRAY_ANSIBLE"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GO_MODULES" "EXPECTED_LINTER_COMMANDS_ARRAY_GO_MODULES"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_RUST_CLIPPY" "EXPECTED_LINTER_COMMANDS_ARRAY_RUST_CLIPPY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

AddDebugOptionsToCommandsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local LOG_DEBUG="true"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  # shellcheck disable=SC2034
  EXPECTED_LINTER_COMMANDS_ARRAY_XML=("${BASE_LINTER_COMMANDS_ARRAY_XML[@]}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_XML" "EXPECTED_LINTER_COMMANDS_ARRAY_XML"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  LOG_DEBUG="false"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  # shellcheck disable=SC2034
  EXPECTED_LINTER_COMMANDS_ARRAY_XML=("${BASE_LINTER_COMMANDS_ARRAY_XML[@]}" "${XMLLINT_NOOUT_OPTIONS[@]}")

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_XML" "EXPECTED_LINTER_COMMANDS_ARRAY_XML"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # Restore LOG_DEBUG
  # shellcheck disable=SC2034
  LOG_DEBUG="true"

  notice "${FUNCTION_NAME} PASS"
}

function InitFixModeOptionsAndCommandsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local LANGUAGE_ARRAY=("A" "B" "C")

  # Test a command that has only fix mode options to add
  # shellcheck disable=SC2034
  local A_FIX_MODE_OPTIONS=(--fixA)

  # Test a command that has only check only mode options to add
  # shellcheck disable=SC2034
  local B_CHECK_ONLY_MODE_TEST=(--checkB)

  # Test a command that has both fix mode and check only mode options to add
  # shellcheck disable=SC2034
  local C_CHECK_ONLY_MODE_TEST=(--checkC)
  # shellcheck disable=SC2034
  local C_FIX_MODE_OPTIONS=(--fixC)

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local -n FIX_LANGUAGE_VARIABLE_NAME="FIX_${LANGUAGE}"

    # shellcheck disable=SC2034
    FIX_LANGUAGE_VARIABLE_NAME="true"

    local -n LINTER_COMMANDS_ARRAY="LINTER_COMMANDS_ARRAY_${LANGUAGE}"
    # shellcheck disable=SC2034
    LINTER_COMMANDS_ARRAY=("LINTER_COMMANDS_ARRAY_FOR_LINTER_${LANGUAGE}_FIX_MODE_TEST")
    EXPECTED_LINTER_COMMANDS_ARRAY_FIX_MODE=("${LINTER_COMMANDS_ARRAY[@]}")
    local FIX_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_FIX_MODE_OPTIONS"
    if [[ -v "${FIX_MODE_OPTIONS_VARIABLE_NAME}" ]]; then
      local -n FIX_MODE_OPTIONS="${FIX_MODE_OPTIONS_VARIABLE_NAME}"
      # shellcheck disable=SC2034
      EXPECTED_LINTER_COMMANDS_ARRAY_FIX_MODE+=("${FIX_MODE_OPTIONS[@]}")
      unset -n FIX_MODE_OPTIONS
    fi
    if ! InitFixModeOptionsAndCommands "${LANGUAGE}"; then
      fatal "InitFixModeOptionsAndCommands for ${LANGUAGE} should have passed validation"
    fi
    if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY" "EXPECTED_LINTER_COMMANDS_ARRAY_FIX_MODE"; then
      fatal "${FUNCTION_NAME} ${!FIX_LANGUAGE_VARIABLE_NAME}: ${FIX_LANGUAGE_VARIABLE_NAME} test failed"
    fi

    # shellcheck disable=SC2034
    FIX_LANGUAGE_VARIABLE_NAME="false"
    LINTER_COMMANDS_ARRAY=("LINTER_COMMANDS_ARRAY_FOR_LINTER_${LANGUAGE}_CHECK_ONLY_MODE_TEST")
    # shellcheck disable=SC2034
    EXPECTED_LINTER_COMMANDS_ARRAY_CHECK_ONLY_MODE=("${LINTER_COMMANDS_ARRAY[@]}")
    local CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME="${LANGUAGE}_CHECK_ONLY_MODE_OPTIONS"
    if [[ -v "${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}" ]]; then
      local -n CHECK_ONLY_MODE_OPTIONS="${CHECK_ONLY_MODE_OPTIONS_VARIABLE_NAME}"
      # shellcheck disable=SC2034
      EXPECTED_LINTER_COMMANDS_ARRAY_CHECK_ONLY_MODE+=("${CHECK_ONLY_MODE_OPTIONS[@]}")
      unset -n CHECK_ONLY_MODE_OPTIONS
    fi
    if ! InitFixModeOptionsAndCommands "${LANGUAGE}"; then
      fatal "InitFixModeOptionsAndCommands for ${LANGUAGE} should have passed validation"
    fi
    if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY" "EXPECTED_LINTER_COMMANDS_ARRAY_CHECK_ONLY_MODE"; then
      fatal "${FUNCTION_NAME} ${!FIX_LANGUAGE_VARIABLE_NAME}: ${FIX_LANGUAGE_VARIABLE_NAME} test failed"
    fi

    unset -n FIX_LANGUAGE_VARIABLE_NAME
    unset -n LINTER_COMMANDS_ARRAY
  done

  notice "${FUNCTION_NAME} PASS"
}

function InitPowerShellCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  EXPECTED_LINTER_COMMANDS_ARRAY_POWERSHELL=(pwsh -NoProfile -NoLogo -Command "\"${LINTER_COMMANDS_ARRAY_POWERSHELL[*]}; if (\\\${Error}.Count) { exit 1 }\"")
  InitPowerShellCommand

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_POWERSHELL" "EXPECTED_LINTER_COMMANDS_ARRAY_POWERSHELL"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

BashExecIgnoreLibrariesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  local BASH_EXEC_IGNORE_LIBRARIES="true"

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_BASH_EXEC=("${BASE_LINTER_COMMANDS_ARRAY_BASH_EXEC[@]}" "true")

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_BASH_EXEC" "EXPECTED_LINTER_COMMANDS_ARRAY_BASH_EXEC"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

# Test environment variables to set command options
CommandOptionsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # Add custom arguments to linter commands that support them.

  ARGS_TO_ADD="--arg1 --arg2"

  # shellcheck disable=SC2034
  local GITHUB_ACTIONS_COMMAND_ARGS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local GITLEAKS_COMMAND_OPTIONS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local JAVA_COMMAND_ARGS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local JAVA_JVM_COMMAND_ARGS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local KUBERNETES_KUBECONFORM_OPTIONS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local PERL_PERLCRITIC_OPTIONS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local PRETTIER_COMMAND_OPTIONS="${ARGS_TO_ADD}"
  # shellcheck disable=SC2034
  local RUST_CLIPPY_COMMAND_OPTIONS="${ARGS_TO_ADD}"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_GITLEAKS=("${BASE_LINTER_COMMANDS_ARRAY_GITLEAKS[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_GITLEAKS" "${GITLEAKS_COMMAND_OPTIONS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GITLEAKS" "EXPECTED_LINTER_COMMANDS_ARRAY_GITLEAKS"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS=("${BASE_LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS" "${GITHUB_ACTIONS_COMMAND_ARGS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS" "EXPECTED_LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # Test both the options to add to the JVM and the options to add to the command
  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_JAVA=("${BASE_LINTER_COMMANDS_ARRAY_JAVA[0]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_JAVA" "${JAVA_JVM_COMMAND_ARGS}"
  EXPECTED_LINTER_COMMANDS_ARRAY_JAVA+=("${BASE_LINTER_COMMANDS_ARRAY_JAVA[@]:1}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_JAVA" "${JAVA_COMMAND_ARGS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_JAVA" "EXPECTED_LINTER_COMMANDS_ARRAY_JAVA"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM=("${BASE_LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM" "${KUBERNETES_KUBECONFORM_OPTIONS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM" "EXPECTED_LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_PERL=("${BASE_LINTER_COMMANDS_ARRAY_PERL[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_PERL" "${PERL_PERLCRITIC_OPTIONS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_PERL" "EXPECTED_LINTER_COMMANDS_ARRAY_PERL"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_PRETTIER=("${BASE_LINTER_COMMANDS_ARRAY_PRETTIER[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_PRETTIER" "${PRETTIER_COMMAND_OPTIONS}"
  if ! AssertArraysElementsContentMatch "PRETTIER_COMMAND" "EXPECTED_LINTER_COMMANDS_ARRAY_PRETTIER"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  # shellcheck disable=SC2034
  local EXPECTED_LINTER_COMMANDS_ARRAY_RUST_CLIPPY=("${BASE_LINTER_COMMANDS_ARRAY_RUST_CLIPPY[@]}")
  AddOptionsToCommand "EXPECTED_LINTER_COMMANDS_ARRAY_RUST_CLIPPY" "${RUST_CLIPPY_COMMAND_OPTIONS}"
  if ! AssertArraysElementsContentMatch "LINTER_COMMANDS_ARRAY_RUST_CLIPPY" "EXPECTED_LINTER_COMMANDS_ARRAY_RUST_CLIPPY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

AddOptionsToCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local TEST_LINTER_COMMANDS_ARRAY=("command1")

  ARG_TO_ADD_1="--arg1"
  ARG_TO_ADD_2="--arg2"

  # shellcheck disable=SC2034
  local EXPECTED_COMMAND_ARRAY=("${TEST_LINTER_COMMANDS_ARRAY[@]}" "${ARG_TO_ADD_1}" "${ARG_TO_ADD_2}")

  AddOptionsToCommand "TEST_LINTER_COMMANDS_ARRAY" "${ARG_TO_ADD_1} ${ARG_TO_ADD_2}"
  if ! AssertArraysElementsContentMatch "TEST_LINTER_COMMANDS_ARRAY" "EXPECTED_COMMAND_ARRAY"; then
    fatal "${FUNCTION_NAME} test failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

LinterCommandPresenceTest
IgnoreGitIgnoredFilesJscpdCommandTest
JscpdCommandTest
EnableCommitlintEditModeCommandTest
EnableCommitlintStrictModeCommandTest
GitleaksCommandTest
GitleaksCommandCustomLogLevelTest
InitInputConsumeCommandsTest
InitFixModeOptionsAndCommandsTest
InitPowerShellCommandTest
BashExecIgnoreLibrariesTest
CommandOptionsTest
AddOptionsToCommandTest
AddDebugOptionsToCommandsTest
