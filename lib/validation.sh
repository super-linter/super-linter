#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter Validation Functions @admiralawkbar ###################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function GetValidationInfo ################################################
function GetValidationInfo() {
  ############################################
  # Print headers for user provided env vars #
  ############################################
  echo ""
  echo "--------------------------------------------"
  echo "Gathering user validation information..."

  ###########################################
  # Skip validation if were running locally #
  ###########################################
  if [[ $RUN_LOCAL != "true" ]]; then
    ###############################
    # Convert string to lowercase #
    ###############################
    VALIDATE_ALL_CODEBASE=$(echo "$VALIDATE_ALL_CODEBASE" | awk '{print tolower($0)}')
    ######################################
    # Validate we should check all files #
    ######################################
    if [[ $VALIDATE_ALL_CODEBASE != "false" ]]; then
      # Set to true
      VALIDATE_ALL_CODEBASE="$DEFAULT_VALIDATE_ALL_CODEBASE"
      echo "- Validating ALL files in code base..."
    else
      # Its false
      echo "- Only validating [new], or [edited] files in code base..."
    fi
  fi

  ######################
  # Create Print Array #
  ######################
  PRINT_ARRAY=()

  ################################
  # Convert strings to lowercase #
  ################################
  VALIDATE_YAML=$(echo "$VALIDATE_YAML" | awk '{print tolower($0)}')
  VALIDATE_JSON=$(echo "$VALIDATE_JSON" | awk '{print tolower($0)}')
  VALIDATE_XML=$(echo "$VALIDATE_XML" | awk '{print tolower($0)}')
  VALIDATE_MD=$(echo "$VALIDATE_MD" | awk '{print tolower($0)}')
  VALIDATE_BASH=$(echo "$VALIDATE_BASH" | awk '{print tolower($0)}')
  VALIDATE_PERL=$(echo "$VALIDATE_PERL" | awk '{print tolower($0)}')
  VALIDATE_PHP=$(echo "$VALIDATE_PHP" | awk '{print tolower($0)}')
  VALIDATE_PYTHON=$(echo "$VALIDATE_PYTHON" | awk '{print tolower($0)}')
  VALIDATE_RUBY=$(echo "$VALIDATE_RUBY" | awk '{print tolower($0)}')
  VALIDATE_COFFEE=$(echo "$VALIDATE_COFFEE" | awk '{print tolower($0)}')
  VALIDATE_ANSIBLE=$(echo "$VALIDATE_ANSIBLE" | awk '{print tolower($0)}')
  VALIDATE_JAVASCRIPT_ES=$(echo "$VALIDATE_JAVASCRIPT_ES" | awk '{print tolower($0)}')
  VALIDATE_JAVASCRIPT_STANDARD=$(echo "$VALIDATE_JAVASCRIPT_STANDARD" | awk '{print tolower($0)}')
  VALIDATE_TYPESCRIPT_ES=$(echo "$VALIDATE_TYPESCRIPT_ES" | awk '{print tolower($0)}')
  VALIDATE_TYPESCRIPT_STANDARD=$(echo "$VALIDATE_TYPESCRIPT_STANDARD" | awk '{print tolower($0)}')
  VALIDATE_DOCKER=$(echo "$VALIDATE_DOCKER" | awk '{print tolower($0)}')
  VALIDATE_GO=$(echo "$VALIDATE_GO" | awk '{print tolower($0)}')
  VALIDATE_TERRAFORM=$(echo "$VALIDATE_TERRAFORM" | awk '{print tolower($0)}')
  VALIDATE_POWERSHELL=$(echo "$VALIDATE_POWERSHELL" | awk '{print tolower($0)}')
  VALIDATE_ARM=$(echo "$VALIDATE_ARM" | awk '{print tolower($0)}')
  VALIDATE_CSS=$(echo "$VALIDATE_CSS" | awk '{print tolower($0)}')
  VALIDATE_ENV=$(echo "$VALIDATE_ENV" | awk '{print tolower($0)}')
  VALIDATE_CLOJURE=$(echo "$VALIDATE_CLOJURE" | awk '{print tolower($0)}')
  VALIDATE_KOTLIN=$(echo "$VALIDATE_KOTLIN" | awk '{print tolower($0)}')
  VALIDATE_PROTOBUF=$(echo "$VALIDATE_PROTOBUF" | awk '{print tolower($0)}')
  VALIDATE_OPENAPI=$(echo "$VALIDATE_OPENAPI" | awk '{print tolower($0)}')
  VALIDATE_EDITORCONFIG=$(echo "$VALIDATE_EDITORCONFIG" | awk '{print tolower($0)}')
  VALIDATE_HTML=$(echo "$VALIDATE_HTML" | awk '{print tolower($0)}')

  #############################
  # Editorconfig special case #
  #############################
  LINTER_RULES_PATH="${LINTER_RULES_PATH:-.github/linters}"               # Linter Path Directory
  EDITORCONFIG_FILE_NAME='.editorconfig'

  ################################################
  # Determine if any linters were explicitly set #
  ################################################
  ANY_SET="false"
  if [[ -n $VALIDATE_YAML || -n \
    $VALIDATE_JSON || -n \
    $VALIDATE_XML || -n \
    $VALIDATE_MD || -n \
    $VALIDATE_BASH || -n \
    $VALIDATE_PERL || -n \
    $VALIDATE_PHP || -n \
    $VALIDATE_PYTHON || -n \
    $VALIDATE_RUBY || -n \
    $VALIDATE_COFFEE || -n \
    $VALIDATE_ANSIBLE || -n \
    $VALIDATE_JAVASCRIPT_ES || -n \
    $VALIDATE_JAVASCRIPT_STANDARD || -n \
    $VALIDATE_TYPESCRIPT_ES || -n \
    $VALIDATE_TYPESCRIPT_STANDARD || -n \
    $VALIDATE_DOCKER || -n \
    $VALIDATE_GO || -n \
    $VALIDATE_TERRAFORM || -n \
    $VALIDATE_POWERSHELL || -n \
    $VALIDATE_ARM || -n \
    $VALIDATE_CSS || -n \
    $VALIDATE_ENV || -n \
    $VALIDATE_CLOJURE || -n \
    $VALIDATE_PROTOBUF || -n \
    $VALIDATE_OPENAPI || -n \
    $VALIDATE_KOTLIN || -n \
    $VALIDATE_EDITORCONFIG || -n \
    $VALIDATE_HTML ]]; then
    ANY_SET="true"
  fi

  ####################################
  # Validate if we should check YAML #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_YAML ]]; then
      # YAML flag was not set - default to false
      VALIDATE_YAML="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_YAML="true"
  fi

  ####################################
  # Validate if we should check JSON #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_JSON ]]; then
      # JSON flag was not set - default to false
      VALIDATE_JSON="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_JSON="true"
  fi

  ###################################
  # Validate if we should check XML #
  ###################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_XML ]]; then
      # XML flag was not set - default to false
      VALIDATE_XML="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_XML="true"
  fi

  ########################################
  # Validate if we should check MARKDOWN #
  ########################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_MD ]]; then
      # MD flag was not set - default to false
      VALIDATE_MD="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_MD="true"
  fi

  ####################################
  # Validate if we should check BASH #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_BASH ]]; then
      # BASH flag was not set - default to false
      VALIDATE_BASH="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_BASH="true"
  fi

  ####################################
  # Validate if we should check PERL #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_PERL ]]; then
      # PERL flag was not set - default to false
      VALIDATE_PERL="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_PERL="true"
  fi

  ####################################
  # Validate if we should check PHP #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_PHP ]]; then
      # PHP flag was not set - default to false
      VALIDATE_PHP="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_PHP="true"
  fi

  ######################################
  # Validate if we should check PYTHON #
  ######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_PYTHON ]]; then
      # PYTHON flag was not set - default to false
      VALIDATE_PYTHON="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_PYTHON="true"
  fi

  ####################################
  # Validate if we should check RUBY #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_RUBY ]]; then
      # RUBY flag was not set - default to false
      VALIDATE_RUBY="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_RUBY="true"
  fi

  ######################################
  # Validate if we should check COFFEE #
  ######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_COFFEE ]]; then
      # COFFEE flag was not set - default to false
      VALIDATE_COFFEE="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_COFFEE="true"
  fi

  #######################################
  # Validate if we should check ANSIBLE #
  #######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_ANSIBLE ]]; then
      # ANSIBLE flag was not set - default to false
      VALIDATE_ANSIBLE="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_ANSIBLE="true"
  fi

  #############################################
  # Validate if we should check JAVASCRIPT_ES #
  #############################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_JAVASCRIPT_ES ]]; then
      # JAVASCRIPT_ES flag was not set - default to false
      VALIDATE_JAVASCRIPT_ES="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_JAVASCRIPT_ES="true"
  fi

  ###################################################
  # Validate if we should check JAVASCRIPT_STANDARD #
  ###################################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_JAVASCRIPT_STANDARD ]]; then
      # JAVASCRIPT_STANDARD flag was not set - default to false
      VALIDATE_JAVASCRIPT_STANDARD="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_JAVASCRIPT_STANDARD="true"
  fi

  #############################################
  # Validate if we should check TYPESCRIPT_ES #
  #############################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_TYPESCRIPT_ES ]]; then
      # TYPESCRIPT_ES flag was not set - default to false
      VALIDATE_TYPESCRIPT_ES="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_TYPESCRIPT_ES="true"
  fi

  ###################################################
  # Validate if we should check TYPESCRIPT_STANDARD #
  ###################################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_TYPESCRIPT_STANDARD ]]; then
      # TYPESCRIPT_STANDARD flag was not set - default to false
      VALIDATE_TYPESCRIPT_STANDARD="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_TYPESCRIPT_STANDARD="true"
  fi

  ######################################
  # Validate if we should check DOCKER #
  ######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_DOCKER ]]; then
      # DOCKER flag was not set - default to false
      VALIDATE_DOCKER="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_DOCKER="true"
  fi

  ##################################
  # Validate if we should check GO #
  ##################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_GO ]]; then
      # GO flag was not set - default to false
      VALIDATE_GO="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_GO="true"
  fi

  #########################################
  # Validate if we should check TERRAFORM #
  #########################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_TERRAFORM ]]; then
      # TERRAFORM flag was not set - default to false
      VALIDATE_TERRAFORM="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_TERRAFORM="true"
  fi

  #########################################
  # Validate if we should check POWERSHELL #
  #########################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_POWERSHELL ]]; then
      # POWERSHELL flag was not set - default to false
      VALIDATE_POWERSHELL="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_POWERSHELL="true"
  fi

  ###################################
  # Validate if we should check ARM #
  ###################################
  if [[ "$ANY_SET" == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z "$VALIDATE_ARM" ]]; then
      # ARM flag was not set - default to false
      VALIDATE_ARM="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_ARM="true"
  fi

  ###################################
  # Validate if we should check CSS #
  ###################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_CSS ]]; then
      # CSS flag was not set - default to false
      VALIDATE_CSS="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_CSS="true"
  fi

  ###################################
  # Validate if we should check ENV #
  ###################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_ENV ]]; then
      # ENV flag was not set - default to false
      VALIDATE_ENV="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_ENV="true"
  fi

  ######################################
  # Validate if we should check KOTLIN #
  ######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_KOTLIN ]]; then
      # ENV flag was not set - default to false
      VALIDATE_KOTLIN="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_KOTLIN="true"
  fi

  #######################################
  # Validate if we should check OPENAPI #
  #######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_OPENAPI ]]; then
      # OPENAPI flag was not set - default to false
      VALIDATE_OPENAPI="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_OPENAPI="true"
  fi

  #######################################
  # Validate if we should check PROTOBUF #
  #######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_PROTOBUF ]]; then
      # PROTOBUF flag was not set - default to false
      VALIDATE_PROTOBUF="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_PROTOBUF="true"
  fi

  #######################################
  # Validate if we should check Clojure #
  #######################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_CLOJURE ]]; then
      # Clojure flag was not set - default to false
      VALIDATE_CLOJURE="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_CLOJURE="true"
  fi

  ############################################
  # Validate if we should check editorconfig #
  ############################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_EDITORCONFIG ]]; then
      # EDITORCONFIG flag was not set - default to false
      VALIDATE_EDITORCONFIG="false"
    fi
  else
    # No linter flags were set
    # special case cehcking for .editorconfig
    if [ -f "$GITHUB_WORKSPACE/$LINTER_RULES_PATH/$EDITORCONFIG_FILE_NAME" ]; then
      VALIDATE_EDITORCONFIG="true"
    fi
  fi

  ####################################
  # Validate if we should check HTML #
  ####################################
  if [[ $ANY_SET == "true" ]]; then
    # Some linter flags were set - only run those set to true
    if [[ -z $VALIDATE_HTML ]]; then
      # HTML flag was not set - default to false
      VALIDATE_HTML="false"
    fi
  else
    # No linter flags were set - default all to true
    VALIDATE_HTML="true"
  fi

  #######################################
  # Print which linters we are enabling #
  #######################################
  if [[ $VALIDATE_YAML == "true" ]]; then
    PRINT_ARRAY+=("- Validating [YAML] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [YAML] files in code base...")
  fi
  if [[ $VALIDATE_JSON == "true" ]]; then
    PRINT_ARRAY+=("- Validating [JSON] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [JSON] files in code base...")
  fi
  if [[ $VALIDATE_XML == "true" ]]; then
    PRINT_ARRAY+=("- Validating [XML] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [XML] files in code base...")
  fi
  if [[ $VALIDATE_MD == "true" ]]; then
    PRINT_ARRAY+=("- Validating [MARKDOWN] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [MARKDOWN] files in code base...")
  fi
  if [[ $VALIDATE_BASH == "true" ]]; then
    PRINT_ARRAY+=("- Validating [BASH] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [BASH] files in code base...")
  fi
  if [[ $VALIDATE_PERL == "true" ]]; then
    PRINT_ARRAY+=("- Validating [PERL] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [PERL] files in code base...")
  fi
  if [[ $VALIDATE_PHP == "true" ]]; then
    PRINT_ARRAY+=("- Validating [PHP] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [PHP] files in code base...")
  fi
  if [[ $VALIDATE_PYTHON == "true" ]]; then
    PRINT_ARRAY+=("- Validating [PYTHON] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [PYTHON] files in code base...")
  fi
  if [[ $VALIDATE_RUBY == "true" ]]; then
    PRINT_ARRAY+=("- Validating [RUBY] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [RUBY] files in code base...")
  fi
  if [[ $VALIDATE_COFFEE == "true" ]]; then
    PRINT_ARRAY+=("- Validating [COFFEE] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [COFFEE] files in code base...")
  fi
  if [[ $VALIDATE_ANSIBLE == "true" ]]; then
    PRINT_ARRAY+=("- Validating [ANSIBLE] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [ANSIBLE] files in code base...")
  fi
  if [[ $VALIDATE_JAVASCRIPT_ES == "true" ]]; then
    PRINT_ARRAY+=("- Validating [JAVASCRIPT(eslint)] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [JAVASCRIPT(eslint)] files in code base...")
  fi
  if [[ $VALIDATE_JAVASCRIPT_STANDARD == "true" ]]; then
    PRINT_ARRAY+=("- Validating [JAVASCRIPT(standard)] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [JAVASCRIPT(standard)] files in code base...")
  fi
  if [[ $VALIDATE_TYPESCRIPT_ES == "true" ]]; then
    PRINT_ARRAY+=("- Validating [TYPESCRIPT(eslint)] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [TYPESCRIPT(eslint)] files in code base...")
  fi
  if [[ $VALIDATE_TYPESCRIPT_STANDARD == "true" ]]; then
    PRINT_ARRAY+=("- Validating [TYPESCRIPT(standard)] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [TYPESCRIPT(standard)] files in code base...")
  fi
  if [[ $VALIDATE_DOCKER == "true" ]]; then
    PRINT_ARRAY+=("- Validating [DOCKER] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [DOCKER] files in code base...")
  fi
  if [[ $VALIDATE_GO == "true" ]]; then
    PRINT_ARRAY+=("- Validating [GOLANG] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [GOLANG] files in code base...")
  fi
  if [[ $VALIDATE_TERRAFORM == "true" ]]; then
    PRINT_ARRAY+=("- Validating [TERRAFORM] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [TERRAFORM] files in code base...")
  fi
  if [[ $VALIDATE_POWERSHELL == "true" ]]; then
    PRINT_ARRAY+=("- Validating [POWERSHELL] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [POWERSHELL] files in code base...")
  fi
  if [[ $VALIDATE_ARM == "true" ]]; then
    PRINT_ARRAY+=("- Validating [ARM] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [ARM] files in code base...")
  fi
  if [[ $VALIDATE_CSS == "true" ]]; then
    PRINT_ARRAY+=("- Validating [CSS] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [CSS] files in code base...")
  fi
  if [[ $VALIDATE_CLOJURE == "true" ]]; then
    PRINT_ARRAY+=("- Validating [CLOJURE] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [CLOJURE] files in code base...")
  fi
  if [[ $VALIDATE_ENV == "true" ]]; then
    PRINT_ARRAY+=("- Validating [ENV] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [ENV] files in code base...")
  fi
  if [[ $VALIDATE_KOTLIN == "true" ]]; then
    PRINT_ARRAY+=("- Validating [KOTLIN] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [KOTLIN] files in code base...")
  fi
  if [[ $VALIDATE_OPENAPI == "true" ]]; then
    PRINT_ARRAY+=("- Validating [OPENAPI] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [OPENAPI] files in code base...")
  fi
  if [[ $VALIDATE_PROTOBUF == "true" ]]; then
    PRINT_ARRAY+=("- Validating [PROTOBUF] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [PROTOBUF] files in code base...")
  fi
  if [[ $VALIDATE_EDITORCONFIG == "true" ]]; then
    PRINT_ARRAY+=("- Validating [EDITORCONFIG] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [EDITORCONFIG] files in code base...")
  fi
  if [[ $VALIDATE_HTML == "true" ]]; then
    PRINT_ARRAY+=("- Validating [HTML] files in code base...")
  else
    PRINT_ARRAY+=("- Excluding [HTML] files in code base...")
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

  ###############################
  # Get the disable errors flag #
  ###############################
  if [ -z "$DISABLE_ERRORS" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    DISABLE_ERRORS="$DEFAULT_DISABLE_ERRORS"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  DISABLE_ERRORS=$(echo "$DISABLE_ERRORS" | awk '{print tolower($0)}')

  ############################
  # Set to false if not true #
  ############################
  if [ "$DISABLE_ERRORS" != "true" ]; then
    DISABLE_ERRORS="false"
  fi

  ############################
  # Get the run verbose flag #
  ############################
  if [ -z "$ACTIONS_RUNNER_DEBUG" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    ACTIONS_RUNNER_DEBUG="$DEFAULT_ACTIONS_RUNNER_DEBUG"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  ACTIONS_RUNNER_DEBUG=$(echo "$ACTIONS_RUNNER_DEBUG" | awk '{print tolower($0)}')

  ############################
  # Set to true if not false #
  ############################
  if [ "$ACTIONS_RUNNER_DEBUG" != "false" ]; then
    ACTIONS_RUNNER_DEBUG="true"
  fi

  ###################
  # Debug on runner #
  ###################
  if [[ $ACTIONS_RUNNER_DEBUG == "true" ]]; then
    ###########################
    # Print the validate info #
    ###########################
    for LINE in "${PRINT_ARRAY[@]}"; do
      echo "$LINE"
    done

    echo "--- DEBUG INFO ---"
    echo "---------------------------------------------"
    RUNNER=$(whoami)
    echo "Runner:[$RUNNER]"
    echo "ENV:"
    printenv
    echo "---------------------------------------------"
  fi
}
