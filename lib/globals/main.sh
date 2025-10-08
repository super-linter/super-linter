#!/usr/bin/env bash

# shellcheck disable=SC2034 # Variable is referenced in other scripts
DEFAULT_SUPER_LINTER_WORKSPACE="/tmp/lint"                                  # Fall-back value for the workspace
DEFAULT_WORKSPACE="${DEFAULT_WORKSPACE:-${DEFAULT_SUPER_LINTER_WORKSPACE}}" # Default workspace if running locally

# shellcheck disable=SC2034 # Variable is referenced in other scripts
TEST_CASE_FOLDER='test/linters' # Folder for test cases we should always ignore

declare -l STRIP_DEFAULT_WORKSPACE_FOR_REGEX
STRIP_DEFAULT_WORKSPACE_FOR_REGEX="${STRIP_DEFAULT_WORKSPACE_FOR_REGEX:-"false"}"
