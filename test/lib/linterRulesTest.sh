#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
source "test/testUtils.sh"

# shellcheck source=/dev/null
source "lib/functions/detectFiles.sh"

# shellcheck source=/dev/null
source "lib/globals/linterRules.sh"

TEST_LANGUAGE_NAME="TEST_LANGUAGE"
TEST_LANGUAGE_NAME_WITHOUT_RULES="TEST_LANGUAGE_WITHOUT_RULES"
TEST_LANGUAGE_ARRAY=("${TEST_LANGUAGE_NAME}" "${TEST_LANGUAGE_NAME_WITHOUT_RULES}")

# shellcheck source=/dev/null
source "lib/functions/linterRules.sh"

# shellcheck disable=SC2034
GITHUB_WORKSPACE="$(pwd)"

function GetLinterRulesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  LinterRulesLocation

  DEFAULT_RULES_LOCATION="${DEFAULT_RULES_LOCATION:-"TEMPLATES"}"
  # Use an existing configuration file. Can be anything inside
  # DEFAULT_RULES_LOCATION that is also in
  # ${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}
  TEST_LANGUAGE_FILE_NAME="${TEST_LANGUAGE_FILE_NAME:-".jscpd.json"}"
  for LANGUAGE in "${TEST_LANGUAGE_ARRAY[@]}"; do
    debug "Loading rules for ${LANGUAGE}..."
    GetLinterRules "${LANGUAGE}" "${DEFAULT_RULES_LOCATION}"
  done

  local EXPECTED_TEST_LANGUAGE_LINTER_RULES="${GITHUB_WORKSPACE}"
  if [[ -n "${LINTER_RULES_PATH:-}" ]]; then
    EXPECTED_TEST_LANGUAGE_LINTER_RULES="${EXPECTED_TEST_LANGUAGE_LINTER_RULES}/${LINTER_RULES_PATH}"
  fi
  EXPECTED_TEST_LANGUAGE_LINTER_RULES="${EXPECTED_TEST_LANGUAGE_LINTER_RULES}/${TEST_LANGUAGE_FILE_NAME}"

  if [[ "${TEST_LANGUAGE_LINTER_RULES}" == "${EXPECTED_TEST_LANGUAGE_LINTER_RULES}" ]]; then
    debug "TEST_LANGUAGE_LINTER_RULES (${TEST_LANGUAGE_LINTER_RULES}) matches the expected value (${EXPECTED_TEST_LANGUAGE_LINTER_RULES})"
  else
    fatal "TEST_LANGUAGE_LINTER_RULES (${TEST_LANGUAGE_LINTER_RULES}) doesn't match the expected value (${EXPECTED_TEST_LANGUAGE_LINTER_RULES})"
  fi
  if [[ -z "${TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES:-}" ]]; then
    debug "TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES is not set as expected"
  else
    fatal "TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES shouldn't be set"
  fi
  unset TEST_LANGUAGE_LINTER_RULES
  unset TEST_LANGUAGE_WITHOUT_RULES_LINTER_RULES
  unset EXPECTED_TEST_LANGUAGE_LINTER_RULES

  notice "${FUNCTION_NAME} PASS"
}

function GetLinterRulesEmptyDotRulesPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LINTER_RULES_PATH="."
  TEST_LANGUAGE_FILE_NAME="README.md"
  DEFAULT_RULES_LOCATION="$(pwd)"
  GetLinterRulesTest

  unset LINTER_RULES_PATH
  unset TEST_LANGUAGE_FILE_NAME

  notice "${FUNCTION_NAME} PASS"
}

function GetLinterRulesEmptyRootRulesPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LINTER_RULES_PATH="."
  TEST_LANGUAGE_FILE_NAME="README.md"
  DEFAULT_RULES_LOCATION="$(pwd)"
  GetLinterRulesTest

  unset LINTER_RULES_PATH
  unset TEST_LANGUAGE_FILE_NAME

  notice "${FUNCTION_NAME} PASS"
}

function LinterRulesVariablesExportTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  DEFAULT_RULES_LOCATION="TEMPLATES"
  TEST_LANGUAGE_FILE_NAME="eslint.config.mjs"

  # shellcheck source=/dev/null
  source "lib/globals/linterRules.sh"

  for LANGUAGE in "${TEST_LANGUAGE_ARRAY[@]}"; do
    debug "Loading rules for ${LANGUAGE}..."
    GetLinterRules "${LANGUAGE}" "${DEFAULT_RULES_LOCATION}"
  done

  for LANGUAGE in "${TEST_LANGUAGE_ARRAY[@]}"; do
    debug "Verify that ${LANGUAGE} configuration file variable is exported"
    if [[ "${LANGUAGE}" == "${TEST_LANGUAGE_NAME_WITHOUT_RULES}" ]]; then
      debug "${LANGUAGE} doesn't have linter configuration file variable. Skipping export test."
      continue
    fi

    local LANGUAGE_LINTER_RULES_VARIABLE_NAME="${LANGUAGE}_LINTER_RULES"
    if [[ ! -v "${LANGUAGE_LINTER_RULES_VARIABLE_NAME}" ]]; then
      fatal "${LANGUAGE_LINTER_RULES_VARIABLE_NAME} is not defined"
    fi
    local -n LANGUAGE_LINTER_RULES
    LANGUAGE_LINTER_RULES="${LANGUAGE_LINTER_RULES_VARIABLE_NAME}"

    debug "LANGUAGE_LINTER_RULES (${LANGUAGE}) variable attributes: ${LANGUAGE_LINTER_RULES@a}"
    if [[ "${LANGUAGE_LINTER_RULES@a}" == *x* ]]; then
      info "LANGUAGE_LINTER_RULES for ${LANGUAGE} is exported as expected"
    else
      fatal "LANGUAGE_LINTER_RULES for ${LANGUAGE} should have been exported"
    fi
    unset -n LANGUAGE_LINTER_RULES
  done

  notice "${FUNCTION_NAME} PASS"
}

function CodespellDefaultConfigurationSkipsPackageLockFilesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local TEST_DIRECTORY
  TEST_DIRECTORY="$(mktemp -d)"
  initialize_temp_directory_cleanup_traps "${TEST_DIRECTORY}"
  mkdir -p "${TEST_DIRECTORY}/nested"
  printf '{"description":"t%sh"}\n' "e" >"${TEST_DIRECTORY}/package-lock.json"
  printf '{"description":"t%sh"}\n' "e" >"${TEST_DIRECTORY}/nested/package-lock.json"

  local CODESPELL_DEFAULT_CONFIGURATION
  CODESPELL_DEFAULT_CONFIGURATION="$(realpath "TEMPLATES/.codespellrc")"
  if ! (
    cd "${TEST_DIRECTORY}"
    codespell --config "${CODESPELL_DEFAULT_CONFIGURATION}" package-lock.json nested/package-lock.json
  ); then
    fatal "The default codespell configuration should skip package-lock.json files at the workspace root and in nested directories"
  fi

  notice "${FUNCTION_NAME} PASS"
}

AssertPreCommitConfigurationFileName() {
  local EXPECTED_PRE_COMMIT_FILE_NAME="${1}"
  local TEST_DESCRIPTION="${2}"

  InitializePreCommitConfigurationFileName

  if [[ "${PRE_COMMIT_FILE_NAME}" == "${EXPECTED_PRE_COMMIT_FILE_NAME}" ]]; then
    debug "PRE_COMMIT_FILE_NAME (${PRE_COMMIT_FILE_NAME}) matches the expected value when ${TEST_DESCRIPTION}"
  else
    fatal "PRE_COMMIT_FILE_NAME (${PRE_COMMIT_FILE_NAME}) doesn't match the expected value (${EXPECTED_PRE_COMMIT_FILE_NAME}) when ${TEST_DESCRIPTION}"
  fi
}

InitializePreCommitConfigurationFileNameTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  local GITHUB_WORKSPACE
  GITHUB_WORKSPACE="$(mktemp -d)"
  initialize_temp_directory_cleanup_traps "${GITHUB_WORKSPACE}"

  local LINTER_RULES_PATH=".github/linters"
  local PRE_COMMIT_CONFIGURATION_DIRECTORY="${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}"
  mkdir -p "${PRE_COMMIT_CONFIGURATION_DIRECTORY}"

  local DEFAULT_PRE_COMMIT_FILE_NAME=".pre-commit-config.yaml"
  local PRE_COMMIT_CONFIG_FILE=""
  local PRE_COMMIT_ENGINE="prek"
  local PRE_COMMIT_FILE_NAME

  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName "${DEFAULT_PRE_COMMIT_FILE_NAME}" "there are no configuration files"

  touch "${PRE_COMMIT_CONFIGURATION_DIRECTORY}/.pre-commit-config.yml"
  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName ".pre-commit-config.yml" "there is only .pre-commit-config.yml"

  touch "${PRE_COMMIT_CONFIGURATION_DIRECTORY}/.pre-commit-config.yaml"
  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName ".pre-commit-config.yaml" "there are .pre-commit-config.yaml and .pre-commit-config.yml"

  touch "${PRE_COMMIT_CONFIGURATION_DIRECTORY}/prek.toml"
  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName "prek.toml" "there are prek.toml and YAML configuration files"

  local PRE_COMMIT_LINTER_RULES
  GetLinterRules "PRE_COMMIT" "TEMPLATES"
  if [[ "${PRE_COMMIT_LINTER_RULES}" != "${PRE_COMMIT_CONFIGURATION_DIRECTORY}/prek.toml" ]]; then
    fatal "PRE_COMMIT_LINTER_RULES (${PRE_COMMIT_LINTER_RULES}) doesn't match the expected value (${PRE_COMMIT_CONFIGURATION_DIRECTORY}/prek.toml)"
  fi

  PRE_COMMIT_ENGINE="pre-commit"
  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName "${DEFAULT_PRE_COMMIT_FILE_NAME}" "PRE_COMMIT_ENGINE is pre-commit"

  # shellcheck disable=SC2034 # Used by InitializePreCommitConfigurationFileName
  PRE_COMMIT_ENGINE="prek"
  PRE_COMMIT_CONFIG_FILE="custom-pre-commit-config.yaml"
  PRE_COMMIT_FILE_NAME="${PRE_COMMIT_CONFIG_FILE}"
  AssertPreCommitConfigurationFileName "${PRE_COMMIT_CONFIG_FILE}" "PRE_COMMIT_CONFIG_FILE is set"
  PRE_COMMIT_CONFIG_FILE=""

  LINTER_RULES_PATH=""
  touch "${GITHUB_WORKSPACE}/prek.toml"
  PRE_COMMIT_FILE_NAME="${DEFAULT_PRE_COMMIT_FILE_NAME}"
  AssertPreCommitConfigurationFileName "prek.toml" "LINTER_RULES_PATH is the workspace root"

  notice "${FUNCTION_NAME} PASS"
}

LoadDefaultRulesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  debug "LANGUAGE_ARRAY: ${LANGUAGE_ARRAY[*]}"

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    debug "Test Loading rules for ${LANGUAGE}..."
    if ! GetLinterRules "${LANGUAGE}" "${DEFAULT_RULES_LOCATION}"; then
      fatal "Failed loading rules for ${LANGUAGE}"
    fi
  done

  notice "${FUNCTION_NAME} PASS"
}

GetLinterRulesTest
GetLinterRulesEmptyDotRulesPathTest
GetLinterRulesEmptyRootRulesPathTest
LinterRulesVariablesExportTest
CodespellDefaultConfigurationSkipsPackageLockFilesTest
InitializePreCommitConfigurationFileNameTest
LoadDefaultRulesTest
