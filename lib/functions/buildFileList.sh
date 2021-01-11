#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter Build File List Functions @admiralawkbar ##############
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function BuildFileList ####################################################
function BuildFileList() {
  debug "Building file list..."

  ################
  # Pull in vars #
  ################
  VALIDATE_ALL_CODEBASE="${1}"
  debug "Validate all code base: ${VALIDATE_ALL_CODEBASE}..."

  TEST_CASE_RUN="${2}"
  debug "TEST_CASE_RUN: ${TEST_CASE_RUN}..."

  ANSIBLE_DIRECTORY="${3}"
  debug "ANSIBLE_DIRECTORY: ${ANSIBLE_DIRECTORY}..."

  if [ "${VALIDATE_ALL_CODEBASE}" == "false" ] && [ "${TEST_CASE_RUN}" != "true" ]; then
    # Need to build a list of all files changed
    # This can be pulled from the GITHUB_EVENT_PATH payload

    ################
    # print header #
    ################
    debug "----------------------------------------------"
    debug "Pulling in code history and branches..."

    #################################################################################
    # Switch codebase back to the default branch to get a list of all files changed #
    #################################################################################
    SWITCH_CMD=$(
      git -C "${GITHUB_WORKSPACE}" pull --quiet
      git -C "${GITHUB_WORKSPACE}" checkout "${DEFAULT_BRANCH}" 2>&1
    )

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ ${ERROR_CODE} -ne 0 ]; then
      # Error
      info "Failed to switch to ${DEFAULT_BRANCH} branch to get files changed!"
      fatal "[${SWITCH_CMD}]"
    fi

    if [ "${GITHUB_EVENT_NAME}" == "push" ]; then
      ################
      # push event   #
      ################
      ################
      # print header #
      ################
      debug "----------------------------------------------"
      debug "Generating Diff with:[git diff-tree --no-commit-id --name-only -r \"${GITHUB_SHA}\"]"

      #################################################
      # Get the Array of files changed in the commits #
      #################################################
      mapfile -t RAW_FILE_ARRAY < <(git diff-tree --no-commit-id --name-only -r "${GITHUB_SHA}" 2>&1)

      ###############################################################
      # Need to see if the array is empty, if so, try the other way #
      ###############################################################
      if [ ${#RAW_FILE_ARRAY[@]} -eq 0 ]; then
        # Empty array, going to try to pull from main branch differences
        ################
        # print header #
        ################
        debug "----------------------------------------------"
        debug "WARN: Generation of File array with diff-tree produced [0] items, trying with git diff..."
        debug "Generating Diff with:[git diff --name-only '${DEFAULT_BRANCH}...${GITHUB_SHA}' --diff-filter=d]"

        #################################################
        # Get the Array of files changed in the commits #
        #################################################
        mapfile -t RAW_FILE_ARRAY < <(git -C "${GITHUB_WORKSPACE}" diff --name-only "${DEFAULT_BRANCH}...${GITHUB_SHA}" --diff-filter=d 2>&1)
      fi
    else
      ################
      # PR event     #
      ################
      ################
      # print header #
      ################
      debug "----------------------------------------------"
      debug "Generating Diff with:[git diff --name-only '${DEFAULT_BRANCH}...${GITHUB_SHA}' --diff-filter=d]"

      #################################################
      # Get the Array of files changed in the commits #
      #################################################
      mapfile -t RAW_FILE_ARRAY < <(git -C "${GITHUB_WORKSPACE}" diff --name-only "${DEFAULT_BRANCH}...${GITHUB_SHA}" --diff-filter=d 2>&1)
    fi
  else
    WORKSPACE_PATH="${GITHUB_WORKSPACE}"
    if [ "${TEST_CASE_RUN}" == "true" ]; then
      WORKSPACE_PATH="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}"
    fi

    ################
    # print header #
    ################
    debug "----------------------------------------------"
    debug "Populating the file list with all the files in the ${WORKSPACE_PATH} workspace"
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

    debug "RAW_FILE_ARRAY contents: ${RAW_FILE_ARRAY[*]}"
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

  if [ "${VALIDATE_ALL_CODEBASE}" == "false" ]; then
    #########################################
    # Need to switch back to branch of code #
    #########################################
    SWITCH2_CMD=$(git -C "${GITHUB_WORKSPACE}" checkout --progress --force "${GITHUB_SHA}" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ ${ERROR_CODE} -ne 0 ]; then
      # Error
      error "Failed to switch back to branch!"
      fatal "[${SWITCH2_CMD}]"
    fi
  fi

  ################################################
  # Iterate through the array of all files found #
  ################################################
  info "---------------------------------"
  info "------ File list to check: ------"
  info "---------------------------------"
  for FILE in "${RAW_FILE_ARRAY[@]}"; do
    # Extract just the file extension
    FILE_TYPE="$(GetFileExtension "$FILE")"
    # get the baseFile for additonal logic, lowercase
    BASE_FILE=$(basename "${FILE,,}")

    ##############
    # Print file #
    ##############
    debug "File:[${FILE}], File_type:[${FILE_TYPE}], Base_file:[${BASE_FILE}]"

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

    # Editorconfig-checker should check every file
    FILE_ARRAY_EDITORCONFIG+=("${FILE}")
    # jscpd also runs an all files
    FILE_ARRAY_JSCPD+=("${FILE}")

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
    elif [[ "${FILE_TYPE}" != "dockerfilelintrc" ]] && [[ "${FILE_TYPE}" != "tap" ]] && [[ "${FILE_TYPE}" != "yml" ]] &&
      [[ "${FILE_TYPE}" != "yaml" ]] && [[ "${FILE_TYPE}" != "json" ]] && [[ "${FILE_TYPE}" != "xml" ]] && [[ "${BASE_FILE}" == *"dockerfile"* ]]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_DOCKERFILE+=("${FILE}")
      FILE_ARRAY_DOCKERFILE_HADOLINT+=("${FILE}")

    #####################
    # Get the ENV files #
    #####################
    elif [ "${FILE_TYPE}" == "env" ]; then
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
    elif [ "$FILE_TYPE" == "groovy" ] || [ "$FILE_TYPE" == "jenkinsfile" ] ||
      [ "$FILE_TYPE" == "gradle" ] || [ "$FILE_TYPE" == "nf" ]; then
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

    ######################
    # Get the JSON files #
    ######################
    elif [ "${FILE_TYPE}" == "json" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSON+=("${FILE}")

      ############################
      # Check if file is Ansible #
      ############################
      if DetectAnsibleFile "${ANSIBLE_DIRECTORY}" "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_ANSIBLE+=("${FILE}")
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

    ###########################
    # Get the Terraform files #
    ###########################
    elif [ "${FILE_TYPE}" == "tf" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TERRAFORM+=("${FILE}")
      FILE_ARRAY_TERRAFORM_TERRASCAN+=("${FILE}")

    ############################
    # Get the Terragrunt files #
    ############################
    elif [ "${FILE_TYPE}" == "hcl" ] && [[ ${FILE} != *".tflint.hcl"* ]]; then
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

      ############################
      # Check if file is Ansible #
      ############################
      if [ -d "${ANSIBLE_DIRECTORY}" ]; then
        if DetectAnsibleFile "${ANSIBLE_DIRECTORY}" "${FILE}"; then
          ################################
          # Append the file to the array #
          ################################
          FILE_ARRAY_ANSIBLE+=("${FILE}")
        fi
      else
        debug "ANSIBLE_DIRECTORY (${ANSIBLE_DIRECTORY}) does NOT exist."
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
        FILE_ARRAY_KUBERNETES_KUBEVAL+=("${FILE}")
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
