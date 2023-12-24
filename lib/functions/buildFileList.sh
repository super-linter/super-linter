#!/usr/bin/env bash

function IssueHintForFullGitHistory() {
  info "Check that you have the full git history, the checkout is not shallow, etc"
  info "Is shallow repository: $(git -C "${GITHUB_WORKSPACE}" rev-parse --is-shallow-repository)"
  info "See https://github.com/super-linter/super-linter#example-connecting-github-action-workflow"
}

function GenerateFileDiff() {
  DIFF_GIT_DEFAULT_BRANCH_CMD="git -C \"${GITHUB_WORKSPACE}\" diff --diff-filter=d --name-only ${DEFAULT_BRANCH}...${GITHUB_SHA} | xargs -I % sh -c 'echo \"${GITHUB_WORKSPACE}/%\"' 2>&1"
  DIFF_TREE_CMD="git -C \"${GITHUB_WORKSPACE}\" diff-tree --no-commit-id --name-only -r ${GITHUB_SHA} ${GITHUB_BEFORE_SHA} | xargs -I % sh -c 'echo \"${GITHUB_WORKSPACE}/%\"' 2>&1"

  if [ "${GITHUB_EVENT_NAME:-}" == "push" ]; then
    RunFileDiffCommand "${DIFF_TREE_CMD}"
    if [ ${#RAW_FILE_ARRAY[@]} -eq 0 ]; then
      debug "----------------------------------------------"
      debug "Generating the file array with diff-tree produced [0] items, trying with git diff against the default branch..."
      RunFileDiffCommand "${DIFF_GIT_DEFAULT_BRANCH_CMD}"
    fi
  else
    RunFileDiffCommand "${DIFF_GIT_DEFAULT_BRANCH_CMD}"
  fi
}

function RunFileDiffCommand() {
  CMD="${1}"
  debug "Generating Diff with:[$CMD]"

  #################################################
  # Get the Array of files changed in the commits #
  #################################################
  CMD_OUTPUT=$(eval "set -eo pipefail; $CMD; set +eo pipefail")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?
  debug "Diff command return code: ${ERROR_CODE}"

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    error "Failed to get Diff with:[$CMD]"
    IssueHintForFullGitHistory
    fatal "[Diff command output: ${CMD_OUTPUT}]"
  fi

  ###################################################
  # Map command output to an array to proper handle #
  ###################################################
  mapfile -t RAW_FILE_ARRAY < <(echo -n "$CMD_OUTPUT")
  debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"
}

function BuildFileList() {
  debug "Building file list..."

  ################
  # Pull in vars #
  ################
  VALIDATE_ALL_CODEBASE="${1}"
  debug "VALIDATE_ALL_CODEBASE: ${VALIDATE_ALL_CODEBASE}"

  TEST_CASE_RUN="${2}"
  debug "TEST_CASE_RUN: ${TEST_CASE_RUN}"

  if [ "${VALIDATE_ALL_CODEBASE}" == "false" ] && [ "${TEST_CASE_RUN}" != "true" ]; then
    debug "----------------------------------------------"
    debug "Build the list of all changed files"

    GenerateFileDiff
  else
    WORKSPACE_PATH="${GITHUB_WORKSPACE}"
    if [ "${TEST_CASE_RUN}" == "true" ]; then
      WORKSPACE_PATH="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}"
    fi

    #############################
    # Use the find on all files #
    #############################
    if [ "${USE_FIND_ALGORITHM}" == 'true' ]; then
      ################
      # print header #
      ################
      debug "----------------------------------------------"
      debug "Populating the file list with all the files in the ${WORKSPACE_PATH} workspace using FIND algorithm"
      mapfile -t RAW_FILE_ARRAY < <(find "${WORKSPACE_PATH}" \
        -not \( -path '*/\.git' -prune \) \
        -not \( -path '*/\.pytest_cache' -prune \) \
        -not \( -path '*/\.rbenv' -prune \) \
        -not \( -path '*/\.terragrunt-cache' -prune \) \
        -not \( -path '*/\.venv' -prune \) \
        -not \( -path '*/\__pycache__' -prune \) \
        -not \( -path '*/\node_modules' -prune \) \
        -not -name ".DS_Store" \
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
        2>&1 | sort)
    else
      debug "----------------------------------------------"
      DIFF_GIT_VALIDATE_ALL_CODEBASE="git -C \"${WORKSPACE_PATH}\" ls-tree -r --name-only HEAD | xargs -I % sh -c \"echo ${WORKSPACE_PATH}/%\" 2>&1"
      debug "Populating the file list with: ${DIFF_GIT_VALIDATE_ALL_CODEBASE}"
      mapfile -t RAW_FILE_ARRAY < <(eval "set -eo pipefail; ${DIFF_GIT_VALIDATE_ALL_CODEBASE}; set +eo pipefail")
      debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"
    fi
  fi

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    fatal "Failed to gain a list of all files changed! Error code: ${ERROR_CODE}"
  fi

  ##########################################################################
  # Check to make sure the raw file array is not empty or throw a warning! #
  ##########################################################################
  if [ ${#RAW_FILE_ARRAY[@]} -eq 0 ]; then
    ###############################
    # No files were found to lint #
    ###############################
    warn "No files were found in the GITHUB_WORKSPACE:[${GITHUB_WORKSPACE}] to lint!"
  fi

  ####################################################
  # Configure linters that scan the entire workspace #
  ####################################################
  debug "Checking if we are in test mode before configuring the list of directories to lint"
  if [ "${TEST_CASE_RUN}" == "true" ]; then
    debug "We are running in test mode."

    debug "Adding test case directories to the list of directories to analyze with ansible-lint."
    DEFAULT_ANSIBLE_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/ansible"
    debug "DEFAULT_ANSIBLE_TEST_CASE_DIRECTORY: ${DEFAULT_ANSIBLE_TEST_CASE_DIRECTORY}"
    FILE_ARRAY_ANSIBLE+=("${DEFAULT_ANSIBLE_TEST_CASE_DIRECTORY}/bad")
    FILE_ARRAY_ANSIBLE+=("${DEFAULT_ANSIBLE_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with Checkov."
    DEFAULT_CHECKOV_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/checkov"
    debug "DEFAULT_CHECKOV_TEST_CASE_DIRECTORY: ${DEFAULT_CHECKOV_TEST_CASE_DIRECTORY}"
    FILE_ARRAY_CHECKOV+=("${DEFAULT_CHECKOV_TEST_CASE_DIRECTORY}/bad")
    FILE_ARRAY_CHECKOV+=("${DEFAULT_CHECKOV_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with Gitleaks."
    DEFAULT_GITLEAKS_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/gitleaks"
    debug "DEFAULT_GITLEAKS_TEST_CASE_DIRECTORY: ${DEFAULT_GITLEAKS_TEST_CASE_DIRECTORY}"
    FILE_ARRAY_GITLEAKS+=("${DEFAULT_GITLEAKS_TEST_CASE_DIRECTORY}/bad")
    FILE_ARRAY_GITLEAKS+=("${DEFAULT_GITLEAKS_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with Checkov."
    DEFAULT_JSCPD_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/jscpd"
    debug "DEFAULT_JSCPD_TEST_CASE_DIRECTORY: ${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}"
    FILE_ARRAY_JSCPD+=("${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}/bad")
    FILE_ARRAY_JSCPD+=("${DEFAULT_JSCPD_TEST_CASE_DIRECTORY}/good")

    debug "Adding test case directories to the list of directories to analyze with textlint."
    DEFAULT_NATURAL_LANGUAGE_TEST_CASE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/natural_language"
    debug "DEFAULT_NATURAL_LANGUAGE_TEST_CASE_DIRECTORY: ${DEFAULT_NATURAL_LANGUAGE_TEST_CASE_DIRECTORY}"
    FILE_ARRAY_NATURAL_LANGUAGE+=("${DEFAULT_NATURAL_LANGUAGE_TEST_CASE_DIRECTORY}/bad")
    FILE_ARRAY_NATURAL_LANGUAGE+=("${DEFAULT_NATURAL_LANGUAGE_TEST_CASE_DIRECTORY}/good")
  else
    debug "We are not running in test mode (${TEST_CASE_RUN})."

    if [ -d "${ANSIBLE_DIRECTORY}" ]; then
      debug "Adding ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) to the list of files and directories to lint."
      FILE_ARRAY_ANSIBLE+=("${ANSIBLE_DIRECTORY}")
    else
      debug "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) does NOT exist."
    fi

    if CheckovConfigurationFileContainsDirectoryOption "${CHECKOV_LINTER_RULES}"; then
      debug "No need to configure the directories to check for Checkov."
    else
      debug "Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with Checkov."
      FILE_ARRAY_CHECKOV+=("${GITHUB_WORKSPACE}")
    fi

    debug "Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with Gitleaks."
    FILE_ARRAY_GITLEAKS+=("${GITHUB_WORKSPACE}")

    debug "Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with JSCPD."
    FILE_ARRAY_JSCPD+=("${GITHUB_WORKSPACE}")

    debug "Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with textlint."
    FILE_ARRAY_NATURAL_LANGUAGE+=("${GITHUB_WORKSPACE}")
  fi

  if CheckovConfigurationFileContainsDirectoryOption "${CHECKOV_LINTER_RULES}"; then
    debug "No need to configure the directories to check for Checkov."
  else
    debug "Checking if we are in test mode before configuring the list of directories to lint with Checkov"
    if [ "${TEST_CASE_RUN}" == "true" ]; then
      debug "We are running in test mode. Adding test case directories to the list of directories to analyze with Checkov."
      FILE_ARRAY_CHECKOV+=("${DEFAULT_CHECKOV_TEST_CASE_DIRECTORY}/bad")
      FILE_ARRAY_CHECKOV+=("${DEFAULT_CHECKOV_TEST_CASE_DIRECTORY}/good")
    else
      debug "We are not running in test mode (${TEST_CASE_RUN}). Adding ${GITHUB_WORKSPACE} to the list of directories to analyze with Checkov."
      FILE_ARRAY_CHECKOV+=("${GITHUB_WORKSPACE}")
    fi
  fi

  ################################################
  # Iterate through the array of all files found #
  ################################################
  info "---------------------------------"
  info "------ File list to check: ------"
  info "---------------------------------"
  for FILE in "${RAW_FILE_ARRAY[@]}"; do
    # Get the file extension
    FILE_TYPE="$(GetFileExtension "$FILE")"
    # Get the name of the file (lowercase) and the containing directory path
    BASE_FILE=$(basename "${FILE,,}")
    FILE_DIR_NAME="$(dirname "${FILE}")"

    ##############
    # Print file #
    ##############
    debug "FILE: ${FILE}, FILE_TYPE: ${FILE_TYPE}, BASE_FILE: ${BASE_FILE}, FILE_DIR_NAME: ${FILE_DIR_NAME}"

    ##########################################################
    # Check if the file exists on the filesystem, or skip it #
    ##########################################################
    if [ ! -f "${FILE}" ]; then
      # File not found in workspace
      warn "File:{$FILE} existed in commit data, but not found on file system, skipping..."
      continue
    fi

    ########################################################
    # Don't include test cases if not running in test mode #
    ########################################################
    if [[ ${FILE} == *"${TEST_CASE_FOLDER}"* ]] && [ "${TEST_CASE_RUN}" != "true" ]; then
      debug "TEST_CASE_RUN (${TEST_CASE_RUN}) is not true. Skipping ${FILE}..."
      continue
    ##################################################
    # Include test cases if not running in test mode #
    ##################################################
    elif [[ ${FILE} != *"${TEST_CASE_FOLDER}"* ]] && [ "${TEST_CASE_RUN}" == "true" ]; then
      debug "TEST_CASE_RUN (${TEST_CASE_RUN}) is true. Skipping ${FILE}..."
    fi

    ###############################################
    # Filter files if FILTER_REGEX_INCLUDE is set #
    ###############################################
    if [[ -n "$FILTER_REGEX_INCLUDE" ]] && [[ ! (${FILE} =~ $FILTER_REGEX_INCLUDE) ]]; then
      debug "FILTER_REGEX_INCLUDE didn't match. Skipping ${FILE}"
      continue
    fi

    ###############################################
    # Filter files if FILTER_REGEX_EXCLUDE is set #
    ###############################################
    if [[ -n "$FILTER_REGEX_EXCLUDE" ]] && [[ ${FILE} =~ $FILTER_REGEX_EXCLUDE ]]; then
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

    # Editorconfig-checker should check every file
    FILE_ARRAY_EDITORCONFIG+=("${FILE}")

    # See https://docs.renovatebot.com/configuration-options/
    if [[ "${BASE_FILE}" =~ renovate.json5? ]] ||
      [ "${BASE_FILE}" == ".renovaterc" ] || [[ "${BASE_FILE}" =~ .renovaterc.json5? ]]; then
      FILE_ARRAY_RENOVATE+=("${FILE}")
    fi

    # See https://docs.renovatebot.com/config-presets/
    IFS="," read -r -a RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY <<<"${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES}"
    for file_name in "${RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES_ARRAY[@]}"; do
      if [ "${BASE_FILE}" == "${file_name}" ]; then
        FILE_ARRAY_RENOVATE+=("${FILE}")
        break
      fi
    done

    if [ "${BASE_FILE}" == "go.mod" ]; then
      debug "Found ${FILE}. Checking if individual Go file linting is enabled as well."
      if [ "${VALIDATE_GO}" == "true" ]; then
        debug "Checking if we are running tests. TEST_CASE_RUN: ${TEST_CASE_RUN}"
        if [ "${TEST_CASE_RUN}" == "true" ]; then
          debug "Skipping the failure due to individual Go files and Go modules linting being enabled at the same time because we're in test mode."
        else
          fatal "Set VALIDATE_GO to false to avoid false positives due to analyzing Go files in the ${FILE_DIR_NAME} directory individually instead of considering them in the context of a Go module."
        fi
      else
        debug "Considering ${FILE_DIR_NAME} as a Go module."
      fi
      FILE_ARRAY_GO_MODULES+=("${FILE_DIR_NAME}")
    fi

    #######################
    # Get the shell files #
    #######################
    if IsValidShellScript "${FILE}"; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_BASH+=("${FILE}")
      FILE_ARRAY_BASH_EXEC+=("${FILE}")
      FILE_ARRAY_SHELL_SHFMT+=("${FILE}")

    #########################
    # Get the CLOJURE files #
    #########################
    elif [ "${FILE_TYPE}" == "clj" ] || [ "${FILE_TYPE}" == "cljs" ] ||
      [ "${FILE_TYPE}" == "cljc" ] || [ "${FILE_TYPE}" == "edn" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CLOJURE+=("${FILE}")
    #####################
    # Get the C++ files #
    #####################
    elif [ "${FILE_TYPE}" == "cpp" ] || [ "${FILE_TYPE}" == "h" ] ||
      [ "${FILE_TYPE}" == "cc" ] || [ "${FILE_TYPE}" == "hpp" ] ||
      [ "${FILE_TYPE}" == "cxx" ] || [ "${FILE_TYPE}" == "cu" ] ||
      [ "${FILE_TYPE}" == "hxx" ] || [ "${FILE_TYPE}" == "c++" ] ||
      [ "${FILE_TYPE}" == "hh" ] || [ "${FILE_TYPE}" == "h++" ] ||
      [ "${FILE_TYPE}" == "cuh" ] || [ "${FILE_TYPE}" == "c" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CPP+=("${FILE}")
      FILE_ARRAY_CLANG_FORMAT+=("${FILE}")

    ########################
    # Get the COFFEE files #
    ########################
    elif [ "${FILE_TYPE}" == "coffee" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_COFFEESCRIPT+=("${FILE}")

    ########################
    # Get the CSHARP files #
    ########################
    elif [ "${FILE_TYPE}" == "cs" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CSHARP+=("${FILE}")

    #####################
    # Get the CSS files #
    #####################
    elif [ "${FILE_TYPE}" == "css" ] || [ "${FILE_TYPE}" == "scss" ] ||
      [ "${FILE_TYPE}" == "sass" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CSS+=("${FILE}")

    ######################
    # Get the DART files #
    ######################
    elif [ "${FILE_TYPE}" == "dart" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_DART+=("${FILE}")

    ########################
    # Get the DOCKER files #
    ########################
    # Use BASE_FILE here because FILE_TYPE is not reliable when there is no file extension
    elif [[ "${FILE_TYPE}" != "tap" ]] && [[ "${FILE_TYPE}" != "yml" ]] &&
      [[ "${FILE_TYPE}" != "yaml" ]] && [[ "${FILE_TYPE}" != "json" ]] &&
      [[ "${FILE_TYPE}" != "xml" ]] &&
      [[ "${BASE_FILE}" =~ ^(.+\.)?(contain|dock)erfile$ ]]; then

      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_DOCKERFILE_HADOLINT+=("${FILE}")

    #####################
    # Get the ENV files #
    #####################
    elif [ "${FILE_TYPE}" == "env" ] || [[ "${BASE_FILE}" == *".env."* ]]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_ENV+=("${FILE}")

    #########################
    # Get the Gherkin files #
    #########################
    elif [ "${FILE_TYPE}" == "feature" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_GHERKIN+=("${FILE}")

    ########################
    # Get the Golang files #
    ########################
    elif [ "${FILE_TYPE}" == "go" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_GO+=("${FILE}")

    ########################
    # Get the GROOVY files #
    ########################
    # Use BASE_FILE here because FILE_TYPE is not reliable when there is no file extension
    elif [ "$FILE_TYPE" == "groovy" ] || [ "$FILE_TYPE" == "jenkinsfile" ] ||
      [ "$FILE_TYPE" == "gradle" ] || [ "$FILE_TYPE" == "nf" ] ||
      [[ "$BASE_FILE" =~ .*jenkinsfile.* ]]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_GROOVY+=("$FILE")

    ######################
    # Get the HTML files #
    ######################
    elif [ "${FILE_TYPE}" == "html" ]; then
      ################################
      # Append the file to the array #
      ##############################p##
      FILE_ARRAY_HTML+=("${FILE}")

    ######################
    # Get the Java files #
    ######################
    elif [ "${FILE_TYPE}" == "java" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JAVA+=("${FILE}")
      FILE_ARRAY_GOOGLE_JAVA_FORMAT+=("${FILE}")

    ############################
    # Get the JavaScript files #
    ############################
    elif [ "${FILE_TYPE}" == "js" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JAVASCRIPT_ES+=("${FILE}")
      FILE_ARRAY_JAVASCRIPT_STANDARD+=("${FILE}")
      FILE_ARRAY_JAVASCRIPT_PRETTIER+=("${FILE}")

    #######################
    # Get the JSONC files #
    #######################
    elif [ "$FILE_TYPE" == "jsonc" ] || [ "$FILE_TYPE" == "json5" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSONC+=("${FILE}")

    ######################
    # Get the JSON files #
    ######################
    elif [ "${FILE_TYPE}" == "json" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSON+=("${FILE}")

      ############################
      # Check if file is OpenAPI #
      ############################
      if DetectOpenAPIFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_OPENAPI+=("${FILE}")
      fi
      ########################
      # Check if file is ARM #
      ########################
      if DetectARMFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_ARM+=("${FILE}")
      fi
      #####################################
      # Check if the file is CFN template #
      #####################################
      if DetectCloudFormationFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_CLOUDFORMATION+=("${FILE}")
      fi
      ############################################
      # Check if the file is AWS States Language #
      ############################################
      if DetectAWSStatesFIle "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_STATES+=("${FILE}")
      fi

    #####################
    # Get the JSX files #
    #####################
    elif [ "${FILE_TYPE}" == "jsx" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSX+=("${FILE}")

    ########################
    # Get the KOTLIN files #
    ########################
    elif [ "${FILE_TYPE}" == "kt" ] || [ "${FILE_TYPE}" == "kts" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_KOTLIN+=("${FILE}")
      FILE_ARRAY_KOTLIN_ANDROID+=("${FILE}")

    #####################
    # Get the LUA files #
    #####################
    elif [ "$FILE_TYPE" == "lua" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_LUA+=("$FILE")

    #######################
    # Get the LaTeX files #
    #######################
    elif [ "${FILE_TYPE}" == "tex" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_LATEX+=("${FILE}")

    ##########################
    # Get the MARKDOWN files #
    ##########################
    elif [ "${FILE_TYPE}" == "md" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_MARKDOWN+=("${FILE}")

    ######################
    # Get the PHP files #
    ######################
    elif [ "${FILE_TYPE}" == "php" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PHP_BUILTIN+=("${FILE}")
      FILE_ARRAY_PHP_PHPCS+=("${FILE}")
      FILE_ARRAY_PHP_PHPSTAN+=("${FILE}")
      FILE_ARRAY_PHP_PSALM+=("${FILE}")

    ######################
    # Get the PERL files #
    ######################
    elif [ "${FILE_TYPE}" == "pl" ] || [ "${FILE_TYPE}" == "pm" ] ||
      [ "${FILE_TYPE}" == "t" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PERL+=("${FILE}")

    ############################
    # Get the Powershell files #
    ############################
    elif [ "${FILE_TYPE}" == "ps1" ] ||
      [ "${FILE_TYPE}" == "psm1" ] ||
      [ "${FILE_TYPE}" == "psd1" ] ||
      [ "${FILE_TYPE}" == "ps1xml" ] ||
      [ "${FILE_TYPE}" == "pssc" ] ||
      [ "${FILE_TYPE}" == "psrc" ] ||
      [ "${FILE_TYPE}" == "cdxml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_POWERSHELL+=("${FILE}")

    #################################
    # Get the PROTOCOL BUFFER files #
    #################################
    elif [ "${FILE_TYPE}" == "proto" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PROTOBUF+=("${FILE}")

    ########################
    # Get the PYTHON files #
    ########################
    elif [ "${FILE_TYPE}" == "py" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PYTHON_BLACK+=("${FILE}")
      FILE_ARRAY_PYTHON_FLAKE8+=("${FILE}")
      FILE_ARRAY_PYTHON_ISORT+=("${FILE}")
      FILE_ARRAY_PYTHON_PYLINT+=("${FILE}")
      FILE_ARRAY_PYTHON_MYPY+=("${FILE}")

    ######################
    # Get the RAKU files #
    ######################
    elif [ "${FILE_TYPE}" == "raku" ] || [ "${FILE_TYPE}" == "rakumod" ] ||
      [ "${FILE_TYPE}" == "rakutest" ] || [ "${FILE_TYPE}" == "pm6" ] ||
      [ "${FILE_TYPE}" == "pl6" ] || [ "${FILE_TYPE}" == "p6" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_RAKU+=("${FILE}")

    ####################
    # Get the R files  #
    ####################
    elif [ "${FILE_TYPE}" == "r" ] || [ "${FILE_TYPE}" == "rmd" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_R+=("${FILE}")

    ######################
    # Get the RUBY files #
    ######################
    elif [ "${FILE_TYPE}" == "rb" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_RUBY+=("${FILE}")

    ######################
    # Get the RUST files #
    ######################
    elif [ "${FILE_TYPE}" == "rs" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_RUST_2015+=("${FILE}")
      FILE_ARRAY_RUST_2018+=("${FILE}")
      FILE_ARRAY_RUST_2021+=("${FILE}")

    #######################
    # Get the RUST crates #
    #######################
    elif [ "${BASE_FILE}" == "cargo.toml" ]; then
      ###############################################
      # Append the crate manifest file to the array #
      ###############################################
      FILE_ARRAY_RUST_CLIPPY+=("${FILE}")

    ###########################
    # Get the SCALA files #
    ###########################
    elif [ "${FILE_TYPE}" == "scala" ] || [ "${FILE_TYPE}" == "sc" ] || [ "${BASE_FILE}" == "??????" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_SCALAFMT+=("${FILE}")

    ###########################
    # Get the SNAKEMAKE files #
    ###########################
    elif [ "${FILE_TYPE}" == "smk" ] || [ "${BASE_FILE}" == "snakefile" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_SNAKEMAKE_LINT+=("${FILE}")
      FILE_ARRAY_SNAKEMAKE_SNAKEFMT+=("${FILE}")

    #####################
    # Get the SQL files #
    #####################
    elif [ "${FILE_TYPE}" == "sql" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_SQL+=("${FILE}")
      FILE_ARRAY_SQLFLUFF+=("${FILE}")

    ###########################
    # Get the Terraform files #
    ###########################
    elif [ "${FILE_TYPE}" == "tf" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TERRAFORM_TFLINT+=("${FILE}")
      FILE_ARRAY_TERRAFORM_TERRASCAN+=("${FILE}")
      FILE_ARRAY_TERRAFORM_FMT+=("${FILE}")

    ############################
    # Get the Terragrunt files #
    ############################
    elif [ "${FILE_TYPE}" == "hcl" ] && [[ ${FILE} != *".tflint.hcl"* ]] && [[ ${FILE} != *".pkr.hcl"* ]]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TERRAGRUNT+=("${FILE}")

    ############################
    # Get the TypeScript files #
    ############################
    elif [ "${FILE_TYPE}" == "ts" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TYPESCRIPT_ES+=("${FILE}")
      FILE_ARRAY_TYPESCRIPT_STANDARD+=("${FILE}")
      FILE_ARRAY_TYPESCRIPT_PRETTIER+=("${FILE}")

    #####################
    # Get the TSX files #
    #####################
    elif [ "${FILE_TYPE}" == "tsx" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TSX+=("${FILE}")

    #####################
    # Get the XML files #
    #####################
    elif [ "${FILE_TYPE}" == "xml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_XML+=("${FILE}")

    ################################
    # Get the CLOUDFORMATION files #
    ################################
    elif [ "${FILE_TYPE}" == "yml" ] || [ "${FILE_TYPE}" == "yaml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_YAML+=("${FILE}")

      ###################################
      # Check if file is GitHub Actions #
      ###################################
      if DetectActions "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_GITHUB_ACTIONS+=("${FILE}")
      fi

      #####################################
      # Check if the file is CFN template #
      #####################################
      if DetectCloudFormationFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_CLOUDFORMATION+=("${FILE}")
      fi

      ############################
      # Check if file is OpenAPI #
      ############################
      if DetectOpenAPIFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_OPENAPI+=("${FILE}")
      fi

      ########################################
      # Check if the file is Tekton template #
      ########################################
      if DetectTektonFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_TEKTON+=("${FILE}")
      fi

      ############################################
      # Check if the file is Kubernetes template #
      ############################################
      if DetectKubernetesFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_KUBERNETES_KUBECONFORM+=("${FILE}")
      fi
    ########################################################################
    # We have something that we need to try to check file type another way #
    ########################################################################
    else
      ##############################################
      # Use file to see if we can parse what it is #
      ##############################################
      CheckFileType "${FILE}"
    fi
    ##########################################
    # Print line break after each file debug #
    ##########################################
    debug ""
  done

  ################
  # Footer print #
  ################
  info "----------------------------------------------"
  info "Successfully gathered list of files..."
}
