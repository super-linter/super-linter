#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter (Lint all the code) @admiralawkbar ####################
################################################################################
################################################################################

##################################################################
# Debug Vars                                                     #
# Define these early, so we can use debug logging ASAP if needed #
##################################################################
# RUN_LOCAL="${RUN_LOCAL}"                            # Boolean to see if we are running locally
ACTIONS_RUNNER_DEBUG="${ACTIONS_RUNNER_DEBUG:-false}" # Boolean to see even more info (debug)
IMAGE="${IMAGE:-standard}"                            # Version of the Super-linter (standard,slim,etc)

##################################################################
# Log Vars                                                       #
# Define these early, so we can use debug logging ASAP if needed #
##################################################################
LOG_FILE="${LOG_FILE:-super-linter.log}" # Default log file name (located in GITHUB_WORKSPACE folder)
LOG_LEVEL="${LOG_LEVEL:-VERBOSE}"        # Default log level (VERBOSE, DEBUG, TRACE)

if [[ ${ACTIONS_RUNNER_DEBUG} == true ]]; then LOG_LEVEL="DEBUG"; fi
# Boolean to see trace logs
LOG_TRACE=$(if [[ ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_TRACE
# Boolean to see debug logs
LOG_DEBUG=$(if [[ ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_DEBUG
# Boolean to see verbose logs (info function)
LOG_VERBOSE=$(if [[ ${LOG_LEVEL} == "VERBOSE" || ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_VERBOSE
# Boolean to see notice logs
LOG_NOTICE=$(if [[ ${LOG_LEVEL} == "NOTICE" || ${LOG_LEVEL} == "VERBOSE" || ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_NOTICE
# Boolean to see warn logs
LOG_WARN=$(if [[ ${LOG_LEVEL} == "WARN" || ${LOG_LEVEL} == "NOTICE" || ${LOG_LEVEL} == "VERBOSE" || ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_WARN
# Boolean to see error logs
LOG_ERROR=$(if [[ ${LOG_LEVEL} == "ERROR" || ${LOG_LEVEL} == "WARN" || ${LOG_LEVEL} == "NOTICE" || ${LOG_LEVEL} == "VERBOSE" || ${LOG_LEVEL} == "DEBUG" || ${LOG_LEVEL} == "TRACE" ]]; then echo "true"; fi)
export LOG_ERROR

#########################
# Source Function Files #
#########################
# shellcheck source=/dev/null
source /action/lib/functions/buildFileList.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/detectFiles.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/linterCommands.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/linterRules.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/linterVersions.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/log.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/updateSSL.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/validation.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/functions/worker.sh # Source the function script(s)

###########
# GLOBALS #
###########
# Default Vars
DEFAULT_RULES_LOCATION='/action/lib/.automation'                    # Default rules files location
LINTER_RULES_PATH="${LINTER_RULES_PATH:-.github/linters}"           # Linter Path Directory
GITHUB_API_URL="${GITHUB_CUSTOM_API_URL:-"https://api.github.com"}" # GitHub API root url
VERSION_FILE='/action/lib/functions/linterVersions.txt'             # File to store linter versions
export VERSION_FILE                                                 # Workaround SC2034

###############
# Rules files #
###############
# shellcheck disable=SC2034  # Variable is referenced indirectly
ANSIBLE_FILE_NAME="${ANSIBLE_CONFIG_FILE:-.ansible-lint.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
ARM_FILE_NAME=".arm-ttk.psd1"
# shellcheck disable=SC2034  # Variable is referenced indirectly
CLOJURE_FILE_NAME=".clj-kondo/config.edn"
# shellcheck disable=SC2034  # Variable is referenced indirectly
CLOUDFORMATION_FILE_NAME=".cfnlintrc.yml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
COFFEESCRIPT_FILE_NAME=".coffee-lint.json"
CSS_FILE_NAME="${CSS_FILE_NAME:-.stylelintrc.json}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
DART_FILE_NAME="analysis_options.yml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
DOCKERFILE_FILE_NAME=".dockerfilelintrc"
DOCKERFILE_HADOLINT_FILE_NAME="${DOCKERFILE_HADOLINT_FILE_NAME:-.hadolint.yaml}"
EDITORCONFIG_FILE_NAME="${EDITORCONFIG_FILE_NAME:-.ecrc}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
GHERKIN_FILE_NAME=".gherkin-lintrc"
# shellcheck disable=SC2034  # Variable is referenced indirectly
GO_FILE_NAME=".golangci.yml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
GROOVY_FILE_NAME=".groovylintrc.json"
# shellcheck disable=SC2034  # Variable is referenced indirectly
HTML_FILE_NAME=".htmlhintrc"
# shellcheck disable=SC2034  # Variable is referenced indirectly
JAVA_FILE_NAME="sun_checks.xml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
JAVASCRIPT_ES_FILE_NAME="${JAVASCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
JAVASCRIPT_DEFAULT_STYLE="${JAVASCRIPT_DEFAULT_STYLE:-standard}"
JAVASCRIPT_STYLE_NAME='' # Variable for the style
JAVASCRIPT_STYLE=''      # Variable for the style
# shellcheck disable=SC2034  # Variable is referenced indirectly
JAVASCRIPT_STANDARD_FILE_NAME="${JAVASCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
JSCPD_FILE_NAME="${JSCPD_CONFIG_FILE:-.jscpd.json}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
JSX_FILE_NAME="${JAVASCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
LATEX_FILE_NAME=".chktexrc"
# shellcheck disable=SC2034  # Variable is referenced indirectly
LUA_FILE_NAME=".luacheckrc"
# shellcheck disable=SC2034  # Variable is referenced indirectly
MARKDOWN_FILE_NAME="${MARKDOWN_CONFIG_FILE:-.markdown-lint.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
OPENAPI_FILE_NAME=".openapirc.yml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PHP_BUILTIN_FILE_NAME="${PHP_CONFIG_FILE:-php.ini}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PHP_PHPCS_FILE_NAME="phpcs.xml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PHP_PHPSTAN_FILE_NAME="phpstan.neon"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PHP_PSALM_FILE_NAME="psalm.xml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
POWERSHELL_FILE_NAME=".powershell-psscriptanalyzer.psd1"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PROTOBUF_FILE_NAME=".protolintrc.yml"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PYTHON_BLACK_FILE_NAME="${PYTHON_BLACK_CONFIG_FILE:-.python-black}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PYTHON_FLAKE8_FILE_NAME="${PYTHON_FLAKE8_CONFIG_FILE:-.flake8}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PYTHON_ISORT_FILE_NAME="${PYTHON_ISORT_CONFIG_FILE:-.isort.cfg}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PYTHON_MYPY_FILE_NAME="${PYTHON_MYPY_CONFIG_FILE:-.mypy.ini}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
PYTHON_PYLINT_FILE_NAME="${PYTHON_PYLINT_CONFIG_FILE:-.python-lint}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
R_FILE_NAME=".lintr"
# shellcheck disable=SC2034  # Variable is referenced indirectly
RUBY_FILE_NAME="${RUBY_CONFIG_FILE:-.ruby-lint.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
SNAKEMAKE_SNAKEFMT_FILE_NAME="${SNAKEMAKE_SNAKEFMT_CONFIG_FILE:-.snakefmt.toml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
SUPPRESS_POSSUM="${SUPPRESS_POSSUM:-false}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
# SSL_CERT_SECRET="${SSL_CERT_SECRET}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
SQL_FILE_NAME="${SQL_CONFIG_FILE:-.sql-config.json}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
TERRAFORM_FILE_NAME=".tflint.hcl"
# shellcheck disable=SC2034  # Variable is referenced indirectly
TSX_FILE_NAME="${TYPESCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
TYPESCRIPT_ES_FILE_NAME="${TYPESCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
TYPESCRIPT_STANDARD_FILE_NAME="${TYPESCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
USE_FIND_ALGORITHM="${USE_FIND_ALGORITHM:-false}"
# shellcheck disable=SC2034  # Variable is referenced indirectly
YAML_FILE_NAME="${YAML_CONFIG_FILE:-.yaml-lint.yml}"

#################################################
# Parse if we are using JS standard or prettier #
#################################################
# Remove spaces
JAVASCRIPT_DEFAULT_STYLE=$(echo "${JAVASCRIPT_DEFAULT_STYLE}" | tr -d ' ')
# lowercase
JAVASCRIPT_DEFAULT_STYLE=$(echo "${JAVASCRIPT_DEFAULT_STYLE}" | tr '[:upper:]' '[:lower:]')
# Check and set
if [ "${JAVASCRIPT_DEFAULT_STYLE}" == "prettier" ]; then
  # Set to prettier
  JAVASCRIPT_STYLE_NAME='JAVASCRIPT_PRETTIER'
  JAVASCRIPT_STYLE='prettier'
else
  # Default to standard
  JAVASCRIPT_STYLE_NAME='JAVASCRIPT_STANDARD'
  JAVASCRIPT_STYLE='standard'
fi

##################
# Language array #
##################
LANGUAGE_ARRAY=('ANSIBLE' 'ARM' 'BASH' 'BASH_EXEC' 'CLOUDFORMATION' 'CLOJURE' 'COFFEESCRIPT' 'CPP' 'CSHARP' 'CSS'
  'DART' 'DOCKERFILE' 'DOCKERFILE_HADOLINT' 'EDITORCONFIG' 'ENV' 'GHERKIN' 'GO' 'GROOVY' 'HTML'
  'JAVA' 'JAVASCRIPT_ES' "${JAVASCRIPT_STYLE_NAME}" 'JSCPD' 'JSON' 'JSONC' 'JSX' 'KUBERNETES_KUBEVAL' 'KOTLIN' 'LATEX' 'LUA' 'MARKDOWN'
  'OPENAPI' 'PERL' 'PHP_BUILTIN' 'PHP_PHPCS' 'PHP_PHPSTAN' 'PHP_PSALM' 'POWERSHELL'
  'PROTOBUF' 'PYTHON_BLACK' 'PYTHON_PYLINT' 'PYTHON_FLAKE8' 'PYTHON_ISORT' 'PYTHON_MYPY'
  'R' 'RAKU' 'RUBY' 'RUST_2015' 'RUST_2018' 'RUST_CLIPPY'
  'SHELL_SHFMT' 'SNAKEMAKE_LINT' 'SNAKEMAKE_SNAKEFMT' 'STATES' 'SQL'
  'TEKTON' 'TERRAFORM' 'TERRAFORM_TERRASCAN' 'TERRAGRUNT' 'TSX' 'TYPESCRIPT_ES' 'TYPESCRIPT_STANDARD' 'XML' 'YAML')

##############################
# Linter command names array #
##############################
declare -A LINTER_NAMES_ARRAY
LINTER_NAMES_ARRAY['ANSIBLE']="ansible-lint"
LINTER_NAMES_ARRAY['ARM']="arm-ttk"
LINTER_NAMES_ARRAY['BASH']="shellcheck"
LINTER_NAMES_ARRAY['BASH_EXEC']="bash-exec"
LINTER_NAMES_ARRAY['CLOJURE']="clj-kondo"
LINTER_NAMES_ARRAY['CLOUDFORMATION']="cfn-lint"
LINTER_NAMES_ARRAY['COFFEESCRIPT']="coffeelint"
LINTER_NAMES_ARRAY['CPP']="cpplint"
LINTER_NAMES_ARRAY['CSHARP']="dotnet-format"
LINTER_NAMES_ARRAY['CSS']="stylelint"
LINTER_NAMES_ARRAY['DART']="dart"
LINTER_NAMES_ARRAY['DOCKERFILE']="dockerfilelint"
LINTER_NAMES_ARRAY['DOCKERFILE_HADOLINT']="hadolint"
LINTER_NAMES_ARRAY['EDITORCONFIG']="editorconfig-checker"
LINTER_NAMES_ARRAY['ENV']="dotenv-linter"
LINTER_NAMES_ARRAY['GHERKIN']="gherkin-lint"
LINTER_NAMES_ARRAY['GO']="golangci-lint"
LINTER_NAMES_ARRAY['GROOVY']="npm-groovy-lint"
LINTER_NAMES_ARRAY['HTML']="htmlhint"
LINTER_NAMES_ARRAY['JAVA']="checkstyle"
LINTER_NAMES_ARRAY['JAVASCRIPT_ES']="eslint"
LINTER_NAMES_ARRAY["${JAVASCRIPT_STYLE_NAME}"]="${JAVASCRIPT_STYLE}"
LINTER_NAMES_ARRAY['JSCPD']="jscpd"
LINTER_NAMES_ARRAY['JSON']="jsonlint"
LINTER_NAMES_ARRAY['JSONC']="eslint"
LINTER_NAMES_ARRAY['JSX']="eslint"
LINTER_NAMES_ARRAY['KOTLIN']="ktlint"
LINTER_NAMES_ARRAY['KUBERNETES_KUBEVAL']="kubeval"
LINTER_NAMES_ARRAY['LATEX']="chktex"
LINTER_NAMES_ARRAY['LUA']="lua"
LINTER_NAMES_ARRAY['MARKDOWN']="markdownlint"
LINTER_NAMES_ARRAY['OPENAPI']="spectral"
LINTER_NAMES_ARRAY['PERL']="perl"
LINTER_NAMES_ARRAY['PHP_BUILTIN']="php"
LINTER_NAMES_ARRAY['PHP_PHPCS']="phpcs"
LINTER_NAMES_ARRAY['PHP_PHPSTAN']="phpstan"
LINTER_NAMES_ARRAY['PHP_PSALM']="psalm"
LINTER_NAMES_ARRAY['POWERSHELL']="pwsh"
LINTER_NAMES_ARRAY['PROTOBUF']="protolint"
LINTER_NAMES_ARRAY['PYTHON_BLACK']="black"
LINTER_NAMES_ARRAY['PYTHON_PYLINT']="pylint"
LINTER_NAMES_ARRAY['PYTHON_FLAKE8']="flake8"
LINTER_NAMES_ARRAY['PYTHON_ISORT']="isort"
LINTER_NAMES_ARRAY['PYTHON_MYPY']="mypy"
LINTER_NAMES_ARRAY['R']="R"
LINTER_NAMES_ARRAY['RAKU']="raku"
LINTER_NAMES_ARRAY['RUBY']="rubocop"
LINTER_NAMES_ARRAY['RUST_2015']="rustfmt"
LINTER_NAMES_ARRAY['RUST_2018']="rustfmt"
LINTER_NAMES_ARRAY['RUST_CLIPPY']="clippy"
LINTER_NAMES_ARRAY['SHELL_SHFMT']="shfmt"
LINTER_NAMES_ARRAY['SNAKEMAKE_LINT']="snakemake"
LINTER_NAMES_ARRAY['SNAKEMAKE_SNAKEFMT']="snakefmt"
LINTER_NAMES_ARRAY['STATES']="asl-validator"
LINTER_NAMES_ARRAY['SQL']="sql-lint"
LINTER_NAMES_ARRAY['TEKTON']="tekton-lint"
LINTER_NAMES_ARRAY['TERRAFORM']="tflint"
LINTER_NAMES_ARRAY['TERRAFORM_TERRASCAN']="terrascan"
LINTER_NAMES_ARRAY['TERRAGRUNT']="terragrunt"
LINTER_NAMES_ARRAY['TSX']="eslint"
LINTER_NAMES_ARRAY['TYPESCRIPT_ES']="eslint"
LINTER_NAMES_ARRAY['TYPESCRIPT_STANDARD']="standard"
LINTER_NAMES_ARRAY['XML']="xmllint"
LINTER_NAMES_ARRAY['YAML']="yamllint"

############################################
# Array for all languages that were linted #
############################################
LINTED_LANGUAGES_ARRAY=() # Will be filled at run time with all languages that were linted

###################
# GitHub ENV Vars #
###################
# ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY}"         # Ansible Directory
MULTI_STATUS="${MULTI_STATUS:-true}"       # Multiple status are created for each check ran
DEFAULT_BRANCH="${DEFAULT_BRANCH:-master}" # Default Git Branch to use (master by default)
# DISABLE_ERRORS="${DISABLE_ERRORS}"               # Boolean to enable warning-only output without throwing errors
# FILTER_REGEX_INCLUDE="${FILTER_REGEX_INCLUDE}"   # RegExp defining which files will be processed by linters (all by default)
# FILTER_REGEX_EXCLUDE="${FILTER_REGEX_EXCLUDE}"   # RegExp defining which files will be excluded from linting (none by default)
# GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"         # Github Event Path
# GITHUB_REPOSITORY="${GITHUB_REPOSITORY}"         # GitHub Org/Repo passed from system
# GITHUB_RUN_ID="${GITHUB_RUN_ID}"                 # GitHub RUn ID to point to logs
# GITHUB_SHA="${GITHUB_SHA}"                       # GitHub sha from the commit
# GITHUB_TOKEN="${GITHUB_TOKEN}"                   # GitHub Token passed from environment
# GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"           # Github Workspace
# TEST_CASE_RUN="${TEST_CASE_RUN}"                 # Boolean to validate only test cases
# VALIDATE_ALL_CODEBASE="${VALIDATE_ALL_CODEBASE}" # Boolean to validate all files

IGNORE_GITIGNORED_FILES="${IGNORE_GITIGNORED_FILES:-false}"

################
# Default Vars #
################
DEFAULT_VALIDATE_ALL_CODEBASE='true'                # Default value for validate all files
DEFAULT_WORKSPACE="${DEFAULT_WORKSPACE:-/tmp/lint}" # Default workspace if running locally
DEFAULT_RUN_LOCAL='false'                           # Default value for debugging locally
DEFAULT_TEST_CASE_RUN='false'                       # Flag to tell code to run only test cases

###############################################################
# Default Vars that are called in Subs and need to be ignored #
###############################################################
DEFAULT_DISABLE_ERRORS='false'                                  # Default to enabling errors
export DEFAULT_DISABLE_ERRORS                                   # Workaround SC2034
ERROR_ON_MISSING_EXEC_BIT="${ERROR_ON_MISSING_EXEC_BIT:-false}" # Default to report a warning if a shell script doesn't have the executable bit set to 1
export ERROR_ON_MISSING_EXEC_BIT
RAW_FILE_ARRAY=()                   # Array of all files that were changed
export RAW_FILE_ARRAY               # Workaround SC2034
TEST_CASE_FOLDER='.automation/test' # Folder for test cases we should always ignore
export TEST_CASE_FOLDER             # Workaround SC2034

##########################
# Array of changed files #
##########################
for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  FILE_ARRAY_VARIABLE_NAME="FILE_ARRAY_${LANGUAGE}"
  debug "Setting ${FILE_ARRAY_VARIABLE_NAME} variable..."
  eval "${FILE_ARRAY_VARIABLE_NAME}=()"
done

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  ###############################
  # Give them the possum action #
  ###############################
  if [[ "${SUPPRESS_POSSUM}" == "false" ]]; then
    /bin/bash /action/lib/functions/possum.sh
  fi

  ##########
  # Prints #
  ##########
  info "---------------------------------------------"
  info "--- GitHub Actions Multi Language Linter ----"
  info " - Image Creation Date:[${BUILD_DATE}]"
  info " - Image Revision:[${BUILD_REVISION}]"
  info " - Image Version:[${BUILD_VERSION}]"
  info "---------------------------------------------"
  info "---------------------------------------------"
  info "The Super-Linter source code can be found at:"
  info " - https://github.com/github/super-linter"
  info "---------------------------------------------"
}
################################################################################
#### Function GetGitHubVars ####################################################
GetGitHubVars() {
  ##########
  # Prints #
  ##########
  info "--------------------------------------------"
  info "Gathering GitHub information..."

  ###############################
  # Get the Run test cases flag #
  ###############################
  if [ -z "${TEST_CASE_RUN}" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    TEST_CASE_RUN="${DEFAULT_TEST_CASE_RUN}"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  TEST_CASE_RUN="${TEST_CASE_RUN,,}"

  ##########################
  # Get the run local flag #
  ##########################
  if [ -z "${RUN_LOCAL}" ]; then
    ##################################
    # No flag passed, set to default #
    ##################################
    RUN_LOCAL="${DEFAULT_RUN_LOCAL}"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  RUN_LOCAL="${RUN_LOCAL,,}"

  #################################
  # Check if were running locally #
  #################################
  if [[ ${RUN_LOCAL} != "false" ]]; then
    ##########################################
    # We are running locally for a debug run #
    ##########################################
    info "NOTE: ENV VAR [RUN_LOCAL] has been set to:[true]"
    info "bypassing GitHub Actions variables..."

    ############################
    # Set the GITHUB_WORKSPACE #
    ############################
    if [ -z "${GITHUB_WORKSPACE}" ]; then
      GITHUB_WORKSPACE="${DEFAULT_WORKSPACE}"
    fi

    if [ ! -d "${GITHUB_WORKSPACE}" ]; then
      fatal "Provided volume is not a directory!"
    fi

    info "Linting all files in mapped directory:[${DEFAULT_WORKSPACE}]"

    # No need to touch or set the GITHUB_SHA
    # No need to touch or set the GITHUB_EVENT_PATH
    # No need to touch or set the GITHUB_ORG
    # No need to touch or set the GITHUB_REPO

    #################################
    # Set the VALIDATE_ALL_CODEBASE #
    #################################
    VALIDATE_ALL_CODEBASE="${DEFAULT_VALIDATE_ALL_CODEBASE}"
  else
    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_SHA}" ]; then
      error "Failed to get [GITHUB_SHA]!"
      fatal "[${GITHUB_SHA}]"
    else
      info "Successfully found:${F[W]}[GITHUB_SHA]${F[B]}, value:${F[W]}[${GITHUB_SHA}]"
    fi

    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_WORKSPACE}" ]; then
      error "Failed to get [GITHUB_WORKSPACE]!"
      fatal "[${GITHUB_WORKSPACE}]"
    else
      info "Successfully found:${F[W]}[GITHUB_WORKSPACE]${F[B]}, value:${F[W]}[${GITHUB_WORKSPACE}]"
    fi

    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_EVENT_PATH}" ]; then
      error "Failed to get [GITHUB_EVENT_PATH]!"
      fatal "[${GITHUB_EVENT_PATH}]"
    else
      info "Successfully found:${F[W]}[GITHUB_EVENT_PATH]${F[B]}, value:${F[W]}[${GITHUB_EVENT_PATH}]${F[B]}"
    fi

    ##################################################
    # Need to pull the GitHub Vars from the env file #
    ##################################################

    ######################
    # Get the GitHub Org #
    ######################
    GITHUB_ORG=$(jq -r '.repository.owner.login' <"${GITHUB_EVENT_PATH}")

    ########################
    # Fix SHA for PR event #
    ########################
    # Github sha on PR events is not the latest commit.
    # https://docs.github.com/en/actions/reference/events-that-trigger-workflows#pull_request
    if [ "$GITHUB_EVENT_NAME" == "pull_request" ]; then
      GITHUB_SHA=$(jq -r .pull_request.head.sha <"$GITHUB_EVENT_PATH")
    fi

    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_ORG}" ]; then
      error "Failed to get [GITHUB_ORG]!"
      fatal "[${GITHUB_ORG}]"
    else
      info "Successfully found:${F[W]}[GITHUB_ORG]${F[B]}, value:${F[W]}[${GITHUB_ORG}]"
    fi

    #######################
    # Get the GitHub Repo #
    #######################
    GITHUB_REPO=$(jq -r '.repository.name' <"${GITHUB_EVENT_PATH}")

    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_REPO}" ]; then
      error "Failed to get [GITHUB_REPO]!"
      fatal "[${GITHUB_REPO}]"
    else
      info "Successfully found:${F[W]}[GITHUB_REPO]${F[B]}, value:${F[W]}[${GITHUB_REPO}]"
    fi
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "${GITHUB_TOKEN}" ] && [[ ${RUN_LOCAL} == "false" ]]; then
    error "Failed to get [GITHUB_TOKEN]!"
    error "[${GITHUB_TOKEN}]"
    error "Please set a [GITHUB_TOKEN] from the main workflow environment to take advantage of multiple status reports!"

    ################################################################################
    # Need to set MULTI_STATUS to false as we cant hit API endpoints without token #
    ################################################################################
    MULTI_STATUS='false'
  else
    info "Successfully found:${F[W]}[GITHUB_TOKEN]"
  fi

  ###############################
  # Convert string to lowercase #
  ###############################
  MULTI_STATUS="${MULTI_STATUS,,}"

  #######################################################################
  # Check to see if the multi status is set, and we have a token to use #
  #######################################################################
  if [ "${MULTI_STATUS}" == "true" ] && [ -n "${GITHUB_TOKEN}" ]; then
    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_REPOSITORY}" ]; then
      error "Failed to get [GITHUB_REPOSITORY]!"
      fatal "[${GITHUB_REPOSITORY}]"
    else
      info "Successfully found:${F[W]}[GITHUB_REPOSITORY]${F[B]}, value:${F[W]}[${GITHUB_REPOSITORY}]"
    fi

    ############################
    # Validate we have a value #
    ############################
    if [ -z "${GITHUB_RUN_ID}" ]; then
      error "Failed to get [GITHUB_RUN_ID]!"
      fatal "[${GITHUB_RUN_ID}]"
    else
      info "Successfully found:${F[W]}[GITHUB_RUN_ID]${F[B]}, value:${F[W]}[${GITHUB_RUN_ID}]"
    fi
  fi
}
################################################################################
#### Function CallStatusAPI ####################################################
CallStatusAPI() {
  ####################
  # Pull in the vars #
  ####################
  LANGUAGE="${1}" # langauge that was validated
  STATUS="${2}"   # success | error
  SUCCESS_MSG='No errors were found in the linting process'
  FAIL_MSG='Errors were detected, please view logs'
  MESSAGE='' # Message to send to status API

  debug "Calling Multi-Status API for $LANGUAGE with status $STATUS"

  ######################################
  # Check the status to create message #
  ######################################
  if [ "${STATUS}" == "success" ]; then
    # Success
    MESSAGE="${SUCCESS_MSG}"
  else
    # Failure
    MESSAGE="${FAIL_MSG}"
  fi

  ##########################################################
  # Check to see if were enabled for multi Status mesaages #
  ##########################################################
  if [ "${MULTI_STATUS}" == "true" ] && [ -n "${GITHUB_TOKEN}" ] && [ -n "${GITHUB_REPOSITORY}" ]; then

    # make sure we honor DISABLE_ERRORS
    if [ "${DISABLE_ERRORS}" == "true" ]; then
      STATUS="success"
    fi

    debug "URL: ${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/statuses/${GITHUB_SHA}"

    ##############################################
    # Call the status API to create status check #
    ##############################################
    SEND_STATUS_CMD=$(
      curl -f -s -X POST \
        --url "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/statuses/${GITHUB_SHA}" \
        -H 'accept: application/vnd.github.v3+json' \
        -H "authorization: Bearer ${GITHUB_TOKEN}" \
        -H 'content-type: application/json' \
        -d "{ \"state\": \"${STATUS}\",
        \"target_url\": \"https://${GITHUB_DOMAIN:-github.com}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}\",
        \"description\": \"${MESSAGE}\", \"context\": \"--> Linted: ${LANGUAGE}\"
      }" 2>&1
    )

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    debug "Send status comd output: [$SEND_STATUS_CMD]"

    ##############################
    # Check the shell for errors #
    ##############################
    if [ "${ERROR_CODE}" -ne 0 ]; then
      # ERROR
      info "ERROR! Failed to call GitHub Status API!"
      info "ERROR:[${SEND_STATUS_CMD}]"
      # Not going to fail the script on this yet...
    fi
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  info "----------------------------------------------"
  info "----------------------------------------------"
  info "The script has completed"
  info "----------------------------------------------"
  info "----------------------------------------------"

  ####################################################
  # Need to clean up the lanuage array of duplicates #
  ####################################################
  mapfile -t UNIQUE_LINTED_ARRAY < <(for LANG in "${LINTED_LANGUAGES_ARRAY[@]}"; do echo "${LANG}"; done | sort -u)
  export UNIQUE_LINTED_ARRAY # Workaround SC2034

  ##############################
  # Prints for errors if found #
  ##############################
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    ###########################
    # Build the error counter #
    ###########################
    ERROR_COUNTER="ERRORS_FOUND_${LANGUAGE}"

    ##################
    # Print if not 0 #
    ##################
    if [[ ${!ERROR_COUNTER} -ne 0 ]]; then
      # We found errors in the language
      ###################
      # Print the goods #
      ###################
      error "ERRORS FOUND${NC} in ${LANGUAGE}:[${!ERROR_COUNTER}]"

      #########################################
      # Create status API for Failed language #
      #########################################
      CallStatusAPI "${LANGUAGE}" "error"
      ######################################
      # Check if we validated the langauge #
      ######################################
    elif [[ ${!ERROR_COUNTER} -eq 0 ]]; then
      if CheckInArray "${LANGUAGE}"; then
        # No errors found when linting the language
        CallStatusAPI "${LANGUAGE}" "success"
      fi
    fi
  done

  ##################################
  # Exit with 0 if errors disabled #
  ##################################
  if [ "${DISABLE_ERRORS}" == "true" ]; then
    warn "Exiting with exit code:[0] as:[DISABLE_ERRORS] was set to:[${DISABLE_ERRORS}]"
    exit 0
  fi

  ###############################
  # Exit with 1 if errors found #
  ###############################
  # Loop through all languages
  for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
    # build the variable
    ERRORS_FOUND_LANGUAGE="ERRORS_FOUND_${LANGUAGE}"
    # Check if error was found
    if [[ ${!ERRORS_FOUND_LANGUAGE} -ne 0 ]]; then
      # Failed exit
      fatal "Exiting with errors found!"
    fi
  done

  ########################
  # Footer prints Exit 0 #
  ########################
  notice "All file(s) linted successfully with no errors detected"
  info "----------------------------------------------"
  # Successful exit
  exit 0
}
################################################################################
#### Function UpdateLoopsForImage ##############################################
UpdateLoopsForImage() {
  ######################################################################
  # Need to clean the array lists of the linters removed for the image #
  ######################################################################
  if [[ "${IMAGE}" == "slim" ]]; then
    #############################################
    # Need to remove linters for the slim image #
    #############################################
    REMOVE_ARRAY=("ARM" "CSHARP" "ENV" "POWERSHELL" "RUST_2015" "RUST_2018" "RUST_CLIPPY")

    # Remove from LANGUAGE_ARRAY
    echo "Removing Languages from LANGUAGE_ARRAY for slim image..."
    for REMOVE_LANGUAGE in "${REMOVE_ARRAY[@]}"; do
      for INDEX in "${!LANGUAGE_ARRAY[@]}"; do
        if [[ ${LANGUAGE_ARRAY[INDEX]} = "${REMOVE_LANGUAGE}" ]]; then
          echo "found item:[${REMOVE_LANGUAGE}], removing Language..."
          unset 'LANGUAGE_ARRAY[INDEX]'
        fi
      done
    done

    # Remove from LINTER_NAMES_ARRAY
    echo "Removing Linters from LINTER_NAMES_ARRAY for slim image..."
    for REMOVE_LINTER in "${REMOVE_ARRAY[@]}"; do
      for INDEX in "${!LINTER_NAMES_ARRAY[@]}"; do
        if [[ ${INDEX} = "${REMOVE_LINTER}" ]]; then
          echo "found item:[${REMOVE_LINTER}], removing linter..."
          unset 'LINTER_NAMES_ARRAY[$INDEX]'
        fi
      done
    done
  fi
}
################################################################################
#### Function Cleanup ##########################################################
cleanup() {
  local -ri EXIT_CODE=$?

  sh -c "cat ${LOG_TEMP} >> ${GITHUB_WORKSPACE}/${LOG_FILE}" || true

  exit ${EXIT_CODE}
  trap - 0 1 2 3 6 14 15
}
trap 'cleanup' 0 1 2 3 6 14 15
################################################################################
############################### MAIN ###########################################
################################################################################

##########
# Header #
##########
Header

################################################
# Need to update the loops for the image style #
################################################
UpdateLoopsForImage

##################################
# Get and print all version info #
##################################
GetLinterVersions

#######################
# Get GitHub Env Vars #
#######################
# Need to pull in all the GitHub variables
# needed to connect back and update checks
GetGitHubVars

########################################################
# Initialize variables that depend on GitHub variables #
########################################################
DEFAULT_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/ansible"                               # Default Ansible Directory
export DEFAULT_ANSIBLE_DIRECTORY                                                      # Workaround SC2034
DEFAULT_TEST_CASE_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/${TEST_CASE_FOLDER}/ansible" # Default Ansible directory when running test cases
export DEFAULT_TEST_CASE_ANSIBLE_DIRECTORY                                            # Workaround SC2034

############################
# Validate the environment #
############################
GetValidationInfo

#################################
# Get the linter rules location #
#################################
LinterRulesLocation

#######################################################
# Get the linter rules and the linter command options #
#######################################################

for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  debug "Loading rules for ${LANGUAGE}..."
  eval "GetLinterRules ${LANGUAGE} ${DEFAULT_RULES_LOCATION}"
done

# Load rules for a couple of special cases
GetStandardRules "javascript"
GetStandardRules "typescript"

# When adding new options and new linters, prefer the long option form over the short form for clarity
declare -A LINTER_DEFAULT_OPTIONS_ARRAY
LINTER_DEFAULT_OPTIONS_ARRAY['ANSIBLE']="-v -c ${ANSIBLE_LINTER_RULES}"
# shellcheck disable=SC2016  # Don't expand variables that PowerShell will handle
LINTER_DEFAULT_OPTIONS_ARRAY['ARM']="\${config} = \$(Import-PowerShellDataFile -Path ${ARM_LINTER_RULES}) ; Test-AzTemplate @config -TemplatePath"
LINTER_DEFAULT_OPTIONS_ARRAY['BASH']="--color --external-sources"
LINTER_DEFAULT_OPTIONS_ARRAY['CLOJURE']="--config ${CLOJURE_LINTER_RULES} --lint"
LINTER_DEFAULT_OPTIONS_ARRAY['CLOUDFORMATION']="--config-file ${CLOUDFORMATION_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['COFFEESCRIPT']="-f ${COFFEESCRIPT_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['CPP']=""
LINTER_DEFAULT_OPTIONS_ARRAY['CSHARP']="--check --folder --exclude / --include"
LINTER_DEFAULT_OPTIONS_ARRAY['CSS']="--config ${CSS_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['DART']="--fatal-infos --fatal-warnings --options ${DART_LINTER_RULES}"
# NOTE: dockerfilelint's "-c" option expects the folder *containing* the DOCKER_LINTER_RULES file
LINTER_DEFAULT_OPTIONS_ARRAY['DOCKERFILE']="-c $(dirname "${DOCKERFILE_LINTER_RULES}")"
LINTER_DEFAULT_OPTIONS_ARRAY['DOCKERFILE_HADOLINT']="-c ${DOCKERFILE_HADOLINT_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['EDITORCONFIG']="-config ${EDITORCONFIG_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['ENV']=""
LINTER_DEFAULT_OPTIONS_ARRAY['GHERKIN']="-c ${GHERKIN_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['GO']="run -c ${GO_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['GROOVY']="-c ${GROOVY_LINTER_RULES} --failon warning"
LINTER_DEFAULT_OPTIONS_ARRAY['HTML']="--config ${HTML_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['JAVA']="-c ${JAVA_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['JAVASCRIPT_ES']="--no-eslintrc -c ${JAVASCRIPT_ES_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['JAVASCRIPT_STANDARD']="${JAVASCRIPT_STANDARD_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['JAVASCRIPT_PRETTIER']="--check"
LINTER_DEFAULT_OPTIONS_ARRAY['JSCPD']="--config ${JSCPD_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['JSON']=""
LINTER_DEFAULT_OPTIONS_ARRAY['JSONC']="--no-eslintrc -c ${JAVASCRIPT_ES_LINTER_RULES} --ext .json5,.jsonc"
LINTER_DEFAULT_OPTIONS_ARRAY['JSX']="--no-eslintrc -c ${JSX_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['KOTLIN']=""
LINTER_DEFAULT_OPTIONS_ARRAY['KUBERNETES_KUBEVAL']="--strict"
LINTER_DEFAULT_OPTIONS_ARRAY['LATEX']="-l ${LATEX_LINTER_RULES} --quiet"
LINTER_DEFAULT_OPTIONS_ARRAY['LUA']="--config ${LUA_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['MARKDOWN']="-c ${MARKDOWN_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['OPENAPI']="lint -r ${OPENAPI_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PERL']=""
LINTER_DEFAULT_OPTIONS_ARRAY['PHP_BUILTIN']="-l -c ${PHP_BUILTIN_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PHP_PHPCS']="--standard=${PHP_PHPCS_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PHP_PHPSTAN']="analyse --no-ansi --no-progress --memory-limit 1G -c ${PHP_PHPSTAN_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PHP_PSALM']="--config=${PHP_PSALM_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['POWERSHELL']="-EnableExit -Settings ${POWERSHELL_LINTER_RULES} -Path"
LINTER_DEFAULT_OPTIONS_ARRAY['PROTOBUF']="lint --config_path ${PROTOBUF_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PYTHON_BLACK']="--config ${PYTHON_BLACK_LINTER_RULES} --diff --check"
LINTER_DEFAULT_OPTIONS_ARRAY['PYTHON_PYLINT']="--rcfile ${PYTHON_PYLINT_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PYTHON_FLAKE8']="--config=${PYTHON_FLAKE8_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PYTHON_ISORT']="--check --diff --sp ${PYTHON_ISORT_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['PYTHON_MYPY']="--config-file ${PYTHON_MYPY_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['R']=""
LINTER_DEFAULT_OPTIONS_ARRAY['RAKU']=""
LINTER_DEFAULT_OPTIONS_ARRAY['RUBY']="-c ${RUBY_LINTER_RULES} --force-exclusion"
LINTER_DEFAULT_OPTIONS_ARRAY['RUST_2015']="--check --edition 2015"
LINTER_DEFAULT_OPTIONS_ARRAY['RUST_2018']="--check --edition 2018"
LINTER_DEFAULT_OPTIONS_ARRAY['RUST_CLIPPY']=""
LINTER_DEFAULT_OPTIONS_ARRAY['SHELL_SHFMT']="-d"
LINTER_DEFAULT_OPTIONS_ARRAY['SNAKEMAKE_LINT']="--lint -s"
LINTER_DEFAULT_OPTIONS_ARRAY['SNAKEMAKE_SNAKEFMT']="--config ${SNAKEMAKE_SNAKEFMT_LINTER_RULES} --check --compact-diff"
LINTER_DEFAULT_OPTIONS_ARRAY['STATES']="--json-path"
LINTER_DEFAULT_OPTIONS_ARRAY['SQL']="--config ${SQL_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['TEKTON']=""
LINTER_DEFAULT_OPTIONS_ARRAY['TERRAFORM']="-c ${TERRAFORM_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['TERRAFORM_TERRASCAN']="scan --iac-type terraform --policy-type all --iac-file"
LINTER_DEFAULT_OPTIONS_ARRAY['TERRAGRUNT']="hclfmt --terragrunt-check --terragrunt-log-level error --terragrunt-hclfmt-file"
LINTER_DEFAULT_OPTIONS_ARRAY['TSX']="--no-eslintrc -c ${TSX_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['TYPESCRIPT_ES']="--no-eslintrc -c ${TYPESCRIPT_ES_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['TYPESCRIPT_STANDARD']="--parser @typescript-eslint/parser --plugin @typescript-eslint/eslint-plugin ${TYPESCRIPT_STANDARD_LINTER_RULES}"
LINTER_DEFAULT_OPTIONS_ARRAY['XML']=""
LINTER_DEFAULT_OPTIONS_ARRAY['YAML']="-c ${YAML_LINTER_RULES}"

# Some linters don't support options
if [ -n "${BASH_EXEC_LINTER_COMMAND_OPTIONS}" ]; then
  warn "bash-exec doesn't support options. You specified the following options with the BASH_EXEC_LINTER_COMMAND_OPTIONS variable: ${BASH_EXEC_LINTER_COMMAND_OPTIONS}. Don't set the BASH_EXEC_LINTER_COMMAND_OPTIONS variable."
fi

# Don't break compatibility with KUBERNETES_KUBEVAL_OPTIONS
if [ -n "${KUBERNETES_KUBEVAL_OPTIONS}" ]; then
  warn "The KUBERNETES_KUBEVAL_OPTIONS variable is deprecated, and will be removed in a next release. Use KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS instead."

  if [ -n "${KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS}" ]; then
    error "You specified both KUBERNETES_KUBEVAL_OPTIONS and KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS. This is not supported. KUBERNETES_KUBEVAL_OPTIONS is deprecated, don't use it. Use KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS only."
    fatal "[KUBERNETES_KUBEVAL_OPTIONS: ${KUBERNETES_KUBEVAL_OPTIONS}, KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS: ${KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS}]"
  fi

  # Add the default values to ensure backward compatibility
  warn "Setting KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS for you to the default options for Kubeval (${LINTER_DEFAULT_OPTIONS_ARRAY["KUBERNETES_KUBEVAL"]}), plus the options you provided with KUBERNETES_KUBEVAL_OPTIONS (${KUBERNETES_KUBEVAL_OPTIONS}), to ensure full backward compatibility."
  KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS="${LINTER_DEFAULT_OPTIONS_ARRAY["KUBERNETES_KUBEVAL"]} ${KUBERNETES_KUBEVAL_OPTIONS}"
  export KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS
  unset KUBERNETES_KUBEVAL_OPTIONS
fi

# Special case for markdownlint
if [ -n "${MARKDOWN_CUSTOM_RULE_GLOBS}" ]; then
  warn "The MARKDOWN_CUSTOM_RULE_GLOBS variable is deprecated, and will be removed in a next release. Use MARKDOWN_LINTER_COMMAND_OPTIONS instead."

  if [ -n "${MARKDOWN_LINTER_COMMAND_OPTIONS}" ]; then
    error "You specified both MARKDOWN_CUSTOM_RULE_GLOBS and MARKDOWN_LINTER_COMMAND_OPTIONS. This is not supported. MARKDOWN_CUSTOM_RULE_GLOBS is deprecated, don't use it. Use MARKDOWN_LINTER_COMMAND_OPTIONS only."
    fatal "[MARKDOWN_CUSTOM_RULE_GLOBS: ${MARKDOWN_CUSTOM_RULE_GLOBS}, MARKDOWN_LINTER_COMMAND_OPTIONS: ${MARKDOWN_LINTER_COMMAND_OPTIONS}]"
  fi

  MARKDOWN_LINTER_COMMAND_OPTIONS=
  warn "super-linter parses the value of MARKDOWN_CUSTOM_RULE_GLOBS to build the options list for markdownlint, adding the necessary command switches (such as -r). When you migrate to MARKDOWN_LINTER_COMMAND_OPTIONS, it's YOUR responsibility to correctly build the options list."
  IFS="," read -r -a MARKDOWN_CUSTOM_RULE_GLOBS_ARRAY <<<"${MARKDOWN_CUSTOM_RULE_GLOBS}"
  for glob in "${MARKDOWN_CUSTOM_RULE_GLOBS_ARRAY[@]}"; do
    if [ -z "${LINTER_RULES_PATH}" ]; then
      MARKDOWN_LINTER_COMMAND_OPTIONS="${MARKDOWN_LINTER_COMMAND_OPTIONS} -r ${GITHUB_WORKSPACE}/${glob}"
    else
      MARKDOWN_LINTER_COMMAND_OPTIONS="${MARKDOWN_LINTER_COMMAND_OPTIONS} -r ${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${glob}"
    fi
  done
  export MARKDOWN_LINTER_COMMAND_OPTIONS
  unset MARKDOWN_CUSTOM_RULE_GLOBS
fi

for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  debug "Loading command options for ${LANGUAGE}"
  eval "GetLinterOptions \"${LANGUAGE}\" \"${LINTER_DEFAULT_OPTIONS_ARRAY["${LANGUAGE}"]}\""
done

##########################
# Define linter commands #
##########################
declare -A LINTER_COMMANDS_ARRAY
LINTER_COMMANDS_ARRAY['ANSIBLE']="ansible-lint ${ANSIBLE_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['ARM']="Import-Module ${ARM_TTK_PSD1} ; ${ARM_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['BASH']="shellcheck ${BASH_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['BASH_EXEC']="bash-exec"
LINTER_COMMANDS_ARRAY['CLOJURE']="clj-kondo ${CLOJURE_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['CLOUDFORMATION']="cfn-lint ${CLOUDFORMATION_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['COFFEESCRIPT']="coffeelint ${COFFEESCRIPT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['CPP']="cpplint ${CPP_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['CSHARP']="dotnet-format ${CSHARP_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['CSS']="stylelint ${CSS_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['DART']="dartanalyzer ${DART_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['DOCKERFILE']="dockerfilelint ${DOCKERFILE_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['DOCKERFILE_HADOLINT']="hadolint ${DOCKERFILE_HADOLINT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['EDITORCONFIG']="editorconfig-checker ${EDITORCONFIG_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['ENV']="dotenv-linter ${ENV_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['GHERKIN']="gherkin-lint ${GHERKIN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['GO']="golangci-lint ${GO_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['GROOVY']="npm-groovy-lint ${GROOVY_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['HTML']="htmlhint ${HTML_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JAVA']="java -jar /usr/bin/checkstyle ${JAVA_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JAVASCRIPT_ES']="eslint ${JAVASCRIPT_ES_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JAVASCRIPT_STANDARD']="standard ${JAVASCRIPT_STANDARD_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JAVASCRIPT_PRETTIER']="prettier ${JAVASCRIPT_PRETTIER_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JSCPD']="jscpd ${JSCPD_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JSON']="jsonlint ${JSON_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JSONC']="eslint ${JSONC_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['JSX']="eslint ${JSX_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['KOTLIN']="ktlint ${KOTLIN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['KUBERNETES_KUBEVAL']="kubeval ${KUBERNETES_KUBEVAL_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['LATEX']="chktex ${LATEX_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['LUA']="luacheck ${LUA_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['MARKDOWN']="markdownlint ${MARKDOWN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['OPENAPI']="spectral ${OPENAPI_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PERL']="perlcritic ${PERL_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PHP_BUILTIN']="php ${PHP_BUILTIN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PHP_PHPCS']="phpcs ${PHP_PHPCS_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PHP_PHPSTAN']="phpstan ${PHP_PHPSTAN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PHP_PSALM']="psalm ${PHP_PSALM_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['POWERSHELL']="Invoke-ScriptAnalyzer ${POWERSHELL_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PROTOBUF']="protolint ${PROTOBUF_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PYTHON_BLACK']="black ${PYTHON_BLACK_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PYTHON_PYLINT']="pylint ${PYTHON_PYLINT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PYTHON_FLAKE8']="flake8 ${PYTHON_FLAKE8_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PYTHON_ISORT']="isort ${PYTHON_ISORT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['PYTHON_MYPY']="mypy ${PYTHON_MYPY_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['R']="lintr ${R_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['RAKU']="raku ${RAKU_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['RUBY']="rubocop ${RUBY_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['RUST_2015']="rustfmt ${RUST_2015_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['RUST_2018']="rustfmt ${RUST_2018_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['RUST_CLIPPY']="clippy ${RUST_CLIPPY_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['SHELL_SHFMT']="shfmt ${SHELL_SHFMT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['SNAKEMAKE_LINT']="snakemake ${SNAKEMAKE_LINT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['SNAKEMAKE_SNAKEFMT']="snakefmt ${SNAKEMAKE_SNAKEFMT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['STATES']="asl-validator ${STATES_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['SQL']="sql-lint ${SQL_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TEKTON']="tekton-lint ${TEKTON_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TERRAFORM']="tflint ${TERRAFORM_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TERRAFORM_TERRASCAN']="terrascan ${TERRAFORM_TERRASCAN_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TERRAGRUNT']="terragrunt ${TERRAGRUNT_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TSX']="eslint ${TSX_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TYPESCRIPT_ES']="eslint ${TYPESCRIPT_ES_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['TYPESCRIPT_STANDARD']="standard ${TYPESCRIPT_STANDARD_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['XML']="xmllint ${XML_LINTER_COMMAND_OPTIONS}"
LINTER_COMMANDS_ARRAY['YAML']="yamllint ${YAML_LINTER_COMMAND_OPTIONS}"

debug "--- Linter commands ---"
debug "-----------------------"
for i in "${!LINTER_COMMANDS_ARRAY[@]}"; do
  debug "Linter key: $i, command: ${LINTER_COMMANDS_ARRAY[$i]}"
done
debug "---------------------------------------------"

#################################
# Check for SSL cert and update #
#################################
CheckSSLCert

###########################################
# Build the list of files for each linter #
###########################################
BuildFileList "${VALIDATE_ALL_CODEBASE}" "${TEST_CASE_RUN}" "${ANSIBLE_DIRECTORY}"

###############
# Run linters #
###############
EDITORCONFIG_FILE_PATH="${GITHUB_WORKSPACE}"/.editorconfig

####################################
# Print ENV before running linters #
####################################
debug "--- ENV (before running linters) ---"
debug "------------------------------------"
PRINTENV=$(printenv | sort)
debug "ENV:"
debug "${PRINTENV}"
debug "------------------------------------"

for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  debug "Running linter for the ${LANGUAGE} language..."
  VALIDATE_LANGUAGE_VARIABLE_NAME="VALIDATE_${LANGUAGE}"
  debug "Setting VALIDATE_LANGUAGE_VARIABLE_NAME to ${VALIDATE_LANGUAGE_VARIABLE_NAME}..."
  VALIDATE_LANGUAGE_VARIABLE_VALUE="${!VALIDATE_LANGUAGE_VARIABLE_NAME}"
  debug "Setting VALIDATE_LANGUAGE_VARIABLE_VALUE to ${VALIDATE_LANGUAGE_VARIABLE_VALUE}..."

  if [ "${VALIDATE_LANGUAGE_VARIABLE_VALUE}" = "true" ]; then
    # Check if we need an .editorconfig file
    # shellcheck disable=SC2153
    if [ "${LANGUAGE}" = "EDITORCONFIG" ] || [ "${LANGUAGE}" = "SHELL_SHFMT" ]; then
      if [ -e "${EDITORCONFIG_FILE_PATH}" ]; then
        debug "Found an EditorConfig file at ${EDITORCONFIG_FILE_PATH}"
      else
        debug "No .editorconfig found at: $EDITORCONFIG_FILE_PATH. Skipping ${LANGUAGE} linting..."
        continue
      fi
    elif [ "${LANGUAGE}" = "R" ] && [ ! -f "${GITHUB_WORKSPACE}/.lintr" ] && ((${#FILE_ARRAY_R[@]})); then
      info "No .lintr configuration file found, using defaults."
      cp "$R_LINTER_RULES" "$GITHUB_WORKSPACE"
    # Check if there's local configuration for the Raku linter
    elif [ "${LANGUAGE}" = "RAKU" ] && [ -e "${GITHUB_WORKSPACE}/META6.json" ]; then
      cd "${GITHUB_WORKSPACE}" && zef install --deps-only --/test .
    fi

    LINTER_NAME="${LINTER_NAMES_ARRAY["${LANGUAGE}"]}"
    if [ -z "${LINTER_NAME}" ]; then
      fatal "Cannot find the linter name for ${LANGUAGE} language."
    else
      debug "Setting LINTER_NAME to ${LINTER_NAME}..."
    fi

    LINTER_COMMAND="${LINTER_COMMANDS_ARRAY["${LANGUAGE}"]}"
    if [ -z "${LINTER_COMMAND}" ]; then
      fatal "Cannot find the linter command for ${LANGUAGE} language."
    else
      debug "Setting LINTER_COMMAND to ${LINTER_COMMAND}..."
    fi

    FILE_ARRAY_VARIABLE_NAME="FILE_ARRAY_${LANGUAGE}"
    debug "Setting FILE_ARRAY_VARIABLE_NAME to ${FILE_ARRAY_VARIABLE_NAME}..."

    # shellcheck disable=SC2125
    LANGUAGE_FILE_ARRAY="${FILE_ARRAY_VARIABLE_NAME}"[@]
    debug "${FILE_ARRAY_VARIABLE_NAME} file array contents: ${!LANGUAGE_FILE_ARRAY}"

    debug "Invoking ${LINTER_NAME} linter. TEST_CASE_RUN: ${TEST_CASE_RUN}"
    LintCodebase "${LANGUAGE}" "${LINTER_NAME}" "${LINTER_COMMAND}" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${TEST_CASE_RUN}" "${!LANGUAGE_FILE_ARRAY}"
  fi
done

##########
# Footer #
##########
Footer
