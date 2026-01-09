#!/usr/bin/env bash

function IssueHintForFullGitHistory() {
  info "Check that the local repository has the full history and that the repository is not shallow."
  if [[ "${RUN_LOCAL}" == "false" ]]; then
    info "Check that you set the 'fetch-depth: 0' option for the actions/checkout step in your GitHub Actions workflow."
  fi
  info "See https://github.com/super-linter/super-linter#get-started"
  info "Is shallow repository: $(git -C "${GITHUB_WORKSPACE}" rev-parse --is-shallow-repository)"
}
export -f IssueHintForFullGitHistory

function GenerateFileDiff() {
  if [[ ! -v GITHUB_BEFORE_SHA ]]; then
    error "GITHUB_BEFORE_SHA is not initialized."
    return 1
  fi

  if [[ ! -v GITHUB_SHA ]]; then
    error "GITHUB_SHA is not initialized."
    return 1
  fi

  debug "Getting the list of changed files considering GITHUB_BEFORE_SHA (${GITHUB_BEFORE_SHA}) and GITHUB_SHA (${GITHUB_SHA})"

  # Get the list of files that changed between "${GITHUB_BEFORE_SHA}"
  # "${GITHUB_SHA}" refs, and add ${GITHUB_WORKSPACE} as a prefix
  local LIST_OF_CHANGED_FILES
  if ! LIST_OF_CHANGED_FILES=$(
    set -o pipefail

    # Exclude deleted files (lowercase d in --diff-filter)
    # Ref: https://git-scm.com/docs/git-diff-tree#Documentation/git-diff-tree.txt---diff-filterACDMRTUXB
    git -C "${GITHUB_WORKSPACE}" diff-tree \
      --diff-filter=d \
      --no-commit-id \
      --name-only \
      -r \
      --root \
      "${GITHUB_BEFORE_SHA}" "${GITHUB_SHA}" | sed "s|^|${GITHUB_WORKSPACE}/|"
  ); then
    error "Failed to get a list of changed files. LIST_OF_CHANGED_FILES: ${LIST_OF_CHANGED_FILES}"
    IssueHintForFullGitHistory
    return 1
  fi

  RAW_FILE_ARRAY=()
  if [[ -n "${LIST_OF_CHANGED_FILES:-}" ]]; then
    # Load the list of files in the repository in the list of files to check
    mapfile -t RAW_FILE_ARRAY <<<"${LIST_OF_CHANGED_FILES}"
  fi
}

function BuildFileList() {
  debug "Building file list..."

  VALIDATE_ALL_CODEBASE="${1}"
  debug "VALIDATE_ALL_CODEBASE: ${VALIDATE_ALL_CODEBASE}"

  TEST_CASE_RUN="${2}"
  debug "TEST_CASE_RUN: ${TEST_CASE_RUN}"

  if [ "${VALIDATE_ALL_CODEBASE}" == "false" ] && [ "${TEST_CASE_RUN}" != "true" ]; then
    debug "Build the list of all changed files"

    if ! GenerateFileDiff; then
      fatal "Error while generating file diff"
    fi
  else
    if [ "${USE_FIND_ALGORITHM}" == 'true' ]; then
      debug "Populating the file list with all the files in the ${GITHUB_WORKSPACE} workspace using FIND algorithm"
      if ! mapfile -t RAW_FILE_ARRAY < <(find "${GITHUB_WORKSPACE}" \
        -not \( -path '*/\.git' -prune \) \
        -not \( -path '*/\.pytest_cache' -prune \) \
        -not \( -path '*/\.rbenv' -prune \) \
        -not \( -path '*/\.terragrunt-cache' -prune \) \
        -not \( -path '*/\.venv' -prune \) \
        -not \( -path '*/\__pycache__' -prune \) \
        -not \( -path '*/\node_modules' -prune \) \
        -not -name ".DS_Store" \
        -not -name "*.avif" \
        -not -name "*.gif" \
        -not -name "*.ico" \
        -not -name "*.jpg" \
        -not -name "*.jpeg" \
        -not -name "*.pdf" \
        -not -name "*.png" \
        -not -name "*.webp" \
        -not -name "*.woff" \
        -not -name "*.woff2" \
        -not -name "*.zip" \
        -type f \
        2>&1 | sort); then
        fatal "Failed to get a list of changed files. USE_FIND_ALGORITHM: ${USE_FIND_ALGORITHM}"
      fi

    else

      # Get the list of files in the codebase, and add ${GITHUB_WORKSPACE} as a
      # prefix
      local LIST_OF_FILES_IN_REPO
      if ! LIST_OF_FILES_IN_REPO=$(
        set -o pipefail
        git -C "${GITHUB_WORKSPACE}" ls-tree -r --name-only HEAD | sed "s|^|${GITHUB_WORKSPACE}/|"
      ); then
        fatal "Failed to get a list of changed files. LIST_OF_FILES_IN_REPO: ${LIST_OF_FILES_IN_REPO}"
      fi

      RAW_FILE_ARRAY=()
      if [[ -n "${LIST_OF_FILES_IN_REPO:-}" ]]; then
        # Load the list of files in the repository in the list of files to check
        mapfile -t RAW_FILE_ARRAY <<<"${LIST_OF_FILES_IN_REPO}"
      fi
    fi
  fi

  debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"

  if [ ${#RAW_FILE_ARRAY[@]} -eq 0 ]; then
    warn "No files were found in the GITHUB_WORKSPACE:[${GITHUB_WORKSPACE}] to lint!"
  else
    debug "RAW_FILE_ARRAY contains ${#RAW_FILE_ARRAY[@]} items: ${RAW_FILE_ARRAY[*]}"
  fi

  ####################################################
  # Configure linters that scan the entire workspace #
  ####################################################
  debug "Checking if we are in test mode before configuring the list of directories to lint. TEST_CASE_RUN: ${TEST_CASE_RUN}"
  if [ "${TEST_CASE_RUN}" == "true" ]; then
    debug "We are running in test mode."

    debug "Adding test case directories to the list of directories to analyze with BIOME_FORMAT."
    DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/biome_format"
    # We need this for parallel
    export DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY
    debug "DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY: ${DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with BIOME_LINT."
    DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/biome_lint"
    # We need this for parallel
    export DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY
    debug "DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY: ${DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with JSCPD."
    DEFAULT_JSCPD_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/jscpd"
    # We need this for parallel
    export DEFAULT_JSCPD_TEST_CASE_DIRECTORY
    debug "DEFAULT_JSCPD_TEST_CASE_DIRECTORY: ${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with Commitlint."
    DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/git_commitlint"
    # We need this for parallel
    export DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY
    debug "DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY: ${DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with Trivy."
    DEFAULT_TRIVY_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/trivy"
    # We need this for parallel
    export DEFAULT_TRIVY_TEST_CASE_DIRECTORY
    debug "DEFAULT_TRIVY_TEST_CASE_DIRECTORY: ${DEFAULT_TRIVY_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_TRIVY_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_TRIVY_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with pre-commit."
    DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/pre_commit"
    # We need this for parallel
    export DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY
    debug "DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY: ${DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY}"
    RAW_FILE_ARRAY+=("${DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY}/bad")
    RAW_FILE_ARRAY+=("${DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY}/good")
  fi

  debug "Add GITHUB_WORKSPACE (${GITHUB_WORKSPACE}) to the list of files to lint because we might need it for linters that lint the whole workspace"
  RAW_FILE_ARRAY+=("${GITHUB_WORKSPACE}")

  if [ -d "${ANSIBLE_DIRECTORY}" ]; then
    debug "Adding ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) to the list of files and directories to lint."
    RAW_FILE_ARRAY+=("${ANSIBLE_DIRECTORY}")
  else
    debug "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) does NOT exist."
  fi

  local PARALLEL_RESULTS_FILE_PATH
  PARALLEL_RESULTS_FILE_PATH="${SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH}/super-linter-parallel-results-build-file-list.json"
  debug "PARALLEL_RESULTS_FILE_PATH when building the file list: ${PARALLEL_RESULTS_FILE_PATH}"

  local -a PARALLEL_COMMAND
  PARALLEL_COMMAND=(parallel --will-cite --keep-order --max-procs "$(($(nproc) * 1))" --results "${PARALLEL_RESULTS_FILE_PATH}" --xargs)

  if [ "${LOG_DEBUG}" == "true" ]; then
    debug "LOG_DEBUG is enabled. Enable verbose output for parallel"
    PARALLEL_COMMAND+=(--verbose)
  fi

  # Max number of files to categorize per process
  PARALLEL_COMMAND+=(--max-lines 10)

  PARALLEL_COMMAND+=("BuildFileArrays")
  debug "PARALLEL_COMMAND to build the list of files and directories to lint: ${PARALLEL_COMMAND[*]}"

  FILE_ARRAYS_DIRECTORY_PATH="${SUPER_LINTER_PRIVATE_OUTPUT_DIRECTORY_PATH}/super-linter-file-arrays"
  mkdir -p "${FILE_ARRAYS_DIRECTORY_PATH}"
  export FILE_ARRAYS_DIRECTORY_PATH
  debug "Created FILE_ARRAYS_DIRECTORY_PATH: ${FILE_ARRAYS_DIRECTORY_PATH}"

  info "Building the list of files and directories to check"

  PARALLEL_COMMAND_OUTPUT=$(printf "%s\n" "${RAW_FILE_ARRAY[@]}" | "${PARALLEL_COMMAND[@]}" 2>&1)
  PARALLEL_COMMAND_RETURN_CODE=$?
  debug "PARALLEL_COMMAND_OUTPUT to build the file list (exit code: ${PARALLEL_COMMAND_RETURN_CODE}):\n${PARALLEL_COMMAND_OUTPUT}"
  debug "Parallel output file (${PARALLEL_RESULTS_FILE_PATH}) contents when building the file list:\n$(cat "${PARALLEL_RESULTS_FILE_PATH}")"

  local RESULTS_OBJECT
  RESULTS_OBJECT=
  if ! RESULTS_OBJECT=$(jq --raw-output -n '[inputs]' "${PARALLEL_RESULTS_FILE_PATH}"); then
    fatal "Error loading results when building the file list: ${RESULTS_OBJECT}"
  fi
  debug "RESULTS_OBJECT when building the file list:\n${RESULTS_OBJECT}"

  local STDOUT_BUILD_FILE_LIST
  # Get raw output so we can strip quotes from the data we load
  if ! STDOUT_BUILD_FILE_LIST="$(jq --raw-output '.[] | select(.Stdout[:-1] | length > 0) | .Stdout[:-1]' <<<"${RESULTS_OBJECT}")"; then
    fatal "Error when loading stdout when building the file list: ${STDOUT_BUILD_FILE_LIST}"
  fi

  if [ -n "${STDOUT_BUILD_FILE_LIST}" ]; then
    info "Command output when building the file list:\n------\n${STDOUT_BUILD_FILE_LIST}\n------"
  else
    debug "Stdout when building the file list is empty"
  fi

  local STDERR_BUILD_FILE_LIST
  if ! STDERR_BUILD_FILE_LIST="$(jq --raw-output '.[] | select(.Stderr[:-1] | length > 0) | .Stderr[:-1]' <<<"${RESULTS_OBJECT}")"; then
    fatal "Error when loading stderr when building the file list:\n${STDERR_BUILD_FILE_LIST}"
  fi

  if [ -n "${STDERR_BUILD_FILE_LIST}" ]; then
    info "Stderr when building the file list:\n------\n${STDERR_BUILD_FILE_LIST}\n------"
  else
    debug "Stderr when building the file list is empty"
  fi

  if [[ ${PARALLEL_COMMAND_RETURN_CODE} -ne 0 ]]; then
    fatal "Error when building the list of files and directories to lint."
  fi

  ################
  # Footer print #
  ################
  info "Successfully gathered list of files..."
}

AddToPythonFileArrays() {
  local FILE="${1}"

  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_BLACK"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_FLAKE8"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_ISORT"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_PYLINT"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_MYPY"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF_FORMAT"
}

AddToShellFileArrays() {
  local FILE="${1}"

  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BASH_EXEC"
  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SHELL_SHFMT"
}

AddToPerlFileArrays() {
  local FILE="${1}"

  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PERL"
}

AddToRubyFileArrays() {
  local FILE="${1}"

  echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUBY"
}

CheckFileType() {
  local FILE
  FILE="$1"

  local GET_FILE_TYPE_CMD
  if ! GET_FILE_TYPE_CMD="$(file --brief "${FILE}" 2>&1)"; then
    error "Error while checking file type: ${GET_FILE_TYPE_CMD}"
    return 1
  fi
  debug "Detected file type for ${FILE}: ${GET_FILE_TYPE_CMD}"

  local FILE_TYPE_MESSAGE

  case "${GET_FILE_TYPE_CMD}" in
  *"Python script"*)
    FILE_TYPE_MESSAGE="Found Python script without extension: ${FILE}"
    AddToPythonFileArrays "${FILE}"
    ;;
  *"Perl script"*)
    FILE_TYPE_MESSAGE="Found Perl script without extension: ${FILE}"
    AddToPerlFileArrays "${FILE}"
    ;;
  *"Ruby script"*)
    FILE_TYPE_MESSAGE="Found Ruby file without extension: ${FILE}"
    AddToRubyFileArrays "${FILE}"
    ;;
  *"POSIX shell script"* | *"Bourne-Again shell script"* | *"Dash shell script"* | *"Korn shell script"* | *"sh script"*)
    FILE_TYPE_MESSAGE="Found a Shell script without extension: ${FILE}"
    AddToShellFileArrays "${FILE}"
    ;;
  *)
    FILE_TYPE_MESSAGE="Failed to get file type for: ${FILE}. Output: ${GET_FILE_TYPE_CMD}"
    return 1
    ;;
  esac

  if [ "${SUPPRESS_FILE_TYPE_WARN}" == "false" ]; then
    warn "${FILE_TYPE_MESSAGE}"
  else
    debug "${FILE_TYPE_MESSAGE}"
  fi
}

BuildFileArrays() {
  local -a RAW_FILE_ARRAY
  RAW_FILE_ARRAY=("$@")

  debug "Categorizing the following files: ${RAW_FILE_ARRAY[*]}"

  RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY=()
  if [[ -n "${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES:-}" ]]; then
    # See https://docs.renovatebot.com/config-presets/
    IFS="," read -r -a RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY <<<"${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES}"
    debug "Initialized RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY with: ${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY[*]}"
  fi

  for FILE in "${RAW_FILE_ARRAY[@]}"; do
    if [[ -z "${FILE:-""}" ]]; then
      error "FILE is empty."
      return 1
    fi

    # Get the file extension
    FILE_TYPE="$(GetFileExtension "$FILE")"
    # We want a lowercase value
    local -l BASE_FILE
    # Get the name of the file and the containing directory path
    BASE_FILE=$(basename "${FILE}")
    FILE_DIR_NAME="$(dirname "${FILE}")"

    debug "FILE: ${FILE}, FILE_TYPE: ${FILE_TYPE}, BASE_FILE: ${BASE_FILE}, FILE_DIR_NAME: ${FILE_DIR_NAME}"

    if [ ! -e "${FILE}" ]; then
      # File not found in workspace
      warn "${FILE} exists in commit data, but not found on file system, skipping..."
      continue
    fi

    # Handle the corner cases of linters that are expected to lint the whole codebase,
    # but we don't have a variable to explicitly set the directory
    # to lint.
    if [[ "${FILE}" == "${GITHUB_WORKSPACE}" ]]; then
      debug "${FILE} matches with ${GITHUB_WORKSPACE}. Adding it to the list of directories to lint for linters that are expected to lint the whole codebase"

      if CheckovConfigurationFileContainsDirectoryOption "${CHECKOV_LINTER_RULES}"; then
        debug "No need to configure the directories to check for Checkov because its configuration file contains the list of directories to analyze."
        debug "Add the Checkov configuration file path to the list of items to check to consume as output later."
        echo "${CHECKOV_LINTER_RULES}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CHECKOV"
      else
        debug "Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with Checkov."
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CHECKOV"
      fi

      # Test cases for these languages are handled below because we first need to exclude non-relevant test cases
      if [[ "${TEST_CASE_RUN}" == "false" ]]; then
        debug "Add ${FILE} to the list of items to lint with BIOME_FORMAT"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BIOME_FORMAT"

        debug "Add ${FILE} to the list of items to lint with BIOME_LINT"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BIOME_LINT"

        debug "Add ${FILE} to the list of items to lint with Commitlint"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GIT_COMMITLINT"

        debug "Add ${FILE} to the list of items to lint with JSCPD"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSCPD"

        debug "Add ${FILE} to the list of items to lint with pre-commit"
        echo "${GITHUB_WORKSPACE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PRE_COMMIT"

        debug "Add ${FILE} to the list of items to lint with Trivy"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TRIVY"
      fi

      # Handle the corner case where FILE=${GITHUB_WORKSPACE}, and the user set
      # ANSIBLE_DIRECTORY=. or ANSIBLE_DIRECTORY=/
      if IsAnsibleDirectory "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ANSIBLE"
      fi

      debug "No need to further process ${FILE}"
      continue
    fi

    local FILE_PATH_FOR_REGEXES="${FILE}"

    if [[ "${STRIP_DEFAULT_WORKSPACE_FOR_REGEX}" == "true" ]]; then
      # Remove the workspace from the path to to match against regular expressions
      # that look for the beginning of the string. Example: ^file\.ext$
      FILE_PATH_FOR_REGEXES="${FILE#"${GITHUB_WORKSPACE}/"}"
      debug "Stripping the default workspace from FILE_PATH_FOR_REGEXES: ${FILE_PATH_FOR_REGEXES}"
    fi

    ###############################################
    # Filter files if FILTER_REGEX_INCLUDE is set #
    ###############################################
    if [[ -n "$FILTER_REGEX_INCLUDE" ]] && [[ ! (${FILE_PATH_FOR_REGEXES} =~ $FILTER_REGEX_INCLUDE) ]]; then
      debug "FILTER_REGEX_INCLUDE didn't match. Skipping ${FILE}"
      continue
    fi

    ###############################################
    # Filter files if FILTER_REGEX_EXCLUDE is set #
    ###############################################
    if [[ -n "$FILTER_REGEX_EXCLUDE" ]] && [[ ${FILE_PATH_FOR_REGEXES} =~ $FILTER_REGEX_EXCLUDE ]]; then
      debug "FILTER_REGEX_EXCLUDE match. Skipping ${FILE}"
      continue
    fi

    ###################################################
    # Filter files if FILTER_REGEX_EXCLUDE is not set #
    ###################################################
    if [ "${IGNORE_GITIGNORED_FILES}" == "true" ] && git -C "${GITHUB_WORKSPACE}" check-ignore "$FILE"; then
      debug "${FILE} is ignored by Git. Skipping ${FILE}"
      continue
    fi

    #########################################
    # Filter files with at-generated marker #
    #########################################
    if [ "${IGNORE_GENERATED_FILES}" == "true" ] && IsGenerated "$FILE"; then
      debug "${FILE} is generated. Skipping ${FILE}"
      continue
    fi

    # These linters check every file
    local EDITORCONFIG_FILE_PATH
    EDITORCONFIG_FILE_PATH="${GITHUB_WORKSPACE}/.editorconfig"
    if [ -e "${EDITORCONFIG_FILE_PATH}" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-EDITORCONFIG"
    else
      debug "Don't include ${FILE} in the list of files to lint with editorconfig-checker because the workspace doesn't contain an EditorConfig file: ${EDITORCONFIG_FILE_PATH}"
    fi

    echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GIT_MERGE_CONFLICT_MARKERS"
    echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GITLEAKS"

    if IsAnsibleDirectory "${FILE}"; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ANSIBLE"
    fi

    # Check for Renovate files because they might be JSON5 files that we
    # also want to lint as JSON5 files.
    # See https://docs.renovatebot.com/configuration-options/
    if [[ "${BASE_FILE}" =~ renovate.json5? ]] ||
      [ "${BASE_FILE}" == ".renovaterc" ] ||
      [[ "${BASE_FILE}" =~ .renovaterc.json5? ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RENOVATE"
    fi
    # Handle test cases for tools that lint the entire workspace
    if [[ "${TEST_CASE_RUN}" == "true" ]] && [[ -d "${FILE}" ]]; then
      # Handle BIOME_FORMAT test cases
      if [[ "${FILE}" =~ .*${DEFAULT_BIOME_FORMAT_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for BIOME_FORMAT. Adding it to the list of items to lint with BIOME_FORMAT"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BIOME_FORMAT"
      # Handle BIOME_LINT test cases
      elif [[ "${FILE}" =~ .*${DEFAULT_BIOME_LINT_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for BIOME_LINT. Adding it to the list of items to lint with BIOME_LINT"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-BIOME_LINT"
      # Handle Commitlint test cases
      elif [[ "${FILE}" =~ .*${DEFAULT_GIT_COMMITLINT_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for Commitlint. Adding it to the list of items to lint with Commitlint"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GIT_COMMITLINT"
      # Handle JSCPD test cases
      elif [[ "${FILE}" =~ .*${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for JSCPD. Adding it to the list of items to lint with JSCPD"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSCPD"
      # Handle pre-commit test cases
      elif [[ "${FILE}" =~ .*${DEFAULT_PRE_COMMIT_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for pre-commit. Adding it to the list of items to lint with pre-commit"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PRE_COMMIT"
      # Handle Trivy test cases
      elif [[ "${FILE}" =~ .*${DEFAULT_TRIVY_TEST_CASE_DIRECTORY}.* ]]; then
        debug "${FILE} is a test case for Trivy. Adding it to the list of items to lint with Trivy"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TRIVY"
      fi
    fi

    # Select files by extension or file name

    if [ "${FILE_TYPE}" == "sh" ] ||
      [ "${FILE_TYPE}" == "bash" ] ||
      [ "${FILE_TYPE}" == "bats" ] ||
      [ "${FILE_TYPE}" == "dash" ] ||
      [ "${FILE_TYPE}" == "ksh" ]; then
      AddToShellFileArrays "${FILE}"
    elif [ "${FILE_TYPE}" == "clj" ] || [ "${FILE_TYPE}" == "cljs" ] ||
      [ "${FILE_TYPE}" == "cljc" ] || [ "${FILE_TYPE}" == "edn" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CLOJURE"
    elif [ "${FILE_TYPE}" == "cpp" ] || [ "${FILE_TYPE}" == "h" ] ||
      [ "${FILE_TYPE}" == "cc" ] || [ "${FILE_TYPE}" == "hpp" ] ||
      [ "${FILE_TYPE}" == "cxx" ] || [ "${FILE_TYPE}" == "cu" ] ||
      [ "${FILE_TYPE}" == "hxx" ] || [ "${FILE_TYPE}" == "c++" ] ||
      [ "${FILE_TYPE}" == "hh" ] || [ "${FILE_TYPE}" == "h++" ] ||
      [ "${FILE_TYPE}" == "cuh" ] || [ "${FILE_TYPE}" == "c" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CPP"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CLANG_FORMAT"
    elif [ "${FILE_TYPE}" == "coffee" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-COFFEESCRIPT"
    elif [ "${FILE_TYPE}" == "cs" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CSHARP"
    elif [ "${FILE_TYPE}" == "css" ] || [ "${FILE_TYPE}" == "scss" ] ||
      [ "${FILE_TYPE}" == "sass" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CSS"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CSS_PRETTIER"
      else
        debug "Skip adding ${FILE} to CSS_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "dart" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-DART"
    # Use BASE_FILE here because FILE_TYPE is not reliable when there is no file extension
    elif [[ "${FILE_TYPE}" != "tap" ]] && [[ "${FILE_TYPE}" != "yml" ]] &&
      [[ "${FILE_TYPE}" != "yaml" ]] && [[ "${FILE_TYPE}" != "json" ]] &&
      [[ "${FILE_TYPE}" != "xml" ]] &&
      [[ "${BASE_FILE}" =~ ^(.+\.)?(contain|dock)erfile$ ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-DOCKERFILE_HADOLINT"
    elif [ "${FILE_TYPE}" == "env" ] || [[ "${BASE_FILE}" == *".env."* ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ENV"
    elif [ "${FILE_TYPE}" == "go" ] ||
      [[ "${BASE_FILE}" == "go.mod" ]]; then

      # Check if we should lint a Go module
      local GO_MOD_FILE_PATH=""
      if [ "${BASE_FILE}" == "go.mod" ]; then
        GO_MOD_FILE_PATH="${FILE}"
        debug "${BASE_FILE} is a Go module file. Setting the go.mod file path to ${GO_MOD_FILE_PATH}"
      else
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GO"
        debug "${BASE_FILE} is a Go file. Trying to find out if it's part of a Go module"
        local dir_name
        dir_name="${FILE_DIR_NAME}"
        while [ "${dir_name}" != "$(dirname "${GITHUB_WORKSPACE}")" ] && [ "${dir_name}" != "/" ]; do
          local potential_go_mod_file_path="${dir_name}/go.mod"
          if [ -f "${potential_go_mod_file_path}" ]; then
            GO_MOD_FILE_PATH="${potential_go_mod_file_path}"
            break
          fi
          dir_name=$(dirname "${dir_name}")
        done
      fi

      if [[ -n "${GO_MOD_FILE_PATH:-}" ]]; then
        debug "Considering ${FILE_DIR_NAME} as a Go module because it contains ${GO_MOD_FILE_PATH}"
        local FILE_ARRAY_GO_MODULES_PATH="${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GO_MODULES"

        if [[ ! -e "${FILE_ARRAY_GO_MODULES_PATH}" ]] || ! grep -Fxq "${FILE_DIR_NAME}" "${FILE_ARRAY_GO_MODULES_PATH}"; then
          echo "${FILE_DIR_NAME}" >>"${FILE_ARRAY_GO_MODULES_PATH}"
          debug "Added ${GO_MOD_FILE_PATH} directory (${FILE_DIR_NAME}) to the list of Go modules to lint"
        else
          debug "Skip adding ${GO_MOD_FILE_PATH} directory (${FILE_DIR_NAME}) to the list of Go modules to lint because it's already in that list"
        fi
      else
        debug "${FILE} is not considered to be part of a Go module"
      fi
    # Use BASE_FILE here because FILE_TYPE is not reliable when there is no file extension
    elif [ "$FILE_TYPE" == "groovy" ] || [ "$FILE_TYPE" == "jenkinsfile" ] ||
      [ "$FILE_TYPE" == "gradle" ] || [ "$FILE_TYPE" == "nf" ] ||
      [[ "$BASE_FILE" =~ .*jenkinsfile.* ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GROOVY"
    elif [ "${FILE_TYPE}" == "html" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-HTML"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-HTML_PRETTIER"
      else
        debug "Skip adding ${FILE} to HTML_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "java" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JAVA"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GOOGLE_JAVA_FORMAT"
    elif [ "${FILE_TYPE}" == "js" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JAVASCRIPT_ES"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JAVASCRIPT_PRETTIER"
      else
        debug "Skip adding ${FILE} to JAVASCRIPT_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "$FILE_TYPE" == "jsonc" ] || [ "$FILE_TYPE" == "json5" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSONC"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSONC_PRETTIER"
      else
        debug "Skip adding ${FILE} to JSONC_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "json" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSON"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSON_PRETTIER"
      else
        debug "Skip adding ${FILE} to JSON_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
      if DetectOpenAPIFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-OPENAPI"
      fi

      if DetectARMFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-ARM"
      fi

      if DetectCloudFormationFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CLOUDFORMATION"
      fi

      if DetectAWSStatesFIle "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-STATES"
      fi
    elif [ "${FILE_TYPE}" == "jsx" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSX"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JSX_PRETTIER"
      else
        debug "Skip adding ${FILE} to JSX_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "ipynb" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_BLACK"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_FLAKE8"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_ISORT"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_MYPY"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_PYLINT"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-JUPYTER_NBQA_RUFF"
    elif [ "${FILE_TYPE}" == "kt" ] || [ "${FILE_TYPE}" == "kts" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-KOTLIN"
    elif [ "$FILE_TYPE" == "lua" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-LUA"
    elif [ "${FILE_TYPE}" == "tex" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-LATEX"
    elif [ "${FILE_TYPE}" == "md" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-MARKDOWN"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-MARKDOWN_PRETTIER"
      else
        debug "Skip adding ${FILE} to MARKDOWN_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-NATURAL_LANGUAGE"
    elif [ "${FILE_TYPE}" == "php" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_BUILTIN"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PHPCS"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PHPSTAN"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PHP_PSALM"
    elif [ "${FILE_TYPE}" == "pl" ] || [ "${FILE_TYPE}" == "pm" ] ||
      [ "${FILE_TYPE}" == "t" ]; then
      AddToPerlFileArrays "${FILE}"
    elif [ "${FILE_TYPE}" == "ps1" ] ||
      [ "${FILE_TYPE}" == "psm1" ] ||
      [ "${FILE_TYPE}" == "psd1" ] ||
      [ "${FILE_TYPE}" == "ps1xml" ] ||
      [ "${FILE_TYPE}" == "pssc" ] ||
      [ "${FILE_TYPE}" == "psrc" ] ||
      [ "${FILE_TYPE}" == "cdxml" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-POWERSHELL"
    elif [ "${FILE_TYPE}" == "proto" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PROTOBUF"
    elif [ "${FILE_TYPE}" == "py" ]; then
      AddToPythonFileArrays "${FILE}"
    elif [ "${FILE_TYPE}" == "r" ] || [ "${FILE_TYPE}" == "rmd" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-R"
    elif [ "${FILE_TYPE}" == "rb" ]; then
      AddToRubyFileArrays "${FILE}"
    elif [ "${FILE_TYPE}" == "rs" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUST_2015"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUST_2018"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUST_2021"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUST_2024"
    elif [ "${BASE_FILE}" == "cargo.toml" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RUST_CLIPPY"
    elif [ "${FILE_TYPE}" == "scala" ] || [ "${FILE_TYPE}" == "sc" ] || [ "${BASE_FILE}" == "??????" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SCALAFMT"
    elif [ "${FILE_TYPE}" == "smk" ] || [ "${BASE_FILE}" == "snakefile" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SNAKEMAKE_LINT"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SNAKEMAKE_SNAKEFMT"
    elif [ "${FILE_TYPE}" == "sql" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-SQLFLUFF"
    elif [ "${FILE_TYPE}" == "tf" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TERRAFORM_TFLINT"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TERRAFORM_FMT"
    elif [ "${FILE_TYPE}" == "hcl" ] &&
      [[ ${FILE} != *".tflint.hcl"* ]] &&
      [[ ${FILE} != *".pkr.hcl"* ]] &&
      [[ ${FILE} != *"docker-bake.hcl"* ]] &&
      [[ ${FILE} != *"docker-bake.override.hcl"* ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TERRAGRUNT"
    elif [ "${FILE_TYPE}" == "ts" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TYPESCRIPT_ES"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TYPESCRIPT_PRETTIER"
      else
        debug "Skip adding ${FILE} to TYPESCRIPT_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "tsx" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TSX"
    elif [ "${FILE_TYPE}" == "txt" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-TXT"
    elif [ "${FILE_TYPE}" == "xml" ] ||
      [ "${FILE_TYPE}" == "xsd" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-XML"
    elif [[ "${FILE}" =~ .?goreleaser.+ya?ml ]]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GO_RELEASER"
    elif [ "${FILE_TYPE}" == "graphql" ]; then
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GRAPHQL_PRETTIER"
      else
        debug "Skip adding ${FILE} to GRAPHQL_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "vue" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-VUE"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-VUE_PRETTIER"
      else
        debug "Skip adding ${FILE} to VUE_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
    elif [ "${FILE_TYPE}" == "sln" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-DOTNET_SLN_FORMAT_ANALYZERS"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-DOTNET_SLN_FORMAT_STYLE"
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-DOTNET_SLN_FORMAT_WHITESPACE"
    elif [ "${FILE_TYPE}" == "yml" ] || [ "${FILE_TYPE}" == "yaml" ]; then
      echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-YAML"
      if IsNotSymbolicLink "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-YAML_PRETTIER"
      else
        debug "Skip adding ${FILE} to YAML_PRETTIER file array because Prettier doesn't support following symbolic links"
      fi
      if DetectGitHubActionsWorkflows "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GITHUB_ACTIONS"
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GITHUB_ACTIONS_ZIZMOR"
      fi

      if DetectDependabot "${FILE}" ||
        DetectGitHubActions "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-GITHUB_ACTIONS_ZIZMOR"
      fi

      if DetectCloudFormationFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CLOUDFORMATION"
      fi

      if DetectOpenAPIFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-OPENAPI"
      fi

      if DetectKubernetesFile "${FILE}"; then
        echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-KUBERNETES_KUBECONFORM"
      fi
    else
      # Fallback option: look at the file contents
      if ! CheckFileType "${FILE}"; then
        debug "Failed to get file type for ${FILE}"
      fi
    fi

    # Handle the special case of Renovate shareable config presets
    # Ref: https://docs.renovatebot.com/config-presets/
    if [[ "$FILE_TYPE" == "json" ]] ||
      [[ "$FILE_TYPE" == "json5" ]] ||
      [[ "$FILE_TYPE" == "jsonc" ]]; then
      for file_name in "${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY[@]}"; do
        if [ "${BASE_FILE}" == "${file_name}" ]; then
          echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-RENOVATE"
          break
        fi
      done
    fi
  done
}

# We need so subprocesses (such as GNU Parallel) have access to these functions
export -f AddToPythonFileArrays
export -f AddToShellFileArrays
export -f AddToPerlFileArrays
export -f AddToRubyFileArrays
export -f BuildFileArrays
export -f CheckFileType
