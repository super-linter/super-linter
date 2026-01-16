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
source "lib/globals/main.sh"
# shellcheck source=/dev/null
source "lib/globals/languages.sh"
# shellcheck source=/dev/null
source "lib/globals/validation.sh"

# Because we need variables defined there
# shellcheck source=/dev/null
source "lib/functions/output.sh"

# shellcheck disable=SC2034
TEST_DATA_DIRECTORY="test/data/test-repository-contents"

# Use arbitrary JSON files in case we want trigger some validation
# shellcheck disable=SC2034
TEST_DATA_JSON_FILE_BAD="${TEST_DATA_DIRECTORY}/json_bad_1.json"
# shellcheck disable=SC2034
TEST_DATA_JSON_FILE_GOOD="${TEST_DATA_DIRECTORY}/json_good_1.json"

# shellcheck disable=SC2034
TEST_OS_PACKAGES_TO_INSTALL_FILE_PATH="test/data/install-dependencies/os-packages.json"

# shellcheck disable=SC2034
TEST_ROOT_CA_CERT_FILE_PATH="test/data/ssl-certificate/rootCA-test.crt"

# Set an arbitrary pull request name
PULL_REQUEST_BRANCH_NAME="pull/6637/merge"

# Set an arbitrary new branch name
NEW_BRANCH_NAME="branch-1"

# shellcheck disable=SC2034
LANGUAGES_WITH_FIX_MODE=(
  "ANSIBLE"
  "BIOME_FORMAT"
  "BIOME_LINT"
  "CLANG_FORMAT"
  "CSHARP"
  "CSS"
  "CSS_PRETTIER"
  "DOTNET_SLN_FORMAT_ANALYZERS"
  "DOTNET_SLN_FORMAT_STYLE"
  "DOTNET_SLN_FORMAT_WHITESPACE"
  "ENV"
  "GITHUB_ACTIONS_ZIZMOR"
  "GO_MODULES"
  "GO"
  "GOOGLE_JAVA_FORMAT"
  "GROOVY"
  "GRAPHQL_PRETTIER"
  "HTML_PRETTIER"
  "JAVASCRIPT_ES"
  "JAVASCRIPT_PRETTIER"
  "JSON"
  "JSON_PRETTIER"
  "JSONC"
  "JSONC_PRETTIER"
  "JSX"
  "JSX_PRETTIER"
  "JUPYTER_NBQA_BLACK"
  "JUPYTER_NBQA_ISORT"
  "JUPYTER_NBQA_RUFF"
  "KOTLIN"
  "MARKDOWN"
  "MARKDOWN_PRETTIER"
  "NATURAL_LANGUAGE"
  "POWERSHELL"
  "PROTOBUF"
  "PYTHON_BLACK"
  "PYTHON_ISORT"
  "PYTHON_RUFF"
  "PYTHON_RUFF_FORMAT"
  "RUBY"
  "RUST_2015"
  "RUST_2018"
  "RUST_2021"
  "RUST_2024"
  "RUST_CLIPPY"
  "SCALAFMT"
  "SHELL_SHFMT"
  "SNAKEMAKE_SNAKEFMT"
  "SPELL_CODESPELL"
  "SQLFLUFF"
  "TERRAFORM_FMT"
  "TSX"
  "TYPESCRIPT_ES"
  "TYPESCRIPT_PRETTIER"
  "VUE"
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
  "RUST_2024"
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

AssertSuperLinterSummaryMatches() {
  local ACTUAL_SUMMARY_FILE_PATH="${1}" && shift
  local EXPECTED_SUMMARY_FILE_PATH="${1}" && shift
  local EXIT_CODE="${1}" && shift

  # 1. Verify that the actual summary starts with the content of the expected summary
  # We ignore comments because Prettier might add blank lines or other minor differences
  # that we handle in AssertFileContentsMatchIgnoreHtmlComments usually, but here we need prefix matching.
  # However, for simplicity and robustness given the user requirement "starts with the exact content",
  # let's try to match the expected content against the head of the actual content.

  local EXPECTED_CONTENT_WITHOUT_COMMENTS
  EXPECTED_CONTENT_WITHOUT_COMMENTS="$(grep -vE '^\s*<!--' "${EXPECTED_SUMMARY_FILE_PATH}" | cat -s)"

  # calculating the number of lines in EXPECTED_CONTENT_WITHOUT_COMMENTS to grab the same amount from ACTUAL
  local EXPECTED_LINE_COUNT
  EXPECTED_LINE_COUNT="$(echo "${EXPECTED_CONTENT_WITHOUT_COMMENTS}" | wc -l)"

  # Get the first EXPECTED_LINE_COUNT lines from ACTUAL_SUMMARY_FILE_PATH (ignoring comments)
  local ACTUAL_CONTENT_WITHOUT_COMMENTS
  ACTUAL_CONTENT_WITHOUT_COMMENTS="$(grep -vE '^\s*<!--' "${ACTUAL_SUMMARY_FILE_PATH}" | cat -s)"
  local ACTUAL_HEAD
  ACTUAL_HEAD="$(echo "${ACTUAL_CONTENT_WITHOUT_COMMENTS}" | head -n "${EXPECTED_LINE_COUNT}")"

  if [[ "${ACTUAL_HEAD}" != "${EXPECTED_CONTENT_WITHOUT_COMMENTS}" ]]; then
    error "The actual summary file (${ACTUAL_SUMMARY_FILE_PATH}) does not start with the expected content (${EXPECTED_SUMMARY_FILE_PATH})."
    error "Actual head:\n${ACTUAL_HEAD}"
    error "Expected content:\n${EXPECTED_CONTENT_WITHOUT_COMMENTS}"
    return 1
  else
    debug "The actual summary file starts with the expected content."
  fi

  # 2. Extract failed linters from the EXPECTED summary table
  # Look for lines containing "Fail ❌"
  local -a FAILED_LINTERS
  FAILED_LINTERS=()
  readarray -t FAILED_LINTERS < <(grep "Fail ❌" "${EXPECTED_SUMMARY_FILE_PATH}" | awk -F '|' '{print $2}' | xargs -r -n 1)

  if [[ "${#FAILED_LINTERS[@]}" -eq 0 ]] && [[ "${EXIT_CODE}" -ne 0 ]]; then
    error "The number of failed linters cannot be (${#FAILED_LINTERS[@]}) when the Super-linter exit code is ${EXIT_CODE}."
    return 1
  fi

  # 3. Verify that for each failed linter, there is a collapsible section in the ACTUAL summary
  for LINTER in "${FAILED_LINTERS[@]}"; do
    debug "Checking for collapsible section for ${LINTER}..."
    local EXPECTED_SECTION_HEADER="<summary>${LINTER}</summary>"
    if ! grep -Fq "${EXPECTED_SECTION_HEADER}" "${ACTUAL_SUMMARY_FILE_PATH}"; then
      error "Missing collapsible section for failed linter ${LINTER} in ${ACTUAL_SUMMARY_FILE_PATH}"
      return 1
    else
      debug "Found collapsible section for ${LINTER}"
    fi
  done
}

AssertFileContains() {
  local FILE_PATH="${1}" && shift
  local STRING_TO_SEARCH="${1}" && shift
  if ! grep -qxF "${STRING_TO_SEARCH}" "${FILE_PATH}"; then
    debug "${FILE_PATH} doesn't contain ${STRING_TO_SEARCH}"
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
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${TEST_CASE_FOLDER}/rust_clippy/bad/target")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${TEST_CASE_FOLDER}/rust_clippy/bad/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${TEST_CASE_FOLDER}/rust_clippy/good/target")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/${TEST_CASE_FOLDER}/rust_clippy/good/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("${SUPER_LINTER_WORKSPACE}/dependencies/composer/vendor")
  # Delete leftovers in pwd in case the workspace is not pwd
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${TEST_CASE_FOLDER}/rust_clippy/bad/target")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${TEST_CASE_FOLDER}/rust_clippy/bad/Cargo.lock")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${TEST_CASE_FOLDER}/rust_clippy/good/target")
  LEFTOVERS_TO_CLEAN+=("$(pwd)/${TEST_CASE_FOLDER}/rust_clippy/good/Cargo.lock")
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

  initialize_temp_directory_cleanup_traps "${GIT_REPOSITORY_PATH}"

  if [[ ! -d "${GIT_REPOSITORY_PATH}" ]]; then
    mkdir --parents "${GIT_REPOSITORY_PATH}"
  fi

  debug "GIT_REPOSITORY_PATH: ${GIT_REPOSITORY_PATH}. DEFAULT_BRANCH: ${DEFAULT_BRANCH}"

  git -C "${GIT_REPOSITORY_PATH}" init --initial-branch="${DEFAULT_BRANCH:-"main"}"
  git -C "${GIT_REPOSITORY_PATH}" config user.name "Super-linter Test"
  git -C "${GIT_REPOSITORY_PATH}" config user.email "super-linter-test@example.com"
}

initialize_temp_directory_cleanup_traps() {
  local TEMP_DIRECTORY_PATH="${1}"

  debug "Initializing temp directory cleanup traps for ${TEMP_DIRECTORY_PATH}"

  # Assuming that if sudo is available we aren't running inside a container,
  # so we don't want to leave leftovers around.
  if command -v sudo; then
    if [[ "${KEEP_TEMP_FILES:-}" == "true" ]]; then
      # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
      trap "echo Temp git repository available at: '${TEMP_DIRECTORY_PATH}'" EXIT
    else
      # shellcheck disable=SC2064 # Once the path is set, we don't expect it to change
      trap "echo 'Deleting ${TEMP_DIRECTORY_PATH}. Set KEEP_TEMP_FILES=true to keep temporary files'; sudo rm -fr '${TEMP_DIRECTORY_PATH}'" EXIT
    fi
  fi
}

initialize_git_repository_contents() {
  local GIT_REPOSITORY_PATH="${1}" && shift
  local COMMITS_TO_CREATE="${1}" && shift
  local CREATE_NEW_BRANCH="${1}" && shift
  local GITHUB_EVENT_NAME="${1}" && shift
  local FORCE_MERGE_COMMIT="${1}" && shift
  local SKIP_GITHUB_BEFORE_SHA_INIT="${1}" && shift
  local COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE="${1}" && shift
  local INITIALIZE_GITHUB_SHA="${1}" && shift
  local ADD_COMMIT_ON_DEFAULT_BRANCH_AFTER_MERGING_PR="${1}" && shift

  unset GIT_ROOT_COMMIT_SHA
  unset GITHUB_BEFORE_SHA
  unset FIRST_COMMIT_HASH
  unset GITHUB_PULL_REQUEST_HEAD_SHA
  unset GITHUB_SHA

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
    GITHUB_BEFORE_SHA="${GIT_EMPTY_TREE_HASH}"
    debug "Setting GITHUB_BEFORE_SHA to the empty tree commit hash (${GIT_EMPTY_TREE_HASH}) because there cannot be commits before the initial commit"

    FIRST_COMMIT_HASH="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
    debug "Setting FIRST_COMMIT_HASH to ${FIRST_COMMIT_HASH}"
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

    if [[ "${i}" -eq 1 ]]; then
      # shellcheck disable=SC2034
      FIRST_COMMIT_HASH="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse HEAD)"
      debug "Setting FIRST_COMMIT_HASH to ${FIRST_COMMIT_HASH}"
    fi
  done

  debug "Simulating a GitHub ${GITHUB_EVENT_NAME:-"not set"} event"

  if [[ "${GITHUB_EVENT_NAME}" == "pull_request" ]] ||
    [[ "${GITHUB_EVENT_NAME}" == "pull_request_target" ]] ||
    [[ "${GITHUB_EVENT_NAME}" == "workflow_dispatch" ]]; then
    debug "Switching to the ${DEFAULT_BRANCH} branch"
    git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"

    if [[ "${COMMIT_BAD_FILE_ON_DEFAULT_BRANCH_AND_MERGE}" == "true" ]]; then
      # Commit a bad file in the default branch to ensure that the file diff mechanism
      # doesn't pick it up
      debug "Commit a bad file in the default branch (${DEFAULT_BRANCH})"
      TEST_FILE_PATH="${GIT_REPOSITORY_PATH}/test-bad0.json"
      cp -v "${TEST_DATA_JSON_FILE_BAD}" "${TEST_FILE_PATH}"
      git -C "${GIT_REPOSITORY_PATH}" add .
      git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add $(basename "${TEST_FILE_PATH}")"

      debug "Switching to ${NEW_BRANCH_NAME}"
      git -C "${GIT_REPOSITORY_PATH}" switch "${NEW_BRANCH_NAME}"

      debug "Create a merge commit to merge the ${DEFAULT_BRANCH} branch in the ${NEW_BRANCH_NAME} branch"
      git -C "${GIT_REPOSITORY_PATH}" merge \
        -m "chore: merge commit ${GITHUB_EVENT_NAME} bad files" \
        --no-ff \
        "${DEFAULT_BRANCH}"

      debug "Switching to the ${DEFAULT_BRANCH} branch"
      git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"
    fi

    # shellcheck disable=SC2034
    GITHUB_PULL_REQUEST_HEAD_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse "${NEW_BRANCH_NAME}")"

    debug "Print Git log graph before adding the pull request merge commit"
    git_log_graph "${GIT_REPOSITORY_PATH}"

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

    if [[ "${ADD_COMMIT_ON_DEFAULT_BRANCH_AFTER_MERGING_PR}" == "true" ]]; then
      debug "Adding another commit on the default branch after creating the pull request merge commit"
      git -C "${GIT_REPOSITORY_PATH}" switch "${DEFAULT_BRANCH}"
      TEST_FILE_PATH="${GIT_REPOSITORY_PATH}/test-additional-file-default-branch.json"
      cp -v "${TEST_DATA_JSON_FILE_GOOD}" "${TEST_FILE_PATH}"
      git -C "${GIT_REPOSITORY_PATH}" add .
      git -C "${GIT_REPOSITORY_PATH}" commit -m "feat: add $(basename "${TEST_FILE_PATH}")"
      git -C "${GIT_REPOSITORY_PATH}" switch "${PULL_REQUEST_BRANCH_NAME}"
    fi

  elif [[ "${GITHUB_EVENT_NAME}" == "push" ]] ||
    [[ "${GITHUB_EVENT_NAME}" == "merge_group" ]] ||
    [[ "${GITHUB_EVENT_NAME}" == "repository_dispatch" ]] ||
    [[ "${GITHUB_EVENT_NAME}" == "schedule" ]]; then
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
    fatal "Handling GITHUB_EVENT_NAME (${GITHUB_EVENT_NAME:-"not set"}) not implemented when initializing Git repository contents"
  fi

  if [[ "${INITIALIZE_GITHUB_SHA:-}" == "true" ]]; then
    debug "Initializing GITHUB_SHA"
    if [[ "${GITHUB_EVENT_NAME}" == "pull_request_target" ]] ||
      [[ "${GITHUB_EVENT_NAME}" == "schedule" ]]; then
      # Ref: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#pull_request_target
      # Ref: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule
      GITHUB_SHA="$(git -C "${GIT_REPOSITORY_PATH}" rev-parse "${DEFAULT_BRANCH}")"
    else
      initialize_github_sha "${GIT_REPOSITORY_PATH}"
    fi
  fi

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

  git --no-pager -C "${GIT_REPOSITORY_PATH}" log \
    --abbrev-commit \
    --all \
    --decorate \
    --format=oneline \
    --graph
}
