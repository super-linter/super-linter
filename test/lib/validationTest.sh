#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC2034
CREATE_LOG_FILE=false
# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/functions/validation.sh"

function IsUnsignedIntegerSuccessTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

  if ! IsUnsignedInteger 1; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

function IsUnsignedIntegerFailureTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

  if IsUnsignedInteger "test"; then
    fatal "${FUNCTION_NAME} failed"
  fi

  notice "${FUNCTION_NAME} PASS"
}

# In the current implementation, there is no return value to assert
function ValidateDeprecatedVariablesTest() {
  FUNCTION_NAME="${FUNCNAME[0]}"

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
  FUNCTION_NAME="${FUNCNAME[0]}"

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

IsUnsignedIntegerSuccessTest
IsUnsignedIntegerFailureTest
ValidateDeprecatedVariablesTest
ValidateGitHubUrlsTest
