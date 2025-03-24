#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default log level
# shellcheck disable=SC2034
LOG_LEVEL="DEBUG"

# Create log file by default
# shellcheck disable=SC2034
CREATE_LOG_FILE="true"

# shellcheck source=/dev/null
source "lib/functions/log.sh"

# shellcheck source=/dev/null
source "lib/globals/languages.sh"

# Because we need variables defined there
# shellcheck source=/dev/null
source "lib/functions/output.sh"

# TODO: use TEST_CASE_FOLDER instead of redefining this after we extract the
# initialization of TEST_CASE_FOLDER from linter.sh
# shellcheck disable=SC2034
LINTERS_TEST_CASE_DIRECTORY="test/linters"

# shellcheck disable=SC2034
LANGUAGES_WITH_FIX_MODE=(
  "ANSIBLE"
  "CLANG_FORMAT"
  "CSHARP"
  "CSS"
  "CSS_PRETTIER"
  "DOTNET_SLN_FORMAT_ANALYZERS"
  "DOTNET_SLN_FORMAT_STYLE"
  "DOTNET_SLN_FORMAT_WHITESPACE"
  "ENV"
  "GO_MODULES"
  "GO"
  "GOOGLE_JAVA_FORMAT"
  "GROOVY"
  "GRAPHQL_PRETTIER"
  "HTML_PRETTIER"
  "JAVASCRIPT_ES"
  "JAVASCRIPT_PRETTIER"
  "JAVASCRIPT_STANDARD"
  "JSON"
  "JSON_PRETTIER"
  "JSONC"
  "JSONC_PRETTIER"
  "JSX"
  "JSX_PRETTIER"
  "JUPYTER_NBQA_BLACK"
  "JUPYTER_NBQA_ISORT"
  "JUPYTER_NBQA_RUFF"
  "MARKDOWN"
  "MARKDOWN_PRETTIER"
  "NATURAL_LANGUAGE"
  "POWERSHELL"
  "PROTOBUF"
  "PYTHON_BLACK"
  "PYTHON_ISORT"
  "PYTHON_PYINK"
  "PYTHON_RUFF"
  "RUBY"
  "RUST_2015"
  "RUST_2018"
  "RUST_2021"
  "RUST_CLIPPY"
  "SCALAFMT"
  "SHELL_SHFMT"
  "SNAKEMAKE_SNAKEFMT"
  "SQLFLUFF"
  "TERRAFORM_FMT"
  "TSX"
  "TYPESCRIPT_ES"
  "TYPESCRIPT_PRETTIER"
  "TYPESCRIPT_STANDARD"
  "VUE_PRETTIER"
  "YAML_PRETTIER"
)

# TODO: extract this list from linter.sh (see REMOVE_ARRAY) instead of
# redefining it here
# shellcheck disable=SC2034
LANGUAGES_NOT_IN_SLIM_IMAGE=(
  "ARM"
  "CSHARP"
  "DOTNET_SLN_FORMAT_ANALYZERS"
  "DOTNET_SLN_FORMAT_STYLE"
  "DOTNET_SLN_FORMAT_WHITESPACE"
  "POWERSHELL"
  "RUST_2015"
  "RUST_2018"
  "RUST_2021"
  "RUST_CLIPPY"
)

DEFAULT_BRANCH="main"

function AssertArraysElementsContentMatch() {
  local ARRAY_1_VARIABLE_NAME="${1}"
  local ARRAY_2_VARIABLE_NAME="${2}"
  local -n ARRAY_1="${ARRAY_1_VARIABLE_NAME}"
  local -n ARRAY_2="${ARRAY_2_VARIABLE_NAME}"
  if [[ "${ARRAY_1[*]}" == "${ARRAY_2[*]}" ]]; then
    debug "${ARRAY_1_VARIABLE_NAME} (${ARRAY_1[*]}) matches the expected value: ${ARRAY_2[*]}"
    RETURN_CODE=0
  else
    error "${ARRAY_1_VARIABLE_NAME} (${ARRAY_1[*]}) doesn't match the expected value: ${ARRAY_2[*]}"
    RETURN_CODE=1
  fi
  unset -n ARRAY_1
  unset -n ARRAY_2
  return ${RETURN_CODE}
}

function CheckUnexpectedGitChanges() {
  local GIT_REPOSITORY_PATH="${1}"
  # Check if there are unexpected changes in the working directory:
  # - Unstaged changes
  # - Changes that are staged but not committed
  # - Untracked files and directories
  if ! git -C "${GIT_REPOSITORY_PATH}" diff --exit-code --quiet ||
    ! git -C "${GIT_REPOSITORY_PATH}" diff --cached --exit-code --quiet ||
    ! git -C "${GIT_REPOSITORY_PATH}" ls-files --others --exclude-standard --directory; then
    echo "There are unexpected changes in the working directory of the ${GIT_REPOSITORY_PATH} Git repository."
    git -C "${GIT_REPOSITORY_PATH}" status
    return 1
  fi
}

AssertFileAndDirContentsMatch() {
  local FILE_1_PATH="${1}"
  local FILE_2_PATH="${2}"
  if diff -r "${FILE_1_PATH}" "${FILE_2_PATH}"; then
    echo "${FILE_1_PATH} contents match with ${FILE_2_PATH} contents"
    return 0
  else
    echo "${FILE_1_PATH} contents don't match with ${FILE_2_PATH} contents"
    return 1
  fi
}

AssertFileContentsMatchIgnoreHtmlComments() {
  local FILE_1_PATH="${1}"
  local FILE_2_PATH="${2}"
  # Use cat -s to remove duplicate blank lines because Prettier adds blank
  # lines after HTML comments in Markdown files
  if diff "${FILE_1_PATH}" <(grep -vE '^\s*<!--' "${FILE_2_PATH}" | cat -s); then
    echo "${FILE_1_PATH} contents match with ${FILE_2_PATH} contents"
    return 0
  else
    echo "${FILE_1_PATH} contents don't match with ${FILE_2_PATH} contents"
    return 1
  fi
}

IsLanguageInSlimImage() {
  local LANGUAGE="${1}"
  if [[ " ${LANGUAGES_NOT_IN_SLIM_IMAGE[*]} " =~ [[:space:]]${LANGUAGE}[[:space:]] ]]; then
    debug "${LANGUAGE} is not available in the Super-linter slim image"
    return 1
  else
    debug "${LANGUAGE} is available in the Super-linter slim image"
    return 0
  fi
}

IsStandardImage() {
  if [[ "${IMAGE}" == "standard" ]]; then
    debug "This is the standard image"
    return 0
  else
    debug "This isn't the standard image"
    return 1
  fi
}

AreAnsiColorCodesInFile() {
  local FILE_TO_SEARCH_IN="${1}"
  if grep --color=never --quiet --perl-regexp "${ANSI_COLOR_CODES_SEARCH_PATTERN}" "${FILE_TO_SEARCH_IN}"; then
    debug "Found at least one ANSI color code in ${FILE_TO_SEARCH_IN}"
    return 0
  else
    debug "Found no ANSI color codes in ${FILE_TO_SEARCH_IN}"
    return 1
  fi
}

RemoveTestLeftovers() {
  local LEFTOVERS_TO_CLEAN=()
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/bad/target")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/bad/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/good/target")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/good/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/dependencies/composer/vendor")
  # Delete leftovers in pwd in case the workspace is not pwd
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/bad/target")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/bad/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/good/target")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${LINTERS_TEST_CASE_DIRECTORY}/rust_clippy/good/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/dependencies/composer/vendor")

  debug "Cleaning eventual test leftovers: ${LEFTOVERS_TO_CLEAN[*]}"
  sudo rm -rf "${LEFTOVERS_TO_CLEAN[@]}"
}

RemoveTestLogsAndSuperLinterOutputs() {
  local LEFTOVERS_TO_CLEAN=()
  LEFTOVERS_TO_CLEAN+=("${LOG_FILE_PATH}")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_MAIN_OUTPUT_PATH}")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_SUMMARY_FILE_PATH}")

  LEFTOVERS_TO_CLEAN+=("$(pwd)/$(basename "${LOG_FILE_PATH}")")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/$(basename "${SUPER_LINTER_GITHUB_STEP_SUMMARY_FILE_PATH}")")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/$(basename "${SUPER_LINTER_MAIN_OUTPUT_PATH}")")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/$(basename "${SUPER_LINTER_SUMMARY_FILE_PATH}")")

  debug "Cleaning eventual test logs and Super-linter outputs leftovers: ${LEFTOVERS_TO_CLEAN[*]}"
  sudo rm -rf "${LEFTOVERS_TO_CLEAN[@]}"
}

initialize_git_repository() {
  local GIT_REPOSITORY_PATH="${1}"

  # Assuming that if sudo is available we aren't running inside a container,
  # so we don't want to leave leftovers around.
  if command -v sudo; then
    if [[ "${KEEP_TEMP_FILES:-}" == "true" ]]; then
      # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
      trap "echo Temp git repository available at: '${GIT_REPOSITORY_PATH}'" EXIT
    else
      # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
      trap "echo 'Deleting ${GIT_REPOSITORY_PATH}. Set KEEP_TEMP_FILES=true to keep temporary files'; sudo rm -fr '${GIT_REPOSITORY_PATH}'" EXIT
    fi
  fi

  if [[ ! -d "${GIT_REPOSITORY_PATH}" ]]; then
    mkdir --parents "${GIT_REPOSITORY_PATH}"
  fi

  debug "GIT_REPOSITORY_PATH: ${GIT_REPOSITORY_PATH}"

  git -C "${GIT_REPOSITORY_PATH}" init --initial-branch="${DEFAULT_BRANCH:-"main"}"
  git -C "${GIT_REPOSITORY_PATH}" config user.name "Super-linter Test"
  git -C "${GIT_REPOSITORY_PATH}" config user.email "super-linter-test@example.com"
}

initialize_git_repository_and_test_args() {
  local GIT_REPOSITORY_PATH="${1}"

  initialize_git_repository "${GIT_REPOSITORY_PATH}"

  local GITHUB_EVENT_FILE_PATH="${2}"

  local GITHUB_EVENT_NAME="${3}"

  # Put an arbitrary JSON file in the repository to trigger some validation
  cp -v "${GITHUB_EVENT_FILE_PATH}" "${GIT_REPOSITORY_PATH}/"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: initial commit"

  if [[ -v COMMAND_TO_RUN ]]; then
    # shellcheck disable=SC2034
    RUN_LOCAL=false
    SUPER_LINTER_WORKSPACE="${GIT_REPOSITORY_PATH}"
    COMMAND_TO_RUN+=(-e GITHUB_WORKSPACE="/tmp/lint")
    COMMAND_TO_RUN+=(-e GITHUB_EVENT_NAME="${GITHUB_EVENT_NAME}")
    COMMAND_TO_RUN+=(-e GITHUB_EVENT_PATH="/tmp/lint/$(basename "${GITHUB_EVENT_FILE_PATH}")")
    COMMAND_TO_RUN+=(-e MULTI_STATUS=false)
    COMMAND_TO_RUN+=(-e VALIDATE_ALL_CODEBASE=false)
  fi
}

initialize_git_repository_and_test_args_merge_commit() {
  local GIT_REPOSITORY_PATH="${1}"
  local GITHUB_EVENT_FILE_PATH="${2}"
  local GITHUB_EVENT_NAME="${3}"

  initialize_git_repository_and_test_args "${GIT_REPOSITORY_PATH}" "${GITHUB_EVENT_FILE_PATH}" "${GITHUB_EVENT_NAME}"

  local NEW_BRANCH_NAME="branch-1"
  git -C "${GIT_REPOSITORY_PATH}" switch --create "${NEW_BRANCH_NAME}"
  cp -v "${GITHUB_EVENT_FILE_PATH}" "${GIT_REPOSITORY_PATH}/new-file-1.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 1"
  cp -v "${GITHUB_EVENT_FILE_PATH}" "${GIT_REPOSITORY_PATH}/new-file-2.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 2"
  cp -v "${GITHUB_EVENT_FILE_PATH}" "${GIT_REPOSITORY_PATH}/new-file-3.json"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add new file 3"
  git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"

  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
    debug "Simulate what happens in a GitHub pull request event"
    # shellcheck disable=SC2034
    GITHUB_PULL_REQUEST_HEAD_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse "${NEW_BRANCH_NAME}")"
    debug "Create a branch to merge the pull request"
    git -C "${GIT_REPOSITORY_PATH}" switch --create pull/6637/merge
  fi

  debug "Forcing the creation of a merge commit"
  git -C "${GIT_REPOSITORY_PATH}" merge \
    -m "Merge commit" \
    --no-ff \
    "${NEW_BRANCH_NAME}"

  if [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
    debug "Simulate what happens in a GitHub push event"
    git -C "${GIT_REPOSITORY_PATH}" branch -d "${NEW_BRANCH_NAME}"
  fi

  initialize_github_sha "${GIT_REPOSITORY_PATH}"

  git_log_graph "${GIT_REPOSITORY_PATH}"

  if [[ -v COMMAND_TO_RUN ]]; then
    COMMAND_TO_RUN+=(-e VALIDATE_JSON="true")
  fi
}

initialize_github_sha() {
  local GIT_REPOSITORY_PATH="${1}"
  local TEST_GITHUB_SHA
  TEST_GITHUB_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
  debug "Setting GITHUB_SHA to ${TEST_GITHUB_SHA}"

  # shellcheck disable=SC2034
  GITHUB_SHA="${TEST_GITHUB_SHA}"

  if [[ -v COMMAND_TO_RUN ]]; then
    COMMAND_TO_RUN+=(-e GITHUB_SHA="${TEST_GITHUB_SHA}")
  fi
}

git_log_graph() {
  local GIT_REPOSITORY_PATH="${1}"

  git -C "${GIT_REPOSITORY_PATH}" log \
    --abbrev-commit \
    --all \
    --decorate \
    --format=oneline \
    --graph
}
