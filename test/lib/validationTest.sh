#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/functions/validation.sh"

function IsUnsignedIntegerSuccessTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  if ! IsUnsignedInteger 1; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function IsUnsignedIntegerFailureTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  if IsUnsignedInteger "test"; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

# In the current implementation, there is no return value to assert
function ValidateDeprecatedVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  ERROR_ON_MISSING_EXEC_BIT="true" \
    ValidateDeprecatedVariables
  EXPERIMENTAL_BATCH_WORKER="true" \
    ValidateDeprecatedVariables
  LOG_LEVEL="TRACE" \
    ValidateDeprecatedVariables
  LOG_LEVEL="VERBOSE" \
    ValidateDeprecatedVariables
  VALIDATE_JSCPD_ALL_CODEBASE="true" \
    ValidateDeprecatedVariables
  VALIDATE_KOTLIN_ANDROID="true" \
    ValidateDeprecatedVariables

  notice "${FUNCTION_NAME} PASS"
}

function ValidateGitHubUrlsTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  DEFAULT_GITHUB_DOMAIN="github.com"

  # shellcheck disable=SC2034
  GITHUB_DOMAIN=
  if ValidateGitHubUrls; then
    fatal "Empty GITHUB_DOMAIN should have failed validation"
  else
    info "Empty GITHUB_DOMAIN passed validation"
  fi

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="github.example.com"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} should have passed validation"
  else
    info "${GITHUB_DOMAIN} passed validation"
  fi
  unset GITHUB_DOMAIN

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} should have passed validation"
  else
    info "${GITHUB_DOMAIN} passed validation"
  fi
  unset GITHUB_DOMAIN

  GITHUB_DOMAIN="github.example.com"
  # shellcheck disable=SC2034
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="github.example.com"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_SERVER_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_API_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} should have failed validation"
  else
    info "${GITHUB_DOMAIN} and ${GITHUB_CUSTOM_SERVER_URL} failed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_SERVER_URL

  # shellcheck disable=SC2034
  GITHUB_DOMAIN="${DEFAULT_GITHUB_DOMAIN}"
  GITHUB_CUSTOM_API_URL="github.custom.api.url"
  GITHUB_CUSTOM_SERVER_URL="github.custom.server.url"
  if ! ValidateGitHubUrls; then
    fatal "${GITHUB_DOMAIN}, ${GITHUB_CUSTOM_API_URL}, and ${GITHUB_CUSTOM_SERVER_URL} should have passed validation"
  else
    info "${GITHUB_DOMAIN}, ${GITHUB_CUSTOM_API_URL}, and ${GITHUB_CUSTOM_SERVER_URL} passed validation as expected"
  fi
  unset GITHUB_DOMAIN
  unset GITHUB_CUSTOM_API_URL
  unset GITHUB_CUSTOM_SERVER_URL

  notice "${FUNCTION_NAME} PASS"
}

function ValidateSuperLinterSummaryOutputPathTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="/non/existing/file"
  if ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have failed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a non-existing file"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} failed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="$(pwd)"
  if ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have failed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a directory"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} failed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  SUPER_LINTER_SUMMARY_OUTPUT_PATH="${0}"
  if ! ValidateSuperLinterSummaryOutputPath; then
    fatal "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} should have passed validation when SUPER_LINTER_SUMMARY_OUTPUT_PATH is set to a file"
  else
    info "SUPER_LINTER_SUMMARY_OUTPUT_PATH=${SUPER_LINTER_SUMMARY_OUTPUT_PATH} passed validation as expected"
  fi
  unset SUPER_LINTER_SUMMARY_OUTPUT_PATH

  notice "${FUNCTION_NAME} PASS"
}

function ValidateFindModeTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  USE_FIND_ALGORITHM="true"
  VALIDATE_ALL_CODEBASE="false"
  if ValidateFindMode; then
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have failed validation"
  else
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} failed validation as expected"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="false"
  VALIDATE_ALL_CODEBASE="false"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="false"
  VALIDATE_ALL_CODEBASE="true"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  USE_FIND_ALGORITHM="true"
  VALIDATE_ALL_CODEBASE="true"
  if ValidateFindMode; then
    info "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} passed validation as expected"
  else
    fatal "USE_FIND_ALGORITHM=${USE_FIND_ALGORITHM}, VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} should have passed validation"
  fi
  unset USE_FIND_ALGORITHM
  unset VALIDATE_ALL_CODEBASE

  notice "${FUNCTION_NAME} PASS"
}

function ValidateAnsibleDirectoryTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  GITHUB_WORKSPACE="/test-github-workspace"

  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/ansible"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  ANSIBLE_DIRECTORY="."
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  INPUT_ANSIBLE_DIRECTORY="/custom-ansible-directory"
  ANSIBLE_DIRECTORY="${INPUT_ANSIBLE_DIRECTORY}"
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}${INPUT_ANSIBLE_DIRECTORY}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  INPUT_ANSIBLE_DIRECTORY="custom-ansible-directory"
  ANSIBLE_DIRECTORY="${INPUT_ANSIBLE_DIRECTORY}"
  ValidateAnsibleDirectory
  EXPECTED_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/${INPUT_ANSIBLE_DIRECTORY}"
  if [[ "${ANSIBLE_DIRECTORY:-}" != "${EXPECTED_ANSIBLE_DIRECTORY}" ]]; then
    fatal "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) is not equal to the expected value: ${EXPECTED_ANSIBLE_DIRECTORY}"
  fi

  unset GITHUB_WORKSPACE

  notice "${FUNCTION_NAME} PASS"
}

function ValidateValidationVariablesTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A' 'B')

  if ValidateValidationVariables; then
    info "Providing no VALIDATE_xxx variables passed validation as expected"
  else
    fatal "Providing no VALIDATE_xxx variables should have passed validation"
  fi

  VALIDATE_A="true"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A} should have passed validation"
  fi
  unset VALIDATE_A

  # TODO: Refactor the ValidateBooleanVariable function to throw an error instead of a fatal
  # VALIDATE_A="blah"
  # if ! ValidateValidationVariables; then
  #   info "VALIDATE_A=${VALIDATE_A} failed validation as expected"
  # else
  #   fatal "VALIDATE_A=${VALIDATE_A} should have failed validation"
  # fi
  # unset VALIDATE_A

  VALIDATE_A="true"
  VALIDATE_B="true"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have passed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="false"
  VALIDATE_B="false"
  if ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} passed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have passed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="true"
  VALIDATE_B="false"
  if ! ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} failed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have failed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  VALIDATE_A="false"
  VALIDATE_B="true"
  if ! ValidateValidationVariables; then
    info "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} failed validation as expected"
  else
    fatal "VALIDATE_A=${VALIDATE_A}, VALIDATE_B=${VALIDATE_B} should have failed validation"
  fi
  unset VALIDATE_A
  unset VALIDATE_B

  notice "${FUNCTION_NAME} PASS"
}

function ValidationVariablesExportTest() {
  local FUNCTION_NAME
  FUNCTION_NAME="${FUNCNAME[0]}"
  info "${FUNCTION_NAME} start"

  # shellcheck disable=SC2034
  LANGUAGE_ARRAY=('A' 'B')

  ValidateValidationVariables

  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    local -n VALIDATE_LANGUAGE
    VALIDATE_LANGUAGE="VALIDATE_${LANGUAGE}"
    debug "VALIDATE_LANGUAGE (${LANGUAGE}) variable attributes: ${VALIDATE_LANGUAGE@a}"
    if [[ "${VALIDATE_LANGUAGE@a}" == *x* ]]; then
      info "VALIDATE_LANGUAGE for ${LANGUAGE} is exported as expected"
    else
      fatal "VALIDATE_LANGUAGE for ${LANGUAGE} should have been exported"
    fi
    unset -n VALIDATE_LANGUAGE
  done

  notice "${FUNCTION_NAME} PASS"
}

IsUnsignedIntegerSuccessTest
IsUnsignedIntegerFailureTest
ValidateDeprecatedVariablesTest
ValidateGitHubUrlsTest
ValidateSuperLinterSummaryOutputPathTest
ValidateFindModeTest
ValidateAnsibleDirectoryTest
ValidateValidationVariablesTest
ValidationVariablesExportTest
