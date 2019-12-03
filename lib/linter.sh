#!/bin/bash

################################################################################
########### EntryPoint for Super-Linter @AdmiralAwkbar #########################
################################################################################

###########
# GLOBALS #
###########
# Default Vars
DEFAULT_RULES_LOCATION='/action/lib/.automation'                    # Default rules files location
# YAML Vars
YAML_FILE_NAME='.yaml-lint.yml'                                     # Name of the file
YAML_LINTER_RULES="$DEFAULT_RULES_LOCATION/$YAML_FILE_NAME"         # Path to the yaml lint rules
# MD Vars
MD_FILE_NAME='.markdown-lint.yml'                                   # Name of the file
MD_LINTER_RULES="$DEFAULT_RULES_LOCATION/$MD_FILE_NAME"             # Path to the markdown lint rules
# Python Vars
PYTHON_FILE_NAME='.python-lint'                                     # Name of the file
PYTHON_LINTER_RULES="$DEFAULT_RULES_LOCATION/$PYTHON_FILE_NAME"     # Path to the python lint rules
# Ruby Vars
RUBY_FILE_NAME='.ruby-lint.yml'                                     # Name of the file
RUBY_LINTER_RULES="$DEFAULT_RULES_LOCATION/$RUBY_FILE_NAME"         # Path to the ruby lint rules
# Coffee Vars
COFFEE_FILE_NAME='.coffee-lint.json'                                # Name of the file
COFFEE_LINTER_RULES="$DEFAULT_RULES_LOCATION/$COFFEE_FILE_NAME"     # Path to the coffescript lint rules
# Javascript Vars
JAVASCRIPT_FILE_NAME='.eslintrc.yml'                                    # Name of the file
JAVASCRIPT_LINTER_RULES="$DEFAULT_RULES_LOCATION/$JAVASCRIPT_FILE_NAME" # Path to the Javascript lint rules
# Ansible Vars
ANSIBLE_FILE_NAME='.ansible-lint.yml'                               # Name of the file
ANSIBLE_LINTER_RULES="$DEFAULT_RULES_LOCATION/$ANSIBLE_FILE_NAME"   # Path to the coffescript lint rules

###################
# GitHub ENV Vars #
###################
GITHUB_SHA="${GITHUB_SHA}"                        # GitHub sha from the commit
GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"          # Github Event Path
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"            # Github Workspace
ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY}"          # Ansible Directory
VALIDATE_ALL_CODEBASE="${VALIDATE_ALL_CODEBASE}"  # Boolean to validate all files
VALIDATE_YAML="${VALIDATE_YAML}"                  # Boolean to validate language
VALIDATE_JSON="${VALIDATE_JSON}"                  # Boolean to validate language
VALIDATE_XML="${VALIDATE_XML}"                    # Boolean to validate language
VALIDATE_MD="${VALIDATE_MD}"                      # Boolean to validate language
VALIDATE_BASH="${VALIDATE_BASH}"                  # Boolean to validate language
VALIDATE_PERL="${VALIDATE_PERL}"                  # Boolean to validate language
VALIDATE_PYTHON="${VALIDATE_PYTHON}"              # Boolean to validate language
VALIDATE_RUBY="${VALIDATE_RUBY}"                  # Boolean to validate language
VALIDATE_COFFEE="${VALIDATE_COFFEE}"              # Boolean to validate language
VALIDATE_ANSIBLE="${VALIDATE_ANSIBLE}"            # Boolean to validate language
VALIDATE_JAVASCRIPT="${VALIDATE_JAVASCRIPT}"      # Boolean to validate language

################
# Default Vars #
################
DEFAULT_VALIDATE_ALL_CODEBASE='true'                  # Default value for validate all files
DEFAULT_VALIDATE_LANGUAGE='true'                      # Default to validate language
DEFAULT_ANSIBLE_DIRECTORY="$GITHUB_WORKSPACE/ansible" # Default Ansible Directory
RAW_FILE_ARRAY=()                                     # Array of all files that were changed

##########################
# Array of changed files #
##########################
FILE_ARRAY_YML=()         # Array of files to check
FILE_ARRAY_JSON=()        # Array of files to check
FILE_ARRAY_XML=()         # Array of files to check
FILE_ARRAY_MD=()          # Array of files to check
FILE_ARRAY_BASH=()        # Array of files to check
FILE_ARRAY_PERL=()        # Array of files to check
FILE_ARRAY_RUBY=()        # Array of files to check
FILE_ARRAY_PYTHON=()      # Array of files to check
FILE_ARRAY_COFFEE=()      # Array of files to check
FILE_ARRAY_JAVASCRIPT=()  # Array of files to check

############
# Counters #
############
ERRORS_FOUND_YML=0          # Count of errors found
ERRORS_FOUND_JSON=0         # Count of errors found
ERRORS_FOUND_XML=0          # Count of errors found
ERRORS_FOUND_MD=0           # Count of errors found
ERRORS_FOUND_BASH=0         # Count of errors found
ERRORS_FOUND_PERL=0         # Count of errors found
ERRORS_FOUND_RUBY=0         # Count of errors found
ERRORS_FOUND_PYTHON=0       # Count of errors found
ERRORS_FOUND_COFFEE=0       # Count of errors found
ERRORS_FOUND_ANSIBLE=0      # Count of errors found
ERRORS_FOUND_JAVASCRIPT=0   # Count of errors found

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "---------------------------------------------"
  echo "------ Github Actions Language Linter -------"
  echo "---------------------------------------------"
  echo ""
}
################################################################################
#### Function GetLinterRules ###################################################
GetLinterRules()
{
  # Need to validate the rules files exist
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Gathering Linter rules from repository, or defaulting..."
  echo ""

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$YAML_FILE_NAME" ]; then
    echo "User provided file:[$YAML_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$YAML_FILE_NAME" "$YAML_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$YAML_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$YAML_FILE_NAME], using Default rules at:[$YAML_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$MD_FILE_NAME" ]; then
    echo "User provided file:[$MD_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$MD_FILE_NAME" "$MD_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$MD_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$MD_FILE_NAME], using Default rules at:[$MD_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$PYTHON_FILE_NAME" ]; then
    echo "User provided file:[$PYTHON_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$PYTHON_FILE_NAME" "$PYTHON_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$PYTHON_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$PYTHON_FILE_NAME], using Default rules at:[$PYTHON_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$RUBY_FILE_NAME" ]; then
    echo "User provided file:[$RUBY_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$RUBY_FILE_NAME" "$RUBY_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$RUBY_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$RUBY_FILE_NAME], using Default rules at:[$RUBY_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$COFFEE_FILE_NAME" ]; then
    echo "User provided file:[$COFFEE_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$COFFEE_FILE_NAME" "$COFFEE_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$COFFEE_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$COFFEE_FILE_NAME], using Default rules at:[$COFFEE_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$ANSIBLE_FILE_NAME" ]; then
    echo "User provided file:[$ANSIBLE_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$ANSIBLE_FILE_NAME" "$ANSIBLE_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$ANSIBLE_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$ANSIBLE_FILE_NAME], using Default rules at:[$ANSIBLE_LINTER_RULES]"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "$GITHUB_WORKSPACE/.github/linters/$JAVASCRIPT_FILE_NAME" ]; then
    echo "User provided file:[$JAVASCRIPT_FILE_NAME], setting rules file..."

    ####################################
    # Move users into default location #
    ####################################
    MV_CMD=$(mv "$GITHUB_WORKSPACE/.github/linters/$JAVASCRIPT_FILE_NAME" "$JAVASCRIPT_LINTER_RULES" 2>&1)

    ###################
    # Load Error code #
    ###################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to set file:[$JAVASCRIPT_FILE_NAME] as default!"
      echo "ERROR:[$MV_CMD]"
      exit 1
    fi
  else
    echo "Codebase does not have file:[.github/linters/$JAVASCRIPT_FILE_NAME], using Default rules at:[$JAVASCRIPT_LINTER_RULES]"
  fi
}
################################################################################
#### Function LintJsonFiles ####################################################
LintJsonFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting JSON files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="jsonlint"

  #######################################
  # Validate we have yamllint installed #
  #######################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find [$LINTER_NAME] in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_JSON[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[JSON]"
  elif [ ${#FILE_ARRAY_JSON[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_JSON[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.json" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do
    #####################
    # Get the file name #
    #####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    if [[ $FILE == *"node_modules"* ]]; then
      # This is a node modules file
      continue
    fi

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_JSON++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintYmlFiles #####################################################
LintYmlFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting YAML files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="yamllint"

  #######################################
  # Validate we have yamllint installed #
  #######################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find [$LINTER_NAME] in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_YML[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[YML]"
  elif [ ${#FILE_ARRAY_YML[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_YML[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f \( -name "*.yml" -or -name "*.yaml" \) 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do
    #####################
    # Get the file name #
    #####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" "$YAML_LINTER_RULES" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_YML++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintXmlFiles #####################################################
LintXmlFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting XML files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="xmllint"

  #######################################
  # Validate we have yamllint installed #
  #######################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find [$LINTER_NAME] in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_XML[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[XML]"
  elif [ ${#FILE_ARRAY_XML[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_XML[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.xml" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do
    #####################
    # Get the file name #
    #####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_XML++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintMdFiles ######################################################
LintMdFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Markdown files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="markdownlint"

  #######################################
  # Validate we have yamllint installed #
  #######################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find [$LINTER_NAME] in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_MD[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[MARKDOWN]"
  elif [ ${#FILE_ARRAY_MD[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_MD[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.md" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do
    #####################
    # Get the file name #
    #####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" -c "$MD_LINTER_RULES" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_MD++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintBashFiles ####################################################
LintBashFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Bash files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="shellcheck"

  #########################################
  # Validate we have shellcheck installed #
  #########################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_BASH[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[BASH]"
  elif [ ${#FILE_ARRAY_BASH[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_BASH[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.sh" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_BASH++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintPythonFiles ##################################################
LintPythonFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Python files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="pylint"

  #####################################
  # Validate we have pylint installed #
  #####################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_PYTHON[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[PYTHON]"
  elif [ ${#FILE_ARRAY_PYTHON[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_PYTHON[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.py" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" --rcfile "$PYTHON_LINTER_RULES" -E "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_PYTHON++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintPerlFiles ####################################################
LintPerlFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Perl files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="perl"

  ###################################
  # Validate we have perl installed #
  ###################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_PERL[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[PERL]"
  elif [ ${#FILE_ARRAY_PERL[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_PERL[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.pl" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" -Mstrict -cw "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_PERL++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintRubyFiles ####################################################
LintRubyFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Ruby files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="rubocop"

  ###################################
  # Validate we have perl installed #
  ###################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_RUBY[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[RUBY]"
  elif [ ${#FILE_ARRAY_RUBY[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_RUBY[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.rb" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" -c "$RUBY_LINTER_RULES" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_RUBY++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintCoffeeFiles ##################################################
LintCoffeeFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Coffee files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="coffeelint"

  #####################################
  # Validate we have pylint installed #
  #####################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_COFFEE[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[COFFEE]"
  elif [ ${#FILE_ARRAY_COFFEE[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_COFFEE[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.coffee" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    # if [[ $FILE == *"node_modules"* ]]; then
    #   # This is a node modules file
    #   continue
    # fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    ################################
    # Lint the file with the rules #
    ################################
    LINT_CMD=$("$LINTER_NAME" -f "$COFFEE_LINTER_RULES" "$FILE" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      #########
      # Error #
      #########
      echo "ERROR! Found errors in [$LINTER_NAME] linter!"
      echo "ERROR:[$LINT_CMD]"
      # Increment error count
      ((ERRORS_FOUND_COFFEE++))
    else
      ###########
      # Success #
      ###########
      echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
    fi
  done
}
################################################################################
#### Function LintJavascriptFiles ##############################################
LintJavascriptFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting JavaScript files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="eslint"

  #####################################
  # Validate we have pylint installed #
  #####################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ############################################################
  # Check to see if we need to go through array or all files #
  ############################################################
  if [ ${#FILE_ARRAY_JAVASCRIPT[@]} -eq 0 ] && [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
    # No files found in commit and user has asked to not validate code base
    echo " - No files found in chageset to lint for language:[JAVASCRIPT]"
  elif [ ${#FILE_ARRAY_JAVASCRIPT[@]} -ne 0 ]; then
    # We have files added to array of files to check
    LIST_FILES=("${FILE_ARRAY_JAVASCRIPT[@]}") # Copy the array into list
  else
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2207
    LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.js" 2>&1))
  fi

  ##################
  # Lint the files #
  ##################
  for FILE in "${LIST_FILES[@]}"
  do

    #######################################
    # Make sure we dont lint node modules #
    #######################################
    if [[ $FILE == *"node_modules"* ]]; then
      # This is a node modules file
      continue
    fi

    ####################
    # Get the filename #
    ####################
    FILE_NAME=$(basename "$FILE" 2>&1)

    ##############
    # File print #
    ##############
    echo "---------------------------"
    echo "File:[$FILE]"

    #############################
    # Lint the file with ESLint #
    #############################
    Eslint "$FILE"

    ###############################
    # Lint the file with Standard #
    ###############################
    StandardLint "$FILE"

  done
}
################################################################################
#### Function Eslint ###########################################################
Eslint()
{
  ####################
  # Pull in the file #
  ####################
  FILE=$1

  #####################
  # Get the file name #
  #####################
  FILE_NAME=$(basename "$FILE" 2>&1)

  ################################
  # Lint the file with the rules #
  ################################
  LINT_CMD=$(eslint -c "$JAVASCRIPT_LINTER_RULES" "$FILE" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    #########
    # Error #
    #########
    echo "ERROR! Found errors in [eslint] linter!"
    echo "ERROR:[$LINT_CMD]"
    # Increment error count
    ((ERRORS_FOUND_JAVASCRIPT++))
  else
    ###########
    # Success #
    ###########
    echo " - File:[$FILE_NAME] was linted with [eslint] successfully"
  fi
}
################################################################################
#### Function StandardLint #####################################################
StandardLint()
{
  ####################
  # Pull in the file #
  ####################
  FILE=$1

  #####################
  # Get the file name #
  #####################
  FILE_NAME=$(basename "$FILE" 2>&1)

  ################################
  # Lint the file with the rules #
  ################################
  STANDARD_LINT_CMD=$(standard "$FILE" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    #########
    # Error #
    #########
    echo "ERROR! Found errors in [js standard] linter!"
    echo "ERROR:[$STANDARD_LINT_CMD]"
    # Increment error count
    ((ERRORS_FOUND_JAVASCRIPT++))
  else
    ###########
    # Success #
    ###########
    echo " - File:[$FILE_NAME] was linted with [js standard] successfully"
  fi
}
################################################################################
#### Function LintAnsibleFiles #################################################
LintAnsibleFiles()
{
  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Linting Ansible files..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Name of the linter #
  ######################
  LINTER_NAME="ansible-lint"

  ###########################################
  # Validate we have ansible-lint installed #
  ###########################################
  # shellcheck disable=SC2230
  VALIDATE_INSTALL_CMD=$(command -v "$LINTER_NAME" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Failed
    echo "ERROR! Failed to find $LINTER_NAME in system!"
    echo "ERROR:[$VALIDATE_INSTALL_CMD]"
    exit 1
  else
    # Success
    echo "Successfully found binary in system"
    echo "Location:[$VALIDATE_INSTALL_CMD]"
  fi

  ##########################
  # Initialize empty Array #
  ##########################
  LIST_FILES=()

  ######################################################
  # Only go into ansible linter if we have base folder #
  ######################################################
  if [ -d "$ANSIBLE_DIRECTORY" ]; then

    ############################################################
    # Check to see if we need to go through array or all files #
    ############################################################
    if [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
      # We need to only check the ansible playbooks that have updates
      #LIST_FILES=("${ANSIBLE_ARRAY[@]}")
      # shellcheck disable=SC2164,SC2010,SC2207
      LIST_FILES=($(cd "$ANSIBLE_DIRECTORY"; ls | grep ".yml" 2>&1))
    else
      #################################
      # Get list of all files to lint #
      #################################
      # shellcheck disable=SC2164,SC2010,SC2207
      LIST_FILES=($(cd "$ANSIBLE_DIRECTORY"; ls | grep ".yml" 2>&1))
    fi

    ##################
    # Lint the files #
    ##################
    for FILE in "${LIST_FILES[@]}"
    do

      ########################################
      # Make sure we dont lint certain files #
      ########################################
      if [[ $FILE == *"vault.yml"* ]] || [[ $FILE == *"galaxy.yml"* ]]; then
        # This is a file we dont look at
        continue
      fi

      ####################
      # Get the filename #
      ####################
      FILE_NAME=$(basename "$ANSIBLE_DIRECTORY/$FILE" 2>&1)

      ##############
      # File print #
      ##############
      echo "---------------------------"
      echo "File:[$FILE]"

      ################################
      # Lint the file with the rules #
      ################################
      LINT_CMD=$("$LINTER_NAME" -v -c "$ANSIBLE_LINTER_RULES" "$ANSIBLE_DIRECTORY/$FILE" 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      ##############################
      # Check the shell for errors #
      ##############################
      if [ $ERROR_CODE -ne 0 ]; then
        #########
        # Error #
        #########
        echo "ERROR! Found errors in [$LINTER_NAME] linter!"
        echo "ERROR:[$LINT_CMD]"
        # Increment error count
        ((ERRORS_FOUND_ANSIBLE++))
      else
        ###########
        # Success #
        ###########
        echo " - File:[$FILE_NAME] was linted with [$LINTER_NAME] successfully"
      fi
    done
  else
    ########################
    # No Ansible dir found #
    ########################
    echo "WARN! No Ansible base directory found at:[$ANSIBLE_DIRECTORY]"
    echo "skipping ansible lint"
  fi
}
################################################################################
#### Function GetGitHubVars ####################################################
GetGitHubVars()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Gathering GitHub information..."

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_SHA" ]; then
    echo "ERROR! Failed to get [GITHUB_SHA]!"
    echo "ERROR:[$GITHUB_SHA]"
    exit 1
  else
    echo "Successfully found:[GITHUB_SHA], value:[$GITHUB_SHA]"
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERROR! Failed to get [GITHUB_WORKSPACE]!"
    echo "ERROR:[$GITHUB_WORKSPACE]"
    exit 1
  else
    echo "Successfully found:[GITHUB_WORKSPACE], value:[$GITHUB_WORKSPACE]"
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_EVENT_PATH" ]; then
    echo "ERROR! Failed to get [GITHUB_EVENT_PATH]!"
    echo "ERROR:[$GITHUB_EVENT_PATH]"
    exit 1
  else
    echo "Successfully found:[GITHUB_EVENT_PATH], value:[$GITHUB_EVENT_PATH]"
  fi

  ##################################################
  # Need to pull the GitHub Vars from the env file #
  ##################################################

  ######################
  # Get the GitHub Org #
  ######################
  # shellcheck disable=SC2002
  GITHUB_ORG=$(cat "$GITHUB_EVENT_PATH" | jq -r '.repository.owner.login' )

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_ORG" ]; then
    echo "ERROR! Failed to get [GITHUB_ORG]!"
    echo "ERROR:[$GITHUB_ORG]"
    exit 1
  else
    echo "Successfully found:[GITHUB_ORG], value:[$GITHUB_ORG]"
  fi

  #######################
  # Get the GitHub Repo #
  #######################
  # shellcheck disable=SC2002
  GITHUB_REPO=$(cat "$GITHUB_EVENT_PATH"| jq -r '.repository.name' )

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_REPO" ]; then
    echo "ERROR! Failed to get [GITHUB_REPO]!"
    echo "ERROR:[$GITHUB_REPO]"
    exit 1
  else
    echo "Successfully found:[GITHUB_REPO], value:[$GITHUB_REPO]"
  fi

  ############################################
  # Print headers for user provided env vars #
  ############################################
  echo ""
  echo "--------------------------------------------"
  echo "Gathering User provided information..."

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_ALL_CODEBASE=$(echo "$VALIDATE_ALL_CODEBASE" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_ALL_CODEBASE" != "false" ]]; then
    # Set to true
    VALIDATE_ALL_CODEBASE="$DEFAULT_VALIDATE_ALL_CODEBASE"
    echo "- Validating ALL files in code base..."
  else
    # Its false
    echo "- Only validating [new], or [edited] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_YAML=$(echo "$VALIDATE_YAML" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_YAML" != "false" ]]; then
    # Set to true
    VALIDATE_YAML="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [YML] files in code base..."
  else
    # Its false
    echo "- Excluding [YML] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_JSON=$(echo "$VALIDATE_JSON" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_JSON" != "false" ]]; then
    # Set to true
    VALIDATE_JSON="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [JSON] files in code base..."
  else
    # Its false
    echo "- Excluding [JSON] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_XML=$(echo "$VALIDATE_XML" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_XML" != "false" ]]; then
    # Set to true
    VALIDATE_XML="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [XML] files in code base..."
  else
    # Its false
    echo "- Excluding [XML] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_MD=$(echo "$VALIDATE_MD" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_MD" != "false" ]]; then
    # Set to true
    VALIDATE_MD="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [MARKDOWN] files in code base..."
  else
    # Its false
    echo "- Excluding [MARKDOWN] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_BASH=$(echo "$VALIDATE_BASH" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_BASH" != "false" ]]; then
    # Set to true
    VALIDATE_BASH="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [BASH] files in code base..."
  else
    # Its false
    echo "- Excluding [BASH] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_PERL=$(echo "$VALIDATE_PERL" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_PERL" != "false" ]]; then
    # Set to true
    VALIDATE_PERL="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [PERL] files in code base..."
  else
    # Its false
    echo "- Excluding [PERL] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_PYTHON=$(echo "$VALIDATE_PYTHON" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_PYTHON" != "false" ]]; then
    # Set to true
    VALIDATE_PYTHON="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [PYTHON] files in code base..."
  else
    # Its false
    echo "- Excluding [PYTHON] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_RUBY=$(echo "$VALIDATE_RUBY" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_RUBY" != "false" ]]; then
    # Set to true
    VALIDATE_RUBY="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [RUBY] files in code base..."
  else
    # Its false
    echo "- Excluding [RUBY] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_COFFEE=$(echo "$VALIDATE_COFFEE" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_COFFEE" != "false" ]]; then
    # Set to true
    VALIDATE_COFFEE="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [COFFEE] files in code base..."
  else
    # Its false
    echo "- Excluding [COFFEE] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_ANSIBLE=$(echo "$VALIDATE_ANSIBLE" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_ANSIBLE" != "false" ]]; then
    # Set to true
    VALIDATE_ANSIBLE="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [ANSIBLE] files in code base..."
  else
    # Its false
    echo "- Excluding [ANSIBLE] files in code base..."
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  VALIDATE_JAVASCRIPT=$(echo "$VALIDATE_JAVASCRIPT" | awk '{print tolower($0)}')
  ######################################
  # Validate we should check all files #
  ######################################
  if [[ "$VALIDATE_JAVASCRIPT" != "false" ]]; then
    # Set to true
    VALIDATE_JAVASCRIPT="$DEFAULT_VALIDATE_LANGUAGE"
    echo "- Validating [JAVASCRIPT] files in code base..."
  else
    # Its false
    echo "- Excluding [JAVASCRIPT] files in code base..."
  fi

  ##############################
  # Validate Ansible Directory #
  ##############################
  if [ -z "$ANSIBLE_DIRECTORY" ]; then
    # No Value, need to default
    ANSIBLE_DIRECTORY="$DEFAULT_ANSIBLE_DIRECTORY"
  else
    # Check if first char is '/'
    if [[ ${ANSIBLE_DIRECTORY:0:1} == "/" ]]; then
      # Remove first char
      ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY:1}"
    fi
    # Need to give it full path
    TEMP_ANSIBLE_DIRECTORY="$GITHUB_WORKSPACE/$ANSIBLE_DIRECTORY"
    # Set the value
    ANSIBLE_DIRECTORY="$TEMP_ANSIBLE_DIRECTORY"
  fi
}
################################################################################
#### Function BuildFileList ####################################################
BuildFileList()
{
  # Need to build a list of all files changed
  # This can be pulled from the GITHUB_EVENT_PATH payload

  ################
  # print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Gathering list of files edited, or added in the commit..."

  #####################################################################
  # Switch codebase back to master to get a list of all files changed #
  #####################################################################
  SWITCH_CMD=$(cd "$GITHUB_WORKSPACE" || exit; git pull; git checkout master 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "Failed to switch to master branch to get files changed!"
    echo "ERROR:[$SWITCH_CMD]"
    exit 1
  fi

  #########
  # Print #
  #########
  echo "Generating Diff with:[git diff --name-only 'master..$GITHUB_SHA' --diff-filter=d]"

  ################################################
  # Get the Array of files changed in the comits #
  ################################################
  # shellcheck disable=SC2207
  RAW_FILE_ARRAY=($(cd "$GITHUB_WORKSPACE" || exit; git diff --name-only "master..$GITHUB_SHA" --diff-filter=d 2>&1))

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "ERROR! Failed to gain a list of all files changed!"
    echo "ERROR:[${RAW_FILE_ARRAY[*]}]"
    exit 1
  fi

  #################################################
  # Itterate through the array of all files found #
  #################################################
  echo "Files that have been modified in the commit(s):"
  for FILE in "${RAW_FILE_ARRAY[@]}"
  do
    ##############
    # Print file #
    ##############
    echo "File:[$FILE]"

    ###########################
    # Get the files extension #
    ###########################
    # Extract just the file and extension, reverse it, cut off extension,
    # reverse it back, substitute to lowercase
    FILE_TYPE=$(basename "$FILE" | rev | cut -f1 -d'.' | rev | awk '{print tolower($0)}')

    #########
    # DEBUG #
    #########
    #echo "FILE_TYPE:[$FILE_TYPE]"

    #####################
    # Get the YML files #
    #####################
    if [ "$FILE_TYPE" == "yml" ] || [ "$FILE_TYPE" == "yaml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_YML+=("$FILE")
    ######################
    # Get the JSON files #
    ######################
    elif [ "$FILE_TYPE" == "json" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JSON+=("$FILE")
    #####################
    # Get the XML files #
    #####################
    elif [ "$FILE_TYPE" == "xml" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_XML+=("$FILE")
    ##########################
    # Get the MARKDOWN files #
    ##########################
    elif [ "$FILE_TYPE" == "md" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_MD+=("$FILE")
    ######################
    # Get the BASH files #
    ######################
    elif [ "$FILE_TYPE" == "sh" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_BASH+=("$FILE")
    ######################
    # Get the PERL files #
    ######################
    elif [ "$FILE_TYPE" == "pl" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PERL+=("$FILE")
    ######################
    # Get the RUBY files #
    ######################
    elif [ "$FILE_TYPE" == "rb" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_RUBY+=("$FILE")
    ########################
    # Get the PYTHON files #
    ########################
    elif [ "$FILE_TYPE" == "py" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_PYTHON+=("$FILE")
    ########################
    # Get the COFFEE files #
    ########################
    elif [ "$FILE_TYPE" == "coffee" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_COFFEE+=("$FILE")
    ########################
    # Get the COFFEE files #
    ########################
    elif [ "$FILE_TYPE" == "js" ]; then
      ################################
      # Append the file to the array #
      ################################
      FILE_ARRAY_JAVASCRIPT+=("$FILE")
    else
      ############################
      # Extension was not found! #
      ############################
      echo "WARN! Failed to get file type for:[$FILE]!"
    fi
  done

  #########################################
  # Need to switch back to branch of code #
  #########################################
  SWITCH2_CMD=$(cd "$GITHUB_WORKSPACE" || exit; git checkout --progress --force "$GITHUB_SHA" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "Failed to switch back to branch!"
    echo "ERROR:[$SWITCH2_CMD]"
    exit 1
  fi

  ################
  # Footer print #
  ################
  echo "Successfully gathered list of files..."
}
################################################################################
#### Function Footer ###########################################################
Footer()
{
  echo ""
  echo "---------------------------"
  echo "The script has completed"
  echo "---------------------------"
  echo "ERRORS FOUND in YAML:[$ERRORS_FOUND_YML]"
  echo "ERRORS FOUND in JSON:[$ERRORS_FOUND_JSON]"
  echo "ERRORS FOUND in XML:[$ERRORS_FOUND_XML]"
  echo "ERRORS FOUND IN MD:[$ERRORS_FOUND_MD]"
  echo "ERRORS FOUND in BASH:[$ERRORS_FOUND_BASH]"
  echo "ERRORS FOUND in PERL:[$ERRORS_FOUND_PERL]"
  echo "ERRORS FOUND in PYTHON:[$ERRORS_FOUND_PYTHON]"
  echo "ERRORS FOUND in COFFEE:[$ERRORS_FOUND_COFFEE]"
  echo "ERRORS FOUND in RUBY:[$ERRORS_FOUND_RUBY]"
  echo "ERRORS FOUND in ANSIBLE:[$ERRORS_FOUND_ANSIBLE]"
  echo "ERRORS FOUND in JAVASCRIPT:[$ERRORS_FOUND_JAVASCRIPT]"

  echo ""

  ###############################
  # Exit with 1 if errors found #
  ###############################
  if [ $ERRORS_FOUND_YML -ne 0 ] || \
     [ $ERRORS_FOUND_JSON -ne 0 ] || \
     [ $ERRORS_FOUND_XML -ne 0 ] || \
     [ $ERRORS_FOUND_MD -ne 0 ] || \
     [ $ERRORS_FOUND_BASH -ne 0 ] || \
     [ $ERRORS_FOUND_PERL -ne 0 ] || \
     [ $ERRORS_FOUND_PYTHON -ne 0 ] || \
     [ $ERRORS_FOUND_COFFEE -ne 0 ] || \
     [ $ERRORS_FOUND_ANSIBLE -ne 0 ] || \
     [ $ERRORS_FOUND_JAVASCRIPT -ne 0 ] || \
     [ $ERRORS_FOUND_RUBY -ne 0 ]; then
    # Failed exit
    echo "Exiting with errors found!"
    exit 1
  else
    # Successful exit
    exit 0
  fi
}
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

#######################
# Get Github Env Vars #
#######################
# Need to pull in all the Github variables
# needed to connect back and update checks
GetGitHubVars

########################
# Get the linter rules #
########################
GetLinterRules

########################################
# Get list of files changed if env set #
########################################
if [ "$VALIDATE_ALL_CODEBASE" == "false" ]; then
  BuildFileList
fi

######################
# Lint the Yml Files #
######################
if [ "$VALIDATE_YAML" == "true" ]; then
  LintYmlFiles
fi

#######################
# Lint the json files #
#######################
if [ "$VALIDATE_JSON" == "true" ]; then
  LintJsonFiles
fi

######################
# Lint the XML Files #
######################
if [ "$VALIDATE_XML" == "true" ]; then
  LintXmlFiles
fi

###########################
# Lint the Markdown Files #
###########################
if [ "$VALIDATE_MD" == "true" ]; then
  LintMdFiles
fi

#######################
# Lint the bash files #
#######################
if [ "$VALIDATE_BASH" == "true" ]; then
  LintBashFiles
fi

#########################
# Lint the python files #
#########################
if [ "$VALIDATE_PYTHON" == "true" ]; then
  LintPythonFiles
fi

#######################
# Lint the perl files #
#######################
if [ "$VALIDATE_PERL" == "true" ]; then
  LintPerlFiles
fi

#######################
# Lint the ruby files #
#######################
if [ "$VALIDATE_RUBY" == "true" ]; then
  LintRubyFiles
fi

#########################
# Lint the coffee files #
#########################
if [ "$VALIDATE_COFFEE" == "true" ]; then
  LintCoffeeFiles
fi

##########################
# Lint the Ansible files #
##########################
if [ "$VALIDATE_ANSIBLE" == "true" ]; then
  LintAnsibleFiles
fi

#############################
# Lint the Javascript files #
#############################
if [ "$VALIDATE_JAVASCRIPT" == "true" ]; then
  LintJavascriptFiles
fi


##########
# Footer #
##########
Footer
