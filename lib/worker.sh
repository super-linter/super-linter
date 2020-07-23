#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions @admiralawkbar ######################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function LintCodebase #####################################################
function LintCodebase() {
  ####################
  # Pull in the vars #
  ####################
  FILE_TYPE="${1}" && shift       # Pull the variable and remove from array path  (Example: JSON)
  LINTER_NAME="${1}" && shift     # Pull the variable and remove from array path  (Example: jsonlint)
  LINTER_COMMAND="${1}" && shift  # Pull the variable and remove from array path  (Example: jsonlint -c ConfigFile /path/to/file)
  FILE_EXTENSIONS="${1}" && shift # Pull the variable and remove from array path  (Example: *.json)
  FILE_ARRAY=("$@")             # Array of files to validate                    (Example: ${FILE_ARRAY_JSON})

  ######################
  # Create Print Array #
  ######################
  PRINT_ARRAY=()

  ################
  # print header #
  ################
  PRINT_ARRAY+=("")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("Linting [${FILE_TYPE}] files...")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("----------------------------------------------")

  #####################################
  # Validate we have linter installed #
  #####################################
  VALIDATE_INSTALL_CMD=$(command -v "${LINTER_NAME}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failed
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to find [${LINTER_NAME}] in system!${NC}"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${VALIDATE_INSTALL_CMD}]${NC}"
    exit 1
  else
    # Success
    if [[ ${ACTIONS_RUNNER_DEBUG} == "true" ]]; then
      echo -e "${NC}${F[B]}Successfully found binary for ${F[W]}[${LINTER_NAME}]${F[B]} in system location: ${F[W]}[${VALIDATE_INSTALL_CMD}]${NC}"
    fi
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ################
  # Set the flag #
  ################
  SKIP_FLAG=0

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY[@]} -eq 0 ] && [ "${VALIDATE_ALL_CODEBASE}" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    SKIP_FLAG=1
    # echo " - No files found in changeset to lint for language:[${FILE_TYPE}]"
  elif [ ${#FILE_ARRAY[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY[@]}") # Copy the array into list
  else
    ###############################################################################
    # Set the file seperator to newline to allow for grabbing objects with spaces #
    ###############################################################################
    IFS=$'\n'

    #################################
    # Get list of all files to lint #
    #################################
    mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" -type f -regex "${FILE_EXTENSIONS}" 2>&1)

    ###########################
    # Set IFS back to default #
    ###########################
    IFS="${DEFAULT_IFS}"

    ############################################################
    # Set it back to empty if loaded with blanks from scanning #
    ############################################################
    if [ ${#LIST_FILES[@]} -lt 1 ]; then
      ######################
      # Set to empty array #
      ######################
      LIST_FILES=()
      #############################
      # Skip as we found no files #
      #############################
      SKIP_FLAG=1
    fi
  fi

  ###############################
  # Check if any data was found #
  ###############################
  if [ ${SKIP_FLAG} -eq 0 ]; then
    ######################
    # Print Header array #
    ######################
    for LINE in "${PRINT_ARRAY[@]}"; do
      #########################
      # Print the header info #
      #########################
      echo "${LINE}"
    done

    ########################################
    # Prepare context if TAP format output #
    ########################################
    if IsTAP ; then
      TMPFILE=$(mktemp -q "/tmp/super-linter-${FILE_TYPE}.XXXXXX")
      INDEX=0
      mkdir -p "${REPORT_OUTPUT_FOLDER}"
      REPORT_OUTPUT_FILE="${REPORT_OUTPUT_FOLDER}/super-linter-${FILE_TYPE}.${OUTPUT_FORMAT}"
    fi

    ##################
    # Lint the files #
    ##################
    for FILE in "${LIST_FILES[@]}"; do
      ###################################
      # Get the file name and directory #
      ###################################
      FILE_NAME=$(basename "${FILE}" 2>&1)
      DIR_NAME=$(dirname "${FILE}" 2>&1)

      #####################################################
      # Make sure we dont lint node modules or test cases #
      #####################################################
      if [[ ${FILE} == *"node_modules"* ]]; then
        # This is a node modules file
        continue
      elif [[ ${FILE} == *"${TEST_CASE_FOLDER}"* ]]; then
        # This is the test cases, we should always skip
        continue
      elif [[ ${FILE} == *".git"* ]]; then
        # This is likely the .git folder and shouldnt be parsed
        continue
      fi

      ##################################
      # Increase the linted file index #
      ##################################
      (("INDEX++"))

      ##############
      # File print #
      ##############
      echo "---------------------------"
      echo "File:[${FILE}]"

      #################################
      # Add the language to the array #
      #################################
      LINTED_LANGUAGES_ARRAY+=("${FILE_TYPE}")

      ####################
      # Set the base Var #
      ####################
      LINT_CMD=''

      ####################################
      # Corner case for pwsh subshell    #
      #  - PowerShell (PSScriptAnalyzer) #
      #  - ARM        (arm-ttk)          #
      ####################################
      if [[ ${FILE_TYPE} == "POWERSHELL" ]] || [[ ${FILE_TYPE} == "ARM" ]]; then
        ################################
        # Lint the file with the rules #
        ################################
        # Need to run PowerShell commands using pwsh -c, also exit with exit code from inner subshell
        LINT_CMD=$(
          cd "${GITHUB_WORKSPACE}" || exit
          pwsh -NoProfile -NoLogo -Command "${LINTER_COMMAND} ${FILE}; if (\${Error}.Count) { exit 1 }"
          exit $? 2>&1
        )
      ###############################################################################
      # Corner case for groovy as we have to pass it as path and file in ant format #
      ###############################################################################
      elif [[ ${FILE_TYPE} == "GROOVY" ]]; then
        #######################################
        # Lint the file with the updated path #
        #######################################
        LINT_CMD=$(
          cd "${GITHUB_WORKSPACE}" || exit
          ${LINTER_COMMAND} --path "${DIR_NAME}" --files "$FILE_NAME" 2>&1
        )
      else
        ################################
        # Lint the file with the rules #
        ################################
        LINT_CMD=$(
          cd "${GITHUB_WORKSPACE}" || exit
          ${LINTER_COMMAND} "${FILE}" 2>&1
        )
      fi

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ ${ERROR_CODE} -ne 0 ]; then
        #########
        # Error #
        #########
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Found errors in [${LINTER_NAME}] linter!${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${LINT_CMD}]${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC} Linter CMD:[${LINTER_COMMAND} ${FILE}]${NC}"
        # Increment the error count
        (("ERRORS_FOUND_${FILE_TYPE}++"))

        #######################################################
        # Store the linting as a temporary file in TAP format #
        #######################################################
        if IsTAP ; then
          NotOkTap "${INDEX}" "${FILE}" "${TMPFILE}"
          AddDetailedMessageIfEnabled "${LINT_CMD}" "${TMPFILE}"
        fi
      else
        ###########
        # Success #
        ###########
        echo -e "${NC}${F[B]} - File:${F[W]}[${FILE_NAME}]${F[B]} was linted with ${F[W]}[${LINTER_NAME}]${F[B]} successfully${NC}"

        #######################################################
        # Store the linting as a temporary file in TAP format #
        #######################################################
        if IsTAP ; then
          OkTap "${INDEX}" "${FILE}" "${TMPFILE}"
        fi
      fi
    done

    #################################
    # Generate report in TAP format #
    #################################
    if IsTAP && [ ${INDEX} -gt 0 ] ; then
      HeaderTap "${INDEX}" "${REPORT_OUTPUT_FILE}"
      cat "${TMPFILE}" >> "${REPORT_OUTPUT_FILE}"
    fi
  fi
}
################################################################################
#### Function TestCodebase #####################################################
function TestCodebase() {
  ####################
  # Pull in the vars #
  ####################
  FILE_TYPE="${1}"             # Pull the variable and remove from array path  (Example: JSON)
  LINTER_NAME="${2}"           # Pull the variable and remove from array path  (Example: jsonlint)
  LINTER_COMMAND="${3}"        # Pull the variable and remove from array path  (Example: jsonlint -c ConfigFile /path/to/file)
  FILE_EXTENSIONS="${4}"       # Pull the variable and remove from array path  (Example: *.json)
  INDVIDUAL_TEST_FOLDER="${5}" # Folder for specific tests
  TESTS_RAN=0                # Incremented when tests are ran, this will help find failed finds

  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "----------------------------------------------"
  echo "Testing Codebase [${FILE_TYPE}] files..."
  echo "----------------------------------------------"
  echo "----------------------------------------------"
  echo ""

  #####################################
  # Validate we have linter installed #
  #####################################
  VALIDATE_INSTALL_CMD=$(command -v "${LINTER_NAME}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failed
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to find [${LINTER_NAME}] in system!${NC}"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${VALIDATE_INSTALL_CMD}]${NC}"
    exit 1
  else
    # Success
    echo -e "${NC}${F[B]}Successfully found binary for ${F[W]}[${LINTER_NAME}]${F[B]} in system location: ${F[W]}[${VALIDATE_INSTALL_CMD}]${NC}"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  #################################
  # Get list of all files to lint #
  #################################
  mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/${INDVIDUAL_TEST_FOLDER}" -type f -regex "${FILE_EXTENSIONS}" ! -path "${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/ansible/ghe-initialize/*" | sort 2>&1)

  ########################################
  # Prepare context if TAP output format #
  ########################################
  if IsTAP ; then
    TMPFILE=$(mktemp -q "/tmp/super-linter-${FILE_TYPE}.XXXXXX")
    mkdir -p "${REPORT_OUTPUT_FOLDER}"
    REPORT_OUTPUT_FILE="${REPORT_OUTPUT_FOLDER}/super-linter-${FILE_TYPE}.${OUTPUT_FORMAT}"
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"; do
    #####################
    # Get the file name #
    #####################
    FILE_NAME=$(basename "${FILE}" 2>&1)
    DIR_NAME=$(dirname "${FILE}" 2>&1)

    ############################
    # Get the file pass status #
    ############################
    # Example: markdown_good_1.md -> good
    FILE_STATUS=$(echo "${FILE_NAME}" | cut -f2 -d'_')

    #########################################################
    # If not found, assume it should be linted successfully #
    #########################################################
    if [ -z "${FILE_STATUS}" ] || [[ ${FILE} == *"README"* ]]; then
      ##################################
      # Set to good for proper linting #
      ##################################
      FILE_STATUS="good"
    fi

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[${FILE}]"

    ########################
    # Set the lint command #
    ########################
    LINT_CMD=''

    #######################################
    # Check if docker and get folder name #
    #######################################
    if [[ ${FILE_TYPE} == "DOCKER" ]]; then
      if [[ ${FILE} == *"good"* ]]; then
        #############
        # Good file #
        #############
        FILE_STATUS='good'
      else
        ############
        # Bad file #
        ############
        FILE_STATUS='bad'
      fi
    fi

    #####################
    # Check for ansible #
    #####################
    if [[ ${FILE_TYPE} == "ANSIBLE" ]]; then
      ########################################
      # Make sure we dont lint certain files #
      ########################################
      if [[ ${FILE} == *"vault.yml"* ]] || [[ ${FILE} == *"galaxy.yml"* ]]; then
        # This is a file we dont look at
        continue
      fi

      ################################
      # Lint the file with the rules #
      ################################
      LINT_CMD=$(
        cd "${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/${INDVIDUAL_TEST_FOLDER}" || exit
        ${LINTER_COMMAND} "${FILE}" 2>&1
      )
    elif [[ ${FILE_TYPE} == "POWERSHELL" ]] || [[ ${FILE_TYPE} == "ARM" ]]; then
      ################################
      # Lint the file with the rules #
      ################################
      # Need to run PowerShell commands using pwsh -c, also exit with exit code from inner subshell
      LINT_CMD=$(
        cd "${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}" || exit
        pwsh -NoProfile -NoLogo -Command "${LINTER_COMMAND} ${FILE}; if (\${Error}.Count) { exit 1 }"
        exit $? 2>&1
      )
    ###############################################################################
    # Corner case for groovy as we have to pass it as path and file in ant format #
    ###############################################################################
    elif [[ ${FILE_TYPE} == "GROOVY" ]]; then
      #######################################
      # Lint the file with the updated path #
      #######################################
      LINT_CMD=$(
        cd "${GITHUB_WORKSPACE}" || exit
        ${LINTER_COMMAND} --path "${DIR_NAME}" --files "$FILE_NAME" 2>&1
      )
    else
      ################################
      # Lint the file with the rules #
      ################################
      LINT_CMD=$(
        cd "${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}" || exit
        ${LINTER_COMMAND} "${FILE}" 2>&1
      )
    fi

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ########################################
    # Increment counter that check was ran #
    ########################################
    (("TESTS_RAN++"))

    ########################################
    # Check for if it was supposed to pass #
    ########################################
    if [[ ${FILE_STATUS} == "good" ]]; then
      ##############################
      # Check the shell for errors #
      ##############################
      if [ ${ERROR_CODE} -ne 0 ]; then
        #########
        # Error #
        #########
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Found errors in [${LINTER_NAME}] linter!${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${LINT_CMD}]${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC} Linter CMD:[${LINTER_COMMAND} ${FILE}]${NC}"
        # Increment the error count
        (("ERRORS_FOUND_${FILE_TYPE}++"))
      else
        ###########
        # Success #
        ###########
        echo -e "${NC}${F[B]} - File:${F[W]}[${FILE_NAME}]${F[B]} was linted with ${F[W]}[${LINTER_NAME}]${F[B]} successfully${NC}"
      fi
      #######################################################
      # Store the linting as a temporary file in TAP format #
      #######################################################
      if IsTAP ; then
        OkTap "${TESTS_RAN}" "${FILE_NAME}" "${TMPFILE}"
      fi
    else
      #######################################
      # File status = bad, this should fail #
      #######################################
      ##############################
      # Check the shell for errors #
      ##############################
      if [ ${ERROR_CODE} -eq 0 ]; then
        #########
        # Error #
        #########
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Found errors in [${LINTER_NAME}] linter!${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} This file should have failed test case!${NC}"
        echo -e "${NC}${B[R]}${F[W]}Command run:${NC}[\$${LINT_CMD}]${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${LINT_CMD}]${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC} Linter CMD:[${LINTER_COMMAND} ${FILE}]${NC}"
        # Increment the error count
        (("ERRORS_FOUND_${FILE_TYPE}++"))
      else
        ###########
        # Success #
        ###########
        echo -e "${NC}${F[B]} - File:${F[W]}[${FILE_NAME}]${F[B]} failed test case with ${F[W]}[${LINTER_NAME}]${F[B]} successfully${NC}"
      fi
      #######################################################
      # Store the linting as a temporary file in TAP format #
      #######################################################
      if IsTAP ; then
        NotOkTap "${TESTS_RAN}" "${FILE_NAME}" "${TMPFILE}"
        AddDetailedMessageIfEnabled "${LINT_CMD}" "${TMPFILE}"
      fi
    fi
  done

  ###########################################################################
  # Generate report in TAP format and validate with the expected TAP output #
  ###########################################################################
  if IsTAP && [ ${TESTS_RAN} -gt 0 ] ; then
    HeaderTap "${TESTS_RAN}" "${REPORT_OUTPUT_FILE}"
    cat "${TMPFILE}" >> "${REPORT_OUTPUT_FILE}"

    ########################################################################
    # If expected TAP report exists then compare with the generated report #
    ########################################################################
    EXPECTED_FILE="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/${INDVIDUAL_TEST_FOLDER}/reports/expected-${FILE_TYPE}.tap"
    if [ -e "${EXPECTED_FILE}" ] ; then
      TMPFILE=$(mktemp -q "/tmp/diff-${FILE_TYPE}.XXXXXX")
      ## Ignore white spaces, case sensitive
      if ! diff -a -w -i "${EXPECTED_FILE}" "${REPORT_OUTPUT_FILE}" > "${TMPFILE}" 2>&1; then
        #############################################
        # We failed to compare the reporting output #
        #############################################
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to assert TAP output:[${LINTER_NAME}]${NC}"!
        echo "Please validate the asserts!"
        cat "${TMPFILE}"
        exit 1
      else
        # Success
        echo -e "${NC}${F[B]}Successfully validation in the expected TAP format for ${F[W]}[${LINTER_NAME}]${NC}"
      fi
    else
      echo -e "${NC}${F[Y]}WARN!${NC} No TAP expected file found at:[${EXPECTED_FILE}]${NC}"
      echo "skipping report assertions"
      #####################################
      # Append the file type to the array #
      #####################################
      WARNING_ARRAY_TEST+=("${FILE_TYPE}")
    fi
  fi

  ##############################
  # Validate we ran some tests #
  ##############################
  if [ "${TESTS_RAN}" -eq 0 ]; then
    #################################################
    # We failed to find files and no tests were ran #
    #################################################
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to find any tests ran for the Linter:[${LINTER_NAME}]${NC}"!
    echo "Please validate logic or that tests exist!"
    exit 1
  fi
}
################################################################################
#### Function RunTestCases #####################################################
function RunTestCases() {
  # This loop will run the test cases and exclude user code
  # This is called from the automation process to validate new code
  # When a PR is opened, the new code is validated with the default branch
  # version of linter.sh, and a new container is built with the latest codebase
  # for testing. That container is spun up, and ran,
  # with the flag: TEST_CASE_RUN=true
  # So that the new code can be validated against the test cases

  #################
  # Header prints #
  #################
  echo ""
  echo "----------------------------------------------"
  echo "-------------- TEST CASE RUN -----------------"
  echo "----------------------------------------------"
  echo ""

  #######################
  # Test case languages #
  #######################
  # TestCodebase "Language" "Linter" "Linter-command" "Regex to find files" "Test Folder"
  TestCodebase "ANSIBLE" "ansible-lint" "ansible-lint -v -c ${ANSIBLE_LINTER_RULES}" ".*\.\(yml\|yaml\)\$" "ansible"
  TestCodebase "ARM" "arm-ttk" "Import-Module ${ARM_TTK_PSD1} ; \${config} = \$(Import-PowerShellDataFile -Path ${ARM_LINTER_RULES}) ; Test-AzTemplate @config -TemplatePath" ".*\.\(json\)\$" "arm"
  TestCodebase "BASH" "shellcheck" "shellcheck --color" ".*\.\(sh\|bash\|dash\|ksh\)\$" "shell"
  TestCodebase "CLOUDFORMATION" "cfn-lint" "cfn-lint --config-file ${CLOUDFORMATION_LINTER_RULES}" ".*\.\(json\|yml\|yaml\)\$" "cloudformation"
  TestCodebase "CLOJURE" "clj-kondo" "clj-kondo --config ${CLOJURE_LINTER_RULES} --lint" ".*\.\(clj\|cljs\|cljc\|edn\)\$" "clojure"
  TestCodebase "COFFEESCRIPT" "coffeelint" "coffeelint -f ${COFFEESCRIPT_LINTER_RULES}" ".*\.\(coffee\)\$" "coffeescript"
  TestCodebase "CSS" "stylelint" "stylelint --config ${CSS_LINTER_RULES}" ".*\.\(css\)\$" "css"
  TestCodebase "DART" "dart" "dartanalyzer --fatal-infos  --fatal-warnings --options ${DART_LINTER_RULES}" ".*\.\(dart\)\$" "dart"
  TestCodebase "DOCKER" "dockerfilelint" "dockerfilelint -c ${DOCKER_LINTER_RULES}" ".*\(Dockerfile\)\$" "docker"
  TestCodebase "EDITORCONFIG" "editorconfig-checker" "editorconfig-checker" ".*\.ext$" "editorconfig-checker"
  TestCodebase "ENV" "dotenv-linter" "dotenv-linter" ".*\.\(env\)\$" "env"
  TestCodebase "GO" "golangci-lint" "golangci-lint run -c ${GO_LINTER_RULES}" ".*\.\(go\)\$" "golang"
  TestCodebase "GROOVY" "npm-groovy-lint" "npm-groovy-lint -c $GROOVY_LINTER_RULES --failon error" ".*\.\(groovy\|jenkinsfile\|gradle\)\$" "groovy"
  TestCodebase "HTML" "htmlhint" "htmlhint --config ${HTML_LINTER_RULES}" ".*\.\(html\)\$" "html"
  TestCodebase "JAVASCRIPT_ES" "eslint" "eslint --no-eslintrc -c ${JAVASCRIPT_LINTER_RULES}" ".*\.\(js\)\$" "javascript"
  TestCodebase "JAVASCRIPT_STANDARD" "standard" "standard ${JAVASCRIPT_STANDARD_LINTER_RULES}" ".*\.\(js\)\$" "javascript"
  TestCodebase "JSON" "jsonlint" "jsonlint" ".*\.\(json\)\$" "json"
  TestCodebase "KOTLIN" "ktlint" "ktlint" ".*\.\(kt\|kts\)\$" "kotlin"
  TestCodebase "MARKDOWN" "markdownlint" "markdownlint -c ${MARKDOWN_LINTER_RULES}" ".*\.\(md\)\$" "markdown"
  TestCodebase "PERL" "perl" "perl -Mstrict -cw" ".*\.\(pl\)\$" "perl"
  TestCodebase "PHP" "php" "php -l" ".*\.\(php\)\$" "php"
  TestCodebase "OPENAPI" "spectral" "spectral lint -r ${OPENAPI_LINTER_RULES}" ".*\.\(ymlopenapi\|jsonopenapi\)\$" "openapi"
  TestCodebase "POWERSHELL" "pwsh" "Invoke-ScriptAnalyzer -EnableExit -Settings ${POWERSHELL_LINTER_RULES} -Path" ".*\.\(ps1\|psm1\|psd1\|ps1xml\|pssc\|psrc\|cdxml\)\$" "powershell"
  TestCodebase "PROTOBUF" "protolint" "protolint lint --config_path ${PROTOBUF_LINTER_RULES}" ".*\.\(proto\)\$" "protobuf"
  TestCodebase "PYTHON" "pylint" "pylint --rcfile ${PYTHON_LINTER_RULES}" ".*\.\(py\)\$" "python"
  TestCodebase "RAKU" "raku" "raku -c" ".*\.\(raku\|rakumod\|rakutest\|pm6\|pl6\|p6\)\$" "raku"
  TestCodebase "RUBY" "rubocop" "rubocop -c ${RUBY_LINTER_RULES}" ".*\.\(rb\)\$" "ruby"
  TestCodebase "STATES" "asl-validator" "asl-validator --json-path" ".*\.\(json\)\$" "states"
  TestCodebase "TERRAFORM" "tflint" "tflint -c ${TERRAFORM_LINTER_RULES}" ".*\.\(tf\)\$" "terraform"
  TestCodebase "TYPESCRIPT_ES" "eslint" "eslint --no-eslintrc -c ${TYPESCRIPT_LINTER_RULES}" ".*\.\(ts\)\$" "typescript"
  TestCodebase "TYPESCRIPT_STANDARD" "standard" "standard --parser @typescript-eslint/parser --plugin @typescript-eslint/eslint-plugin ${TYPESCRIPT_STANDARD_LINTER_RULES}" ".*\.\(ts\)\$" "typescript"
  TestCodebase "XML" "xmllint" "xmllint" ".*\.\(xml\)\$" "xml"
  TestCodebase "YML" "yamllint" "yamllint -c ${YAML_LINTER_RULES}" ".*\.\(yml\|yaml\)\$" "yml"

  #################
  # Footer prints #
  #################
  # Call the footer to display run information
  # and exit with error code
  Footer
}
################################################################################
#### Function LintAnsibleFiles #################################################
function LintAnsibleFiles() {
  ######################
  # Create Print Array #
  ######################
  PRINT_ARRAY=()

  ################
  # print header #
  ################
  PRINT_ARRAY+=("")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("Linting [Ansible] files...")
  PRINT_ARRAY+=("----------------------------------------------")
  PRINT_ARRAY+=("----------------------------------------------")

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="ansible-lint"

  ###########################################
  # Validate we have ansible-lint installed #
  ###########################################
  VALIDATE_INSTALL_CMD=$(command -v "${LINTER_NAME}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failed
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to find ${LINTER_NAME} in system!${NC}"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${VALIDATE_INSTALL_CMD}]${NC}"
    exit 1
  else
    # Success
    if [[ ${ACTIONS_RUNNER_DEBUG} == "true" ]]; then
      # Success
      echo -e "${NC}${F[B]}Successfully found binary in system${NC}"
      echo "Location:[${VALIDATE_INSTALL_CMD}]"
    fi
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  #######################
  # Create flag to skip #
  #######################
  SKIP_FLAG=0

  ######################################################
  # Only go into ansible linter if we have base folder #
  ######################################################
  if [ -d "${ANSIBLE_DIRECTORY}" ]; then

    #################################
    # Get list of all files to lint #
    #################################
    mapfile -t LIST_FILES < <(ls "${ANSIBLE_DIRECTORY}"/*.{yaml,yml} 2>&1)

    ###############################################################
    # Set the list to empty if only MD and TXT files were changed #
    ###############################################################
    # No need to run the full ansible checks on read only file changes
    if [ "${READ_ONLY_CHANGE_FLAG}" -eq 0 ]; then
      ##########################
      # Set the array to empty #
      ##########################
      LIST_FILES=()
      ###################################
      # Send message that were skipping #
      ###################################
      #echo "- Skipping Ansible lint run as file(s) that were modified were read only..."
      ############################
      # Create flag to skip loop #
      ############################
      SKIP_FLAG=1
    fi

    ####################################
    # Check if we have data to look at #
    ####################################
    if [ ${SKIP_FLAG} -eq 0 ]; then
      for LINE in "${PRINT_ARRAY[@]}"; do
        #########################
        # Print the header line #
        #########################
        echo "${LINE}"
      done
    fi

    ########################################
    # Prepare context if TAP output format #
    ########################################
    if IsTAP ; then
      TMPFILE=$(mktemp -q "/tmp/super-linter-${FILE_TYPE}.XXXXXX")
      INDEX=0
      mkdir -p "${REPORT_OUTPUT_FOLDER}"
      REPORT_OUTPUT_FILE="${REPORT_OUTPUT_FOLDER}/super-linter-${FILE_TYPE}.${OUTPUT_FORMAT}"
    fi

    ##################
    # Lint the files #
    ##################
    for FILE in "${LIST_FILES[@]}"; do

      ########################################
      # Make sure we dont lint certain files #
      ########################################
      if [[ ${FILE} == *"vault.yml"* ]] || [[ ${FILE} == *"galaxy.yml"* ]]; then
        # This is a file we dont look at
        continue
      fi

      ##################################
      # Increase the linted file index #
      ##################################
      (("INDEX++"))

      ####################
      # Get the filename #
      ####################
      FILE_NAME=$(basename "${ANSIBLE_DIRECTORY}/${FILE}" 2>&1)

      ##############
      # File print #
      ##############
      echo "---------------------------"
      echo "File:[${FILE}]"

      ################################
      # Lint the file with the rules #
      ################################
      LINT_CMD=$("${LINTER_NAME}" -v -c "${ANSIBLE_LINTER_RULES}" "${ANSIBLE_DIRECTORY}/${FILE}" 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ ${ERROR_CODE} -ne 0 ]; then
        #########
        # Error #
        #########
        echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Found errors in [${LINTER_NAME}] linter!${NC}"
        echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[${LINT_CMD}]${NC}"
        # Increment error count
        ((ERRORS_FOUND_ANSIBLE++))

        #######################################################
        # Store the linting as a temporary file in TAP format #
        #######################################################
        if IsTAP ; then
          NotOkTap "${INDEX}" "${FILE}" "${TMPFILE}"
          AddDetailedMessageIfEnabled "${LINT_CMD}" "${TMPFILE}"
        fi

      else
        ###########
        # Success #
        ###########
        echo -e "${NC}${F[B]} - File:${F[W]}[${FILE_NAME}]${F[B]} was linted with ${F[W]}[${LINTER_NAME}]${F[B]} successfully${NC}"

        #######################################################
        # Store the linting as a temporary file in TAP format #
        #######################################################
        if IsTAP ; then
          OkTap "${INDEX}" "${FILE}" "${TMPFILE}"
        fi
      fi
    done

    #################################
    # Generate report in TAP format #
    #################################
    if IsTAP && [ ${INDEX} -gt 0 ] ; then
      HeaderTap "${INDEX}" "${REPORT_OUTPUT_FILE}"
      cat "${TMPFILE}" >> "${REPORT_OUTPUT_FILE}"
    fi
  else # No ansible directory found in path
    ###############################
    # Check to see if debug is on #
    ###############################
    if [[ ${ACTIONS_RUNNER_DEBUG} == "true" ]]; then
      ########################
      # No Ansible dir found #
      ########################
      echo -e "${NC}${F[Y]}WARN!${NC} No Ansible base directory found at:[${ANSIBLE_DIRECTORY}]${NC}"
      echo "skipping ansible lint"
    fi
  fi
}
################################################################################
#### Function IsTap ############################################################
function IsTAP() {
  if [ "${OUTPUT_FORMAT}" == "tap" ] ; then
    return 0
  else
    return 1
  fi
}
################################################################################
#### Function TransformTAPDetails ##############################################
function TransformTAPDetails() {
  DATA=${1}
  if [ -n "${DATA}" ] && [ "${OUTPUT_DETAILS}" == "detailed" ] ; then
    #########################################################
    # Transform new lines to \\n, remove colours and colons #
    #########################################################
    echo "${DATA}" | awk 'BEGIN{RS="\n";ORS="\\n"}1' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | tr ':' ' '
  fi
}
################################################################################
#### Function HeaderTap ########################################################
function HeaderTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"        # File being validated
  OUTPUT_FILE="${2}"  # Output location

  ###################
  # Print the goods #
  ###################
  printf "TAP version 13\n1..%s\n" "${INDEX}" > "${OUTPUT_FILE}"
}
################################################################################
#### Function OkTap ############################################################
function OkTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"      # Location
  FILE="${2}"       # File being validated
  TEMP_FILE="${3}"  # Temp file location

  ###################
  # Print the goods #
  ###################
  echo "ok ${INDEX} - ${FILE}" >> "${TEMP_FILE}"
}
################################################################################
#### Function NotOkTap #########################################################
function NotOkTap() {
  ################
  # Pull in Vars #
  ################
  INDEX="${1}"      # Location
  FILE="${2}"       # File being validated
  TEMP_FILE="${3}"  # Temp file location

  ###################
  # Print the goods #
  ###################
  echo "not ok ${INDEX} - ${FILE}" >> "${TEMP_FILE}"
}
################################################################################
#### Function AddDetailedMessageIfEnabled ######################################
function AddDetailedMessageIfEnabled() {
  ################
  # Pull in Vars #
  ################
  LINT_CMD="${1}"   # Linter command
  TEMP_FILE="${2}"  # Temp file

  ####################
  # Check the return #
  ####################
  DETAILED_MSG=$(TransformTAPDetails "${LINT_CMD}")
  if [ -n "${DETAILED_MSG}" ] ; then
    printf "  ---\n  message: %s\n  ...\n" "${DETAILED_MSG}" >> "${TEMP_FILE}"
  fi
}
