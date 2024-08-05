#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

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
GITHUB_WORKSPACE="$(pwd)"
# shellcheck disable=SC2034
IGNORE_GITIGNORED_FILES="false"
LINTER_RULES_PATH="TEMPLATES"
# shellcheck disable=SC2034
TYPESCRIPT_STANDARD_TSCONFIG_FILE=".github/linters/tsconfig.json"
# shellcheck disable=SC2034
YAML_ERROR_ON_WARNING="false"
for LANGUAGE in "${LANGUAGE_ARRAY_FOR_LINTER_RULES[@]}"; do
  GetLinterRules "${LANGUAGE}" "${LINTER_RULES_PATH}"
done
ValidateValidationVariables

# The slim image might not have this variable defined
if [[ ! -v ARM_TTK_PSD1 ]]; then
  ARM_TTK_PSD1="/usr/lib/microsoft/arm-ttk/arm-ttk.psd1"
fi

# Source the file so we can load commands to compare them without redefining
# each command. We're not interested in the actual values of those commands, but
# only in how we eventually modify them.

# shellcheck source=/dev/null
source "lib/functions/linterCommands.sh"

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
  IGNORE_GITIGNORED_FILES="true"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  EXPECTED_COMMAND=("${LINTER_COMMANDS_ARRAY_JSCPD[@]}" "${JSCPD_GITIGNORE_OPTION}")

  if [[ "${LINTER_COMMANDS_ARRAY_JSCPD[*]}" == "${EXPECTED_COMMAND[*]}" ]]; then
    debug "Command (${LINTER_COMMANDS_ARRAY_JSCPD[*]}) matches with the expected one (${EXPECTED_COMMAND[*]})"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function JscpdCommandTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # Source the file again so it accounts for modifications
  # shellcheck source=/dev/null
  source "lib/functions/linterCommands.sh"

  EXPECTED_COMMAND=(jscpd --config "${JSCPD_LINTER_RULES}")

  if [[ "${LINTER_COMMANDS_ARRAY_JSCPD[*]}" == "${EXPECTED_COMMAND[*]}" ]]; then
    debug "Command (${LINTER_COMMANDS_ARRAY_JSCPD[*]}) matches with the expected one (${EXPECTED_COMMAND[*]})"
  fi

  notice "${FUNCTION_NAME} PASS"
}

LinterCommandPresenceTest
IgnoreGitIgnoredFilesJscpdCommandTest
JscpdCommandTest
