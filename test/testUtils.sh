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

# shellcheck disable=SC2034
TEST_DATA_DIRECTORY="test/data/test-repository-contents"

# Use an arbitrary JSON file in case we want trigger some validation
# shellcheck disable=SC2034
TEST_DATA_JSON_FILE_GOOD="${TEST_DATA_DIRECTORY}/json_good_1.json"

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

  unset GITHUB_SHA
  unset GIT_ROOT_COMMIT_SHA
  unset GITHUB_BEFORE_SHA

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

initialize_git_repository_contents() {
  local GIT_REPOSITORY_PATH="${1}" && shift
  local COMMITS_TO_CREATE="${1}" && shift
  local CREATE_NEW_BRANCH="${1}" && shift
  local GITHUB_EVENT_NAME="${1}" && shift
  local FORCE_MERGE_COMMIT="${1}" && shift
  local SKIP_GITHUB_BEFORE_SHA_INIT="${1}" && shift

  local NEW_BRANCH_NAME="branch-1"

  debug "Creating the initial commit"
  local TEST_FILE_PATH
  TEST_FILE_PATH="${GIT_REPOSITORY_PATH}/test0.json"
  cp -v "${TEST_DATA_JSON_FILE_GOOD}" "${TEST_FILE_PATH}"
  git -C "${GIT_REPOSITORY_PATH}" add .
  git -C "${GIT_REPOSITORY_PATH}" commit -m "Add ${TEST_FILE_PATH}"

  # shellcheck disable=SC2034
  GIT_ROOT_COMMIT_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
  debug "GIT_ROOT_COMMIT_SHA: ${GIT_ROOT_COMMIT_SHA}"

  if [[ "${COMMITS_TO_CREATE}" -gt 0 ]]; then
    if [[ "${SKIP_GITHUB_BEFORE_SHA_INIT}" != "true" ]]; then
      GITHUB_BEFORE_SHA="${GIT_ROOT_COMMIT_SHA}"
      debug "GITHUB_BEFORE_SHA: ${GITHUB_BEFORE_SHA}"
    else
      debug "Skipping GITHUB_BEFORE_SHA initialization because SKIP_GITHUB_BEFORE_SHA_INIT is ${SKIP_GITHUB_BEFORE_SHA_INIT}"
    fi
  else
    debug "Skipping GITHUB_BEFORE_SHA because there are no more commits other than the root commit"
  fi

  if [[ "${CREATE_NEW_BRANCH}" == "true" ]]; then
    debug "Creating a new branch: ${NEW_BRANCH_NAME}"
    git -C "${GIT_REPOSITORY_PATH}" switch --create "${NEW_BRANCH_NAME}"
  fi

  debug "Creating ${COMMITS_TO_CREATE} commits"
  for ((i = 1; i <= COMMITS_TO_CREATE; i++)); do
    local TEST_FILE_PATH="${GIT_REPOSITORY_PATH}/test${i}.json"
    cp -v "${TEST_DATA_JSON_FILE_GOOD}" "${TEST_FILE_PATH}"
    git -C "${GIT_REPOSITORY_PATH}" add .
    git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add $(basename "${TEST_FILE_PATH}")"
  done

  debug "Simulating a GitHub ${GITHUB_EVENT_NAME:-"not set"} event"

  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]]; then
    debug "Switching to the ${DEFAULT_BRANCH} branch"
    git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"

    local PULL_REQUEST_BRANCH_NAME="pull/6637/merge"
    # shellcheck disable=SC2034
    GITHUB_PULL_REQUEST_HEAD_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse "${NEW_BRANCH_NAME}")"
    debug "Create a branch to merge the pull request"
    git -C "${GIT_REPOSITORY_PATH}" switch --create "${PULL_REQUEST_BRANCH_NAME}"

    if [[ "${FORCE_MERGE_COMMIT}" != "true" ]]; then
      fatal "A pull request always creates a merge commit. Set FORCE_MERGE_COMMIT to true"
    fi

    debug "Create a merge commit to merge the ${NEW_BRANCH_NAME} branch in the pull request branch (${PULL_REQUEST_BRANCH_NAME})"
    git -C "${GIT_REPOSITORY_PATH}" merge \
      -m "chore: merge commit ${GITHUB_EVENT_NAME}" \
      --no-ff \
      "${NEW_BRANCH_NAME}"
  elif [[ "${GITHUB_EVENT_NAME}" == "push" ]]; then
    if [[ "${CREATE_NEW_BRANCH}" == "true" ]]; then
      if [[ "${FORCE_MERGE_COMMIT}" == "true" ]]; then
        git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"
        debug "Forcing the creation of a merge commit"
        git -C "${GIT_REPOSITORY_PATH}" merge \
          -m "chore: merge commit ${GITHUB_EVENT_NAME}" \
          --no-ff \
          "${NEW_BRANCH_NAME}"

        debug "Deleting the ${NEW_BRANCH_NAME} branch"
        git -C "${GIT_REPOSITORY_PATH}" branch -d "${NEW_BRANCH_NAME}"
      else
        debug "Skipping the creation of a merge commit."
      fi
    else
      debug "Pushed directly to the default branch. No need to merge."
    fi
  else
    fatal "Handling GITHUB_EVENT_NAME (${GITHUB_EVENT_NAME:-"not set"}) not implemented"
  fi

  initialize_github_sha "${GIT_REPOSITORY_PATH}"

  git_log_graph "${GIT_REPOSITORY_PATH}"
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
