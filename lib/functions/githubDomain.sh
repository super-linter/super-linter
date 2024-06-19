#!/usr/bin/env bash

DEFAULT_GITHUB_DOMAIN="github.com"
GITHUB_DOMAIN="${GITHUB_DOMAIN:-${DEFAULT_GITHUB_DOMAIN}}"
GITHUB_DOMAIN="${GITHUB_DOMAIN%/}" # Remove trailing slash if present

# GitHub API root url
GITHUB_API_URL="${GITHUB_CUSTOM_API_URL:-"https://api.${GITHUB_DOMAIN}"}"
GITHUB_API_URL="${GITHUB_API_URL%/}" # Remove trailing slash if present

# shellcheck disable=SC2034  # Variable is referenced indirectly
GITHUB_SERVER_URL="${GITHUB_CUSTOM_SERVER_URL:-"https://${GITHUB_DOMAIN}"}"
GITHUB_SERVER_URL="${GITHUB_SERVER_URL%/}" # Remove trailing slash if present

# shellcheck disable=SC2034  # Variable is referenced indirectly
GITHUB_META_URL="${GITHUB_API_URL}/meta"

debug "GitHub server URL: ${GITHUB_SERVER_URL}"
debug "GitHub API URL: ${GITHUB_API_URL}"
debug "GitHub meta URL: ${GITHUB_META_URL}"
