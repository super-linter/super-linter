cd "$GITHUB_WORKSPACE" || exit;#!/bin/bash

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
# Ansible Vars
ANSIBLE_FILE_NAME='.ansible-lint.yml'                               # Name of the file
ANSIBLE_LINTER_RULES="$DEFAULT_RULES_LOCATION/$ANSIBLE_FILE_NAME"   # Path to the coffescript lint rules

###################
# GitHub ENV Vars #
###################
GITHUB_SHA="${GITHUB_SHA}"                # GitHub sha from the commit
GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"  # Github Event Path
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"    # Github Workspace

############
# Counters #
############
ERRORS_FOUND_YML=0      # Count of errors found
ERRORS_FOUND_JSON=0     # Count of errors found
ERRORS_FOUND_XML=0      # Count of errors found
ERRORS_FOUND_MD=0       # Count of errors found
ERRORS_FOUND_BASH=0     # Count of errors found
ERRORS_FOUND_PERL=0     # Count of errors found
ERRORS_FOUND_RUBY=0     # Count of errors found
ERRORS_FOUND_PYTHON=0   # Count of errors found
ERRORS_FOUND_COFFEE=0   # Count of errors found
ERRORS_FOUND_ANSIBLE=0  # Count of errors found

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
    echo "Using Default rules at:[$YAML_LINTER_RULES]"
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
    echo "Using Default rules at:[$MD_LINTER_RULES]"
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
    echo "Using Default rules at:[$PYTHON_LINTER_RULES]"
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
    echo "Using Default rules at:[$RUBY_LINTER_RULES]"
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
    echo "Using Default rules at:[$COFFEE_LINTER_RULES]"
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
    echo "Using Default rules at:[$ANSIBLE_LINTER_RULES]"
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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.json" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f \( -name "*.yml" -or -name "*.yaml" \) 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.xml" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.md" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.sh" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.py" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.pl" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.rb" 2>&1))

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

  #################################
  # Get list of all files to lint #
  #################################
  # shellcheck disable=SC2207
  LIST_FILES=($(cd "$GITHUB_WORKSPACE" || exit; find . -type f -name "*.coffee" 2>&1))

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
    echo "Successfully found:[GITHUB_SHA]"
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERROR! Failed to get [GITHUB_WORKSPACE]!"
    echo "ERROR:[$GITHUB_WORKSPACE]"
    exit 1
  else
    echo "Successfully found:[GITHUB_WORKSPACE]"
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_EVENT_PATH" ]; then
    echo "ERROR! Failed to get [GITHUB_EVENT_PATH]!"
    echo "ERROR:[$GITHUB_EVENT_PATH]"
    exit 1
  else
    echo "Successfully found:[GITHUB_EVENT_PATH]"
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
    echo "Successfully found:[GITHUB_ORG]"
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
    echo "Successfully found:[GITHUB_REPO]"
  fi
}
################################################################################
#### Function LintAnsibleFiles #################################################
LintAnsibleFiles()
{
  ANSIBLE_DIR="$GITHUB_WORKSPACE/ansible" # Ansible directory

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

  ######################################################
  # Only go into ansible linter if we have base folder #
  ######################################################
  if [ -d "$ANSIBLE_DIR" ]; then
    #################################
    # Get list of all files to lint #
    #################################
    # shellcheck disable=SC2164,SC2010,SC2207
    LIST_FILES=($(cd "$ANSIBLE_DIR"; ls -I vault.yml -I galaxy.yml | grep ".yml" 2>&1))

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
      FILE_NAME=$(basename "$ANSIBLE_DIR/$FILE" 2>&1)

      ##############
      # File print #
      ##############
      echo "---------------------------"
      echo "File:[$FILE]"

      ################################
      # Lint the file with the rules #
      ################################
      LINT_CMD=$("$LINTER_NAME" -v -c "$ANSIBLE_LINTER_FILE" "$ANSIBLE_DIR/$FILE" 2>&1)

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
    echo "WARN! No Ansible base directory found at:[$ANSIBLE_DIR]"
    echo "skipping ansible lint"
  fi
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
  echo "ERRORS FOUND in RUBY:[$ERRORS_FOUND_RUBY]"
  echo "ERRORS FOUND in ANSIBLE:[$ERRORS_FOUND_ANSIBLE]"

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
     [ $ERRORS_FOUND_ANSIBLE -ne 0 ] || \
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

######################
# Validate workspace #
######################

######################
# Lint the Yml Files #
######################
LintYmlFiles

#######################
# Lint the json files #
#######################
LintJsonFiles

######################
# Lint the XML Files #
######################
LintXmlFiles

###########################
# Lint the Markdown Files #
###########################
LintMdFiles

#######################
# Lint the bash files #
#######################
LintBashFiles

#########################
# Lint the python files #
#########################
LintPythonFiles

#######################
# Lint the perl files #
#######################
LintPerlFiles

#######################
# Lint the ruby files #
#######################
LintRubyFiles

#########################
# Lint the coffee files #
#########################
LintCoffeeFiles

##########################
# Lint the Ansible files #
##########################
LintAnsibleFiles

##########
# Footer #
##########
Footer
