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

  ################
  # print header #
  ################
  debug "----------------------------------------------"
  debug "Generating Diff with:[git diff --name-only '${DEFAULT_BRANCH}...${GITHUB_SHA}' --diff-filter=d]"

  #################################################
  # Get the Array of files changed in the commits #
  #################################################
  mapfile -t RAW_FILE_ARRAY < <(git -C "${GITHUB_WORKSPACE}" diff --name-only "${DEFAULT_BRANCH}...${GITHUB_SHA}" --diff-filter=d 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Error
    error "Failed to gain a list of all files changed!"
    fatal "[${RAW_FILE_ARRAY[*]}]"
  fi

  ################################################
  # Iterate through the array of all files found #
  ################################################
  info "----------------------------------------------"
  info "------ Files modified in the commit(s): ------"
  info "----------------------------------------------"
  for FILE in "${RAW_FILE_ARRAY[@]}"; do
    # Extract just the file extension
    FILE_TYPE="$(GetFileExtension "$FILE")"
    # get the baseFile for additonal logic
    BASE_FILE=$(basename "${FILE,,}")

    ##############
    # Print file #
    ##############
    info "File:[${FILE}], File_type:[${FILE_TYPE}], Base_file:[${BASE_FILE}]"

    #########
    # DEBUG #
    #########
    debug "FILE_TYPE:[${FILE_TYPE}]"

    ######################
    # Get the shell files #
    ######################
    if IsValidShellScript "${FILE}"; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_BASH+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #########################
    # Get the CLOJURE files #
    #########################
    elif [ "${FILE_TYPE}" == "clj" ] || [ "${FILE_TYPE}" == "cljs" ] ||
      [ "${FILE_TYPE}" == "cljc" ] || [ "${FILE_TYPE}" == "edn" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CLOJURE+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the COFFEE files #
    ########################
    elif [ "${FILE_TYPE}" == "coffee" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_COFFEESCRIPT+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the CSHARP files #
    ########################
    elif [ "${FILE_TYPE}" == "cs" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CSHARP+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the CSS files #
    #####################
    elif [ "${FILE_TYPE}" == "css" ] || [ "${FILE_TYPE}" == "scss" ] ||
      [ "${FILE_TYPE}" == "sass" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_CSS+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ######################
    # Get the DART files #
    ######################
    elif [ "${FILE_TYPE}" == "dart" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_DART+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the DOCKER files #
    ########################
    elif [ "${FILE_TYPE}" == "dockerfile" ] || [[ "${BASE_FILE}" == *"dockerfile."* ]]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_DOCKER+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the ENV files #
    #####################
    elif [ "${FILE_TYPE}" == "env" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_ENV+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the Golang files #
    ########################
    elif [ "${FILE_TYPE}" == "go" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_GO+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the GROOVY files #
    ########################
    elif [ "$FILE_TYPE" == "groovy" ] || [ "$FILE_TYPE" == "jenkinsfile" ] ||
      [ "$FILE_TYPE" == "gradle" ] || [ "$FILE_TYPE" == "nf" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_GROOVY+=("$FILE")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ######################
    # Get the HTML files #
    ######################
    elif [ "${FILE_TYPE}" == "html" ]; then
      ################################
      # Append the file to the array #
      ##############################p##
      FILE_ARRAY_HTML+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1


    ######################
    # Get the Java files #
    ######################
    elif [ "${FILE_TYPE}" == "java" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JAVA+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ############################
    # Get the JavaScript files #
    ############################
    elif [ "${FILE_TYPE}" == "js" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JAVASCRIPT_ES+=("${FILE}")
      FILE_ARRAY_JAVASCRIPT_STANDARD+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1
    #####################
    # Get the JSX files #
    #####################

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
      ############################
      # Check if file is ARM #
      ############################
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
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    elif [ "${FILE_TYPE}" == "jsx" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSX+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the KOTLIN files #
    ########################
    elif [ "${FILE_TYPE}" == "kt" ] || [ "${FILE_TYPE}" == "kts" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_KOTLIN+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the LUA files #
    #####################
    elif [ "$FILE_TYPE" == "lua" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_LUA+=("$FILE")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #######################
    # Get the LaTeX files #
    #######################
    elif [ "${FILE_TYPE}" == "tex" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_LATEX+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1


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
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ######################
    # Get the PERL files #
    ######################
    elif [ "${FILE_TYPE}" == "pl" ] || [ "${FILE_TYPE}" == "pm" ] ||
      [ "${FILE_TYPE}" == "t" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PERL+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ############################
    # Get the Powershell files #
    ############################
    elif [ "${FILE_TYPE}" == "ps1" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_POWERSHELL+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #################################
    # Get the PROTOCOL BUFFER files #
    #################################
    elif [ "${FILE_TYPE}" == "proto" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PROTOBUF+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ########################
    # Get the PYTHON files #
    ########################
    elif [ "${FILE_TYPE}" == "py" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PYTHON_PYLINT+=("${FILE}")
      FILE_ARRAY_PYTHON_FLAKE8+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

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
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ####################
    # Get the R files  #
    ####################
    elif [ "${FILE_TYPE}" == "r" ] || [ "${FILE_TYPE}" == "rmd" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_R+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ######################
    # Get the RUBY files #
    ######################
    elif [ "${FILE_TYPE}" == "rb" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_RUBY+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ###########################
    # Get the SNAKEMAKE files #
    ###########################
    elif [ "${FILE_TYPE}" == "smk" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_SNAKEMAKE+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the SQL files #
    #####################
    elif [ "${FILE_TYPE}" == "sql" ]; then
      ################################
      # Append the file to the array #
      ##############################p##
      FILE_ARRAY_SQL+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ###########################
    # Get the Terraform files #
    ###########################
    elif [ "${FILE_TYPE}" == "tf" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TERRAFORM+=("${FILE}")
      FILE_ARRAY_TERRAFORM_TERRASCAN+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ############################
    # Get the TypeScript files #
    ############################
    elif [ "${FILE_TYPE}" == "ts" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TYPESCRIPT_ES+=("${FILE}")
      FILE_ARRAY_TYPESCRIPT_STANDARD+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the TSX files #
    #####################
    elif [ "${FILE_TYPE}" == "tsx" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_TSX+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    #####################
    # Get the XML files #
    #####################
    elif [ "${FILE_TYPE}" == "xml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_XML+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

    ################################
    # Get the CLOUDFORMATION files #
    ################################
    elif [ "${FILE_TYPE}" == "yml" ] || [ "${FILE_TYPE}" == "yaml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_YAML+=("${FILE}")
      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1

      #####################################
      # Check if the file is CFN template #
      #####################################
      if DetectCloudFormationFile "${FILE}"; then
        ################################
        # Append the file to the array #
        ################################
        FILE_ARRAY_CLOUDFORMATION+=("${FILE}")
        ##########################################################
        # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
        ##########################################################
        READ_ONLY_CHANGE_FLAG=1
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
  done

  export READ_ONLY_CHANGE_FLAG # Workaround SC2034

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

  ################
  # Footer print #
  ################
  info "----------------------------------------------"
  info "Successfully gathered list of files..."
}
################################################################################
#### Function GetFileType ######################################################
function GetFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  ################
  # Pull in Vars #
  ################
  FILE="$1"

  ##################
  # Check the file #
  ##################
  GET_FILE_TYPE_CMD=$(file "${FILE}" 2>&1)

  echo "${GET_FILE_TYPE_CMD}"
}
################################################################################
#### Function CheckFileType ####################################################
function CheckFileType() {
  # Need to run the file through the 'file' exec to help determine
  # The type of file being parsed

  ################
  # Pull in Vars #
  ################
  FILE="$1"

  #################
  # Get file type #
  #################
  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  #################
  # Check if bash #
  #################
  if IsValidShellScript "$FILE"; then
    ################################
    # Append the file to the array #
    ################################
    FILE_ARRAY_BASH+=("${FILE}")
    ##########################################################
    # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
    ##########################################################
    READ_ONLY_CHANGE_FLAG=1
  elif [[ ${GET_FILE_TYPE_CMD} == *"Ruby script"* ]]; then
    #######################
    # It is a Ruby script #
    #######################
    warn "Found ruby script without extension:[.rb]"
    info "Please update file with proper extensions."
    ################################
    # Append the file to the array #
    ################################
    FILE_ARRAY_RUBY+=("${FILE}")
    ##########################################################
    # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
    ##########################################################
    READ_ONLY_CHANGE_FLAG=1
  else
    ############################
    # Extension was not found! #
    ############################
    warn "Failed to get filetype for:[${FILE}]!"
    ##########################################################
    # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
    ##########################################################
    READ_ONLY_CHANGE_FLAG=1
  fi
}
################################################################################
#### Function GetFileExtension ###############################################
function GetFileExtension() {
  ################
  # Pull in Vars #
  ################
  FILE="$1"

  ###########################
  # Get the files extension #
  ###########################
  # Extract just the file extension
  FILE_TYPE=${FILE##*.}
  # To lowercase
  FILE_TYPE=${FILE_TYPE,,}

  echo "$FILE_TYPE"
}
################################################################################
#### Function IsValidShellScript ###############################################
function IsValidShellScript() {
  ################
  # Pull in Vars #
  ################
  FILE="$1"

  #################
  # Get file type #
  #################
  FILE_EXTENSION="$(GetFileExtension "$FILE")"
  GET_FILE_TYPE_CMD="$(GetFileType "$FILE")"

  trace "File:[${FILE}], File extension:[${FILE_EXTENSION}], File type: [${GET_FILE_TYPE_CMD}]"

  if [[ "${FILE_EXTENSION}" == "zsh" ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"zsh script"* ]]; then
    warn "$FILE is a ZSH script. Skipping..."
    return 1
  fi

  if [ "${FILE_EXTENSION}" == "sh" ] ||
    [ "${FILE_EXTENSION}" == "bash" ] ||
    [ "${FILE_EXTENSION}" == "dash" ] ||
    [ "${FILE_EXTENSION}" == "ksh" ]; then
      debug "$FILE is a valid shell script (has a valid extension: ${FILE_EXTENSION})"
      return 0
  fi

  if [[ "${GET_FILE_TYPE_CMD}" == *"POSIX shell script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"Bourne-Again shell script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"dash script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"ksh script"* ]] ||
    [[ ${GET_FILE_TYPE_CMD} == *"/usr/bin/env sh script"* ]]; then
      debug "$FILE is a valid shell script (has a valid file type: ${GET_FILE_TYPE_CMD})"
      return 0
  fi

  trace "$FILE is NOT a supported shell script. Skipping"
  return 1
}
################################################################################
#### Function IsValidShellScript ###############################################
function PopulateShellScriptsList() {
  debug "Populating shell script file list. Source: ${GITHUB_WORKSPACE}"

  ###############################################################################
  # Set the file seperator to newline to allow for grabbing objects with spaces #
  ###############################################################################
  IFS=$'\n'

  mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" \
    -path "*/node_modules" -prune -o \
    -path "*/.git" -prune -o \
    -path "*/.venv" -prune -o \
    -path "*/.rbenv" -prune -o \
    -type f 2>&1)
  for FILE in "${LIST_FILES[@]}"; do
    if IsValidShellScript "${FILE}"; then
      debug "Adding ${FILE} to shell script files list"
      FILE_ARRAY_BASH+=("${FILE}")

      ##########################################################
      # Set the READ_ONLY_CHANGE_FLAG since this could be exec #
      ##########################################################
      READ_ONLY_CHANGE_FLAG=1
    fi
  done

  ###########################
  # Set IFS back to default #
  ###########################
  IFS="${DEFAULT_IFS}"
}
