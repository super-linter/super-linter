#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter (Lint all the code) @admiralawkbar ####################
################################################################################
################################################################################

#########################
# Source Function Files #
#########################
# shellcheck source=/dev/null
source /action/lib/log.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/buildFileList.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/validation.sh # Source the function script(s)
# shellcheck source=/dev/null
source /action/lib/worker.sh # Source the function script(s)

###########
# GLOBALS #
###########
# Default Vars
DEFAULT_RULES_LOCATION='/action/lib/.automation' # Default rules files location
GITHUB_API_URL='https://api.github.com'          # GitHub API root url
# Ansible Vars
ANSIBLE_FILE_NAME='.ansible-lint.yml'                                 # Name of the file
ANSIBLE_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${ANSIBLE_FILE_NAME}" # Path to the Ansible lint rules
# Azure Resource Manager Vars
ARM_FILE_NAME='.arm-ttk.psd1'                                 # Name of the file
ARM_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${ARM_FILE_NAME}" # Path to the ARM lint rules
# Cloudformation Vars
CLOUDFORMATION_FILE_NAME='.cfnlintrc.yml'                                           # Name of the file
CLOUDFORMATION_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${CLOUDFORMATION_FILE_NAME}" # Path to the cloudformation lint rules
# Clojure Vars
CLOJURE_FILE_NAME='.clj-kondo/config.edn'                             # Name of the file
CLOJURE_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${CLOJURE_FILE_NAME}" # Path to the Clojure lint rules
# Coffee Vars
COFFEESCRIPT_FILE_NAME='.coffee-lint.json'                                      # Name of the file
COFFEESCRIPT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${COFFEESCRIPT_FILE_NAME}" # Path to the coffeescript lint rules
# CSS Vars
CSS_FILE_NAME="${CSS_FILE_NAME:-.stylelintrc.json}"           # Name of the file
CSS_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${CSS_FILE_NAME}" # Path to the CSS lint rules
# Dart Vars
DART_FILE_NAME='analysis_options.yml'                           # Name of the file
DART_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${DART_FILE_NAME}" # Path to the DART lint rules
# Dockerfile Vars
DOCKERFILE_FILE_NAME='.dockerfilelintrc'                                    # Name of the file
DOCKERFILE_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${DOCKERFILE_FILE_NAME}" # Path to the Docker lint rules
# Dockerfile Hadolint Vars
DOCKERFILE_HADOLINT_FILE_NAME="${DOCKERFILE_HADOLINT_FILE_NAME:-.hadolint.yml}"               # Name of the file
DOCKERFILE_HADOLINT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${DOCKERFILE_HADOLINT_FILE_NAME}" # Path to the Docker lint rules
# Golang Vars
GO_FILE_NAME='.golangci.yml'                                # Name of the file
GO_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${GO_FILE_NAME}" # Path to the Go lint rules
# Groovy Vars
GROOVY_FILE_NAME='.groovylintrc.json'                               # Name of the file
GROOVY_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${GROOVY_FILE_NAME}" # Path to the Groovy lint rules
# HTML Vars
HTML_FILE_NAME='.htmlhintrc'                                    # Name of the file
HTML_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${HTML_FILE_NAME}" # Path to the HTML lint rules
# Java Vars
JAVA_FILE_NAME="sun_checks.xml"                                 # Name of the Java config file
JAVA_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${JAVA_FILE_NAME}" # Path to the Java lint rules
# Javascript Vars
JAVASCRIPT_FILE_NAME="${JAVASCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"          # Name of the file
JAVASCRIPT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${JAVASCRIPT_FILE_NAME}" # Path to the Javascript lint rules
JAVASCRIPT_STANDARD_LINTER_RULES=''                                         # ENV string to pass when running js standard
# Default linter path
LINTER_RULES_PATH="${LINTER_RULES_PATH:-.github/linters}" # Linter Path Directory
# LaTeX Vars
LATEX_FILE_NAME='.chktexrc'                                       # Name of the file
LATEX_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${LATEX_FILE_NAME}" # Path to the Latex lint rules
# Lua Vars
LUA_FILE_NAME='.luacheckrc'                                   # Name of the file
LUA_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${LUA_FILE_NAME}" # Path to the Lua lint rules
# MD Vars
MARKDOWN_FILE_NAME="${MARKDOWN_CONFIG_FILE:-.markdown-lint.yml}"        # Name of the file
MARKDOWN_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${MARKDOWN_FILE_NAME}" # Path to the markdown lint rules
# OpenAPI Vars
OPENAPI_FILE_NAME='.openapirc.yml'                                    # Name of the file
OPENAPI_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${OPENAPI_FILE_NAME}" # Path to the OpenAPI lint rules
# PHPCS Vars
PHP_PHPCS_FILE_NAME='phpcs.xml'                                     # Name of the file
PHP_PHPCS_LINTER_RULES="${GITHUB_WORKSPACE}/${PHP_PHPCS_FILE_NAME}" # Path to the PHP CodeSniffer lint rules in the repository
if [ ! -f "$PHP_PHPCS_LINTER_RULES" ]; then
  PHP_PHPCS_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PHP_PHPCS_FILE_NAME}" # Path to the PHP CodeSniffer lint rules
fi
# PHPStan Vars
PHP_PHPSTAN_FILE_NAME='phpstan.neon'                                    # Name of the file
PHP_PHPSTAN_LINTER_RULES="${GITHUB_WORKSPACE}/${PHP_PHPSTAN_FILE_NAME}" # Path to the PHPStan lint rules in the repository
if [ ! -f "$PHP_PHPSTAN_LINTER_RULES" ]; then
  PHP_PHPSTAN_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PHP_PHPSTAN_FILE_NAME}" # Path to the PHPStan lint rules
fi
# Psalm Vars
PHP_PSALM_FILE_NAME='psalm.xml'                                     # Name of the file
PHP_PSALM_LINTER_RULES="${GITHUB_WORKSPACE}/${PHP_PSALM_FILE_NAME}" # Path to the Psalm lint rules in the repository
if [ ! -f "$PHP_PSALM_LINTER_RULES" ]; then
  PHP_PSALM_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PHP_PSALM_FILE_NAME}" # Path to the Psalm lint rules
fi
# Powershell Vars
POWERSHELL_FILE_NAME='.powershell-psscriptanalyzer.psd1'                    # Name of the file
POWERSHELL_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${POWERSHELL_FILE_NAME}" # Path to the Powershell lint rules
# Protocol Buffers Vars
PROTOBUF_FILE_NAME='.protolintrc.yml'                                   # Name of the file
PROTOBUF_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PROTOBUF_FILE_NAME}" # Path to the Protocol Buffers lint rules
# Python Vars
PYTHON_PYLINT_FILE_NAME="${PYTHON_PYLINT_CONFIG_FILE:-.python-lint}"              # Name of the file
PYTHON_PYLINT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PYTHON_PYLINT_FILE_NAME}" # Path to the python lint rules
PYTHON_FLAKE8_FILE_NAME="${PYTHON_FLAKE8_CONFIG_FILE:-.flake8}"                   # Name of the file
PYTHON_FLAKE8_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PYTHON_FLAKE8_FILE_NAME}" # Path to the python lint rules
PYTHON_BLACK_FILE_NAME="${PYTHON_BLACK_CONFIG_FILE:-.python-black}"               # Name of the file
PYTHON_BLACK_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${PYTHON_BLACK_FILE_NAME}"   # Path to the python lint rules
# R Vars
R_FILE_NAME='.lintr'                                      # Name of the file
R_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${R_FILE_NAME}" # Path to the R lint rules
# Ruby Vars
RUBY_FILE_NAME="${RUBY_CONFIG_FILE:-.ruby-lint.yml}"            # Name of the file
RUBY_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${RUBY_FILE_NAME}" # Path to the ruby lint rules
# Snakemake Vars
SNAKEMAKE_FILE_NAME="${SNAKEMAKE_CONFIG_FILE:-.snakefmt.toml}"                     # Name of the file
SNAKEMAKE_SNAKEFMT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${SNAKEMAKE_FILE_NAME}" # Path to the snakemake lint rules
# SQL Vars
SQL_FILE_NAME=".sql-config.json"                              # Name of the file
SQL_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${SQL_FILE_NAME}" # Path to the SQL lint rules
# Terraform Vars
TERRAFORM_FILE_NAME='.tflint.hcl'                                         # Name of the file
TERRAFORM_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${TERRAFORM_FILE_NAME}" # Path to the Terraform lint rules
# Typescript Vars
TYPESCRIPT_FILE_NAME="${TYPESCRIPT_ES_CONFIG_FILE:-.eslintrc.yml}"          # Name of the file
TYPESCRIPT_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${TYPESCRIPT_FILE_NAME}" # Path to the Typescript lint rules
TYPESCRIPT_STANDARD_LINTER_RULES=''                                         # ENV string to pass when running js standard
# Version File info
VERSION_FILE='/action/lib/linter-versions.txt' # File to store linter versions
# YAML Vars
YAML_FILE_NAME="${YAML_CONFIG_FILE:-.yaml-lint.yml}"            # Name of the file
YAML_LINTER_RULES="${DEFAULT_RULES_LOCATION}/${YAML_FILE_NAME}" # Path to the yaml lint rules

#############################
# Language array for prints #
#############################
LANGUAGE_ARRAY=('ANSIBLE' 'ARM' 'BASH' 'BASH_EXEC' 'CLOUDFORMATION' 'CLOJURE' 'COFFEESCRIPT' 'CSHARP' 'CSS'
  'DART' 'DOCKERFILE' 'DOCKERFILE_HADOLINT' 'EDITORCONFIG' 'ENV' 'GO' 'GROOVY' 'HTML'
  'JAVA' 'JAVASCRIPT_ES' 'JAVASCRIPT_STANDARD' 'JSON' 'JSX' 'KUBERNETES_KUBEVAL' 'KOTLIN' 'LATEX' 'LUA' 'MARKDOWN'
  'OPENAPI' 'PERL' 'PHP_BUILTIN' 'PHP_PHPCS' 'PHP_PHPSTAN' 'PHP_PSALM' 'POWERSHELL'
  'PROTOBUF' 'PYTHON_BLACK' 'PYTHON_PYLINT' 'PYTHON_FLAKE8' 'R' 'RAKU' 'RUBY' 'SHELL_SHFMT' 'STATES' 'SQL' 'TERRAFORM'
  'TERRAFORM_TERRASCAN' 'TSX' 'TYPESCRIPT_ES' 'TYPESCRIPT_STANDARD' 'XML' 'YAML')

############################################
# Array for all languages that were linted #
############################################
LINTED_LANGUAGES_ARRAY=() # Will be filled at run time with all languages that were linted

###################
# GitHub ENV Vars #
###################
ANSIBLE_DIRECTORY="${ANSIBLE_DIRECTORY}"                             # Ansible Directory
DEFAULT_BRANCH="${DEFAULT_BRANCH:-master}"                           # Default Git Branch to use (master by default)
DISABLE_ERRORS="${DISABLE_ERRORS}"                                   # Boolean to enable warning-only output without throwing errors
FILTER_REGEX_INCLUDE="${FILTER_REGEX_INCLUDE}"                       # RegExp defining which files will be processed by linters (all by default)
FILTER_REGEX_EXCLUDE="${FILTER_REGEX_EXCLUDE}"                       # RegExp defining which files will be excluded from linting (none by default)
GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"                             # Github Event Path
GITHUB_REPOSITORY="${GITHUB_REPOSITORY}"                             # GitHub Org/Repo passed from system
GITHUB_RUN_ID="${GITHUB_RUN_ID}"                                     # GitHub RUn ID to point to logs
GITHUB_SHA="${GITHUB_SHA}"                                           # GitHub sha from the commit
GITHUB_TOKEN="${GITHUB_TOKEN}"                                       # GitHub Token passed from environment
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"                               # Github Workspace
KUBERNETES_DIRECTORY="${KUBERNETES_DIRECTORY}"                       # Kubernetes directory
LOG_FILE="${LOG_FILE:-super-linter.log}"                             # Default log file name (located in GITHUB_WORKSPACE folder)
LOG_LEVEL="${LOG_LEVEL:-VERBOSE}"                                    # Default log level (VERBOSE, DEBUG, TRACE)
MULTI_STATUS="${MULTI_STATUS:-true}"                                 # Multiple status are created for each check ran
TEST_CASE_RUN="${TEST_CASE_RUN}"                                     # Boolean to validate only test cases
VALIDATE_ALL_CODEBASE="${VALIDATE_ALL_CODEBASE}"                     # Boolean to validate all files
VALIDATE_ANSIBLE="${VALIDATE_ANSIBLE}"                               # Boolean to validate language
VALIDATE_ARM="${VALIDATE_ARM}"                                       # Boolean to validate language
VALIDATE_BASH="${VALIDATE_BASH}"                                     # Boolean to validate language
VALIDATE_BASH_EXEC="${VALIDATE_BASH_EXEC}"                           # Boolean to validate language
VALIDATE_CLOUDFORMATION="${VALIDATE_CLOUDFORMATION}"                 # Boolean to validate language
VALIDATE_CLOJURE="${VALIDATE_CLOJURE}"                               # Boolean to validate language
VALIDATE_COFFEE="${VALIDATE_COFFEE}"                                 # Boolean to validate language
VALIDATE_CSHARP="${VALIDATE_CSHARP}"                                 # Boolean to validate language
VALIDATE_CSS="${VALIDATE_CSS}"                                       # Boolean to validate language
VALIDATE_DART="${VALIDATE_DART}"                                     # Boolean to validate language
VALIDATE_DOCKERFILE="${VALIDATE_DOCKERFILE}"                         # Boolean to validate language
VALIDATE_DOCKERFILE_HADOLINT="${VALIDATE_DOCKERFILE_HADOLINT}"       # Boolean to validate language
VALIDATE_EDITORCONFIG="${VALIDATE_EDITORCONFIG}"                     # Boolean to validate files with editorconfig
VALIDATE_ENV="${VALIDATE_ENV}"                                       # Boolean to validate language
VALIDATE_GO="${VALIDATE_GO}"                                         # Boolean to validate language
VALIDATE_GROOVY="${VALIDATE_GROOVY}"                                 # Boolean to validate language
VALIDATE_HTML="${VALIDATE_HTML}"                                     # Boolean to validate language
VALIDATE_JAVA="${VALIDATE_JAVA}"                                     # Boolean to validate language
VALIDATE_JAVASCRIPT_ES="${VALIDATE_JAVASCRIPT_ES}"                   # Boolean to validate language
VALIDATE_JAVASCRIPT_STANDARD="${VALIDATE_JAVASCRIPT_STANDARD}"       # Boolean to validate language
VALIDATE_JSON="${VALIDATE_JSON}"                                     # Boolean to validate language
VALIDATE_JSX="${VALIDATE_JSX}"                                       # Boolean to validate language
VALIDATE_KUBERNETES_KUBEVAL="${VALIDATE_KUBERNETES_KUBEVAL}"         # Boolean to validate language
VALIDATE_KOTLIN="${VALIDATE_KOTLIN}"                                 # Boolean to validate language
VALIDATE_LATEX="${VALIDATE_LATEX}"                                   # Boolean to validate language
VALIDATE_LUA="${VALIDATE_LUA}"                                       # Boolean to validate language
VALIDATE_MARKDOWN="${VALIDATE_MD:-}"                                 # Boolean to validate language
VALIDATE_OPENAPI="${VALIDATE_OPENAPI}"                               # Boolean to validate language
VALIDATE_PERL="${VALIDATE_PERL}"                                     # Boolean to validate language
VALIDATE_PHP_BUILTIN="${VALIDATE_PHP:-$VALIDATE_PHP_BUILTIN}"        # Boolean to validate language
VALIDATE_PHP_PHPCS="${VALIDATE_PHP_PHPCS}"                           # Boolean to validate language
VALIDATE_PHP_PHPSTAN="${VALIDATE_PHP_PHPSTAN}"                       # Boolean to validate language
VALIDATE_PHP_PSALM="${VALIDATE_PHP_PSALM}"                           # Boolean to validate language
VALIDATE_POWERSHELL="${VALIDATE_POWERSHELL}"                         # Boolean to validate language
VALIDATE_PYTHON_FLAKE8="${VALIDATE_PYTHON_FLAKE8}"                   # Boolean to validate language
VALIDATE_PYTHON_BLACK="${VALIDATE_PYTHON_BLACK}"                     # Boolean to validate language
VALIDATE_PYTHON_PYLINT="${VALIDATE_PYTHON:-$VALIDATE_PYTHON_PYLINT}" # Boolean to validate language
VALIDATE_R="${VALIDATE_R}"                                           # Boolean to validate language
VALIDATE_RAKU="${VALIDATE_RAKU}"                                     # Boolean to validate language
VALIDATE_RUBY="${VALIDATE_RUBY}"                                     # Boolean to validate language
VALIDATE_STATES="${VALIDATE_STATES}"                                 # Boolean to validate language
VALIDATE_SHELL_SHFMT="${VALIDATE_SHELL_SHFMT}"                       # Boolean to check Shell files against editorconfig
VALIDATE_SNAKEMAKE_LINT="${VALIDATE_SNAKEMAKE_LINT}"                 # Boolean to validate Snakefiles
VALIDATE_SNAKEMAKE_SNAKEFMT="${VALIDATE_SNAKEMAKE_SNAKEFMT}"         # Boolean to validate Snakefiles
VALIDATE_SQL="${VALIDATE_SQL}"                                       # Boolean to validate language
VALIDATE_TERRAFORM="${VALIDATE_TERRAFORM}"                           # Boolean to validate language
VALIDATE_TERRAFORM_TERRASCAN="${VALIDATE_TERRAFORM_TERRASCAN}"       # Boolean to validate language
VALIDATE_TSX="${VALIDATE_TSX}"                                       # Boolean to validate language
VALIDATE_TYPESCRIPT_ES="${VALIDATE_TYPESCRIPT_ES}"                   # Boolean to validate language
VALIDATE_TYPESCRIPT_STANDARD="${VALIDATE_TYPESCRIPT_STANDARD}"       # Boolean to validate language
VALIDATE_XML="${VALIDATE_XML}"                                       # Boolean to validate language
VALIDATE_YAML="${VALIDATE_YAML}"                                     # Boolean to validate language

##############
# Debug Vars #
##############
RUN_LOCAL="${RUN_LOCAL}"                              # Boolean to see if we are running locally
ACTIONS_RUNNER_DEBUG="${ACTIONS_RUNNER_DEBUG:-false}" # Boolean to see even more info (debug)

############
# Log Vars #
############
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

################
# Default Vars #
################
DEFAULT_VALIDATE_ALL_CODEBASE='true'                # Default value for validate all files
DEFAULT_WORKSPACE="${DEFAULT_WORKSPACE:-/tmp/lint}" # Default workspace if running locally
DEFAULT_RUN_LOCAL='false'                           # Default value for debugging locally
DEFAULT_TEST_CASE_RUN='false'                       # Flag to tell code to run only test cases
DEFAULT_IFS="${IFS}"                                # Get the Default IFS for updating

###############################################################
# Default Vars that are called in Subs and need to be ignored #
###############################################################
DEFAULT_DISABLE_ERRORS='false'                          # Default to enabling errors
export DEFAULT_DISABLE_ERRORS                           # Workaround SC2034
ERROR_ON_MISSING_EXEC_BIT="${ERROR_ON_MISSING_EXEC_BIT:-false}" # Default to report a warning if a shell script doesn't have the executable bit set to 1
export ERROR_ON_MISSING_EXEC_BIT
RAW_FILE_ARRAY=()                                       # Array of all files that were changed
export RAW_FILE_ARRAY                                   # Workaround SC2034
READ_ONLY_CHANGE_FLAG=0                                 # Flag set to 1 if files changed are not txt or md
export READ_ONLY_CHANGE_FLAG                            # Workaround SC2034
TEST_CASE_FOLDER='.automation/test'                     # Folder for test cases we should always ignore
export TEST_CASE_FOLDER                                 # Workaround SC2034
WARNING_ARRAY_TEST=()                                   # Array of warning linters that did not have an expected test result.
export WARNING_ARRAY_TEST                               # Workaround SC2034

##############
# Format     #
##############
OUTPUT_FORMAT="${OUTPUT_FORMAT}"                            # Output format to be generated. Default none
OUTPUT_FOLDER="${OUTPUT_FOLDER:-super-linter.report}"       # Folder where the reports are generated. Default super-linter.report
OUTPUT_DETAILS="${OUTPUT_DETAILS:-simpler}"                 # What level of details. (simpler or detailed). Default simpler

##########################
# Array of changed files #
##########################
FILE_ARRAY_ARM=()                 # Array of files to check
FILE_ARRAY_BASH=()                # Array of files to check
FILE_ARRAY_CLOUDFORMATION=()      # Array of files to check
FILE_ARRAY_CLOJURE=()             # Array of files to check
FILE_ARRAY_COFFEESCRIPT=()        # Array of files to check
FILE_ARRAY_CSHARP=()              # Array of files to check
FILE_ARRAY_CSS=()                 # Array of files to check
FILE_ARRAY_DART=()                # Array of files to check
FILE_ARRAY_DOCKERFILE=()          # Array of files to check
FILE_ARRAY_ENV=()                 # Array of files to check
FILE_ARRAY_GO=()                  # Array of files to check
FILE_ARRAY_GROOVY=()              # Array of files to check
FILE_ARRAY_HTML=()                # Array of files to check
FILE_ARRAY_JAVA=()                # Array of files to check
FILE_ARRAY_JAVASCRIPT_ES=()       # Array of files to check
FILE_ARRAY_JAVASCRIPT_STANDARD=() # Array of files to check
FILE_ARRAY_JSON=()                # Array of files to check
FILE_ARRAY_JSX=()                 # Array of files to check
FILE_ARRAY_KUBERNETES=()
FILE_ARRAY_KOTLIN=()              # Array of files to check
FILE_ARRAY_LATEX=()               # Array of files to check
FILE_ARRAY_LUA=()                 # Array of files to check
FILE_ARRAY_MARKDOWN=()            # Array of files to check
FILE_ARRAY_OPENAPI=()             # Array of files to check
FILE_ARRAY_PERL=()                # Array of files to check
FILE_ARRAY_PHP_BUILTIN=()         # Array of files to check
FILE_ARRAY_PHP_PHPCS=()           # Array of files to check
FILE_ARRAY_PHP_PHPSTAN=()         # Array of files to check
FILE_ARRAY_PHP_PSALM=()           # Array of files to check
FILE_ARRAY_POWERSHELL=()          # Array of files to check
FILE_ARRAY_PROTOBUF=()            # Array of files to check
FILE_ARRAY_PYTHON_BLACK=()        # Array of files to check
FILE_ARRAY_PYTHON_PYLINT=()       # Array of files to check
FILE_ARRAY_PYTHON_FLAKE8=()       # Array of files to check
FILE_ARRAY_R=()                   # Array of files to check
FILE_ARRAY_RAKU=()                # Array of files to check
FILE_ARRAY_RUBY=()                # Array of files to check
FILE_ARRAY_STATES=()              # Array of files to check
FILE_ARRAY_SQL=()                 # Array of files to check
FILE_ARRAY_TERRAFORM=()           # Array of files to check
FILE_ARRAY_TSX=()                 # Array of files to check
FILE_ARRAY_TYPESCRIPT_ES=()       # Array of files to check
FILE_ARRAY_TYPESCRIPT_STANDARD=() # Array of files to check
FILE_ARRAY_XML=()                 # Array of files to check
FILE_ARRAY_YAML=()                # Array of files to check

############
# Counters #
############
ERRORS_FOUND_ANSIBLE=0                  # Count of errors found
export ERRORS_FOUND_ANSIBLE             # Workaround SC2034
ERRORS_FOUND_ARM=0                      # Count of errors found
export ERRORS_FOUND_ARM                 # Workaround SC2034
ERRORS_FOUND_BASH=0                     # Count of errors found
export ERRORS_FOUND_BASH                # Workaround SC2034
ERRORS_FOUND_BASH_EXEC=0                # Count of errors found
export ERRORS_FOUND_BASH_EXEC           # Workaround SC2034
ERRORS_FOUND_CLOUDFORMATION=0           # Count of errors found
export ERRORS_FOUND_CLOUDFORMATION      # Workaround SC2034
ERRORS_FOUND_CLOJURE=0                  # Count of errors found
export ERRORS_FOUND_CLOJURE             # Workaround SC2034
ERRORS_FOUND_CSHARP=0                   # Count of errors found
export ERRORS_FOUND_CSHARP              # Workaround SC2034
ERRORS_FOUND_CSS=0                      # Count of errors found
export ERRORS_FOUND_CSS                 # Workaround SC2034
ERRORS_FOUND_COFFEESCRIPT=0             # Count of errors found
export ERRORS_FOUND_COFFEESCRIPT        # Workaround SC2034
ERRORS_FOUND_DART=0                     # Count of errors found
export ERRORS_FOUND_DART                # Workaround SC2034
ERRORS_FOUND_DOCKERFILE=0               # Count of errors found
export ERRORS_FOUND_DOCKERFILE          # Workaround SC2034
ERRORS_FOUND_DOCKERFILE_HADOLINT=0      # Count of errors found
export ERRORS_FOUND_DOCKERFILE_HADOLINT # Workaround SC2034
ERRORS_FOUND_EDITORCONFIG=0             # Count of errors found
export ERRORS_FOUND_EDITORCONFIG        # Workaround SC2034
ERRORS_FOUND_ENV=0                      # Count of errors found
export ERRORS_FOUND_ENV                 # Workaround SC2034
ERRORS_FOUND_GO=0                       # Count of errors found
export ERRORS_FOUND_GO                  # Workaround SC2034
ERRORS_FOUND_GROOVY=0                   # Count of errors found
export ERRORS_FOUND_GROOVY              # Workaround SC2034
ERRORS_FOUND_HTML=0                     # Count of errors found
export ERRORS_FOUND_HTML                # Workaround SC2034
ERRORS_FOUND_JAVA=0                     # Count of errors found
export ERRORS_FOUND_JAVA                # Workaround SC2034
ERRORS_FOUND_JAVASCRIPT_STANDARD=0      # Count of errors found
export ERRORS_FOUND_JAVASCRIPT_STANDARD # Workaround SC2034
ERRORS_FOUND_JAVASCRIPT_ES=0            # Count of errors found
export ERRORS_FOUND_JAVASCRIPT_ES       # Workaround SC2034
ERRORS_FOUND_JSON=0                     # Count of errors found
export ERRORS_FOUND_JSON                # Workaround SC2034
ERRORS_FOUND_JSX=0                      # Count of errors found
export ERRORS_FOUND_JSX                 # Workaround SC2034
ERRORS_FOUND_KUBERNETES_KUBEVAL=0       # Count of errors found
export ERRORS_FOUND_KUBERNETES_KUBEVAL
ERRORS_FOUND_KOTLIN=0                   # Count of errors found
export ERRORS_FOUND_KOTLIN              # Workaround SC2034
ERRORS_FOUND_LATEX=0                    # Count of errors found
export ERRORS_FOUND_LATEX=0             # Workaround SC2034
ERRORS_FOUND_LUA=0                      # Count of errors found
export ERRORS_FOUND_LUA=0               # Workaround SC2034
ERRORS_FOUND_MARKDOWN=0                 # Count of errors found
export ERRORS_FOUND_MARKDOWN            # Workaround SC2034
ERRORS_FOUND_OPENAPI=0                  # Count of errors found
export ERRORS_FOUND_OPENAPI             # Workaround SC2034
ERRORS_FOUND_PERL=0                     # Count of errors found
export ERRORS_FOUND_PERL                # Workaround SC2034
ERRORS_FOUND_PHP_BUILTIN=0              # Count of errors found
export ERRORS_FOUND_PHP_BUILTIN         # Workaround SC2034
ERRORS_FOUND_PHP_PHPCS=0                # Count of errors found
export ERRORS_FOUND_PHP_PHPCS           # Workaround SC2034
ERRORS_FOUND_PHP_PHPSTAN=0              # Count of errors found
export ERRORS_FOUND_PHP_PHPSTAN         # Workaround SC2034
ERRORS_FOUND_PHP_PSALM=0                # Count of errors found
export ERRORS_FOUND_PHP_PSALM           # Workaround SC2034
ERRORS_FOUND_POWERSHELL=0               # Count of errors found
export ERRORS_FOUND_POWERSHELL          # Workaround SC2034
ERRORS_FOUND_PROTOBUF=0                 # Count of errors found
export ERRORS_FOUND_PROTOBUF            # Workaround SC2034
ERRORS_FOUND_PYTHON_BLACK=0             # Count of errors found
export ERRORS_FOUND_PYTHON_BLACK        # Workaround SC2034
ERRORS_FOUND_PYTHON_PYLINT=0            # Count of errors found
export ERRORS_FOUND_PYTHON_PYLINT       # Workaround SC2034
ERRORS_FOUND_PYTHON_FLAKE8=0            # Count of errors found
export ERRORS_FOUND_PYTHON_FLAKE8       # Workaround SC2034
ERRORS_FOUND_R=0                        # Count of errors found
export ERRORS_FOUND_R                   # Workaround SC2034
ERRORS_FOUND_RAKU=0                     # Count of errors found
export ERRORS_FOUND_RAKU                # Workaround SC2034
ERRORS_FOUND_RUBY=0                     # Count of errors found
export ERRORS_FOUND_RUBY                # Workaround SC2034
ERRORS_FOUND_SHELL_SHFMT=0              # Count of errors found
export ERRORS_FOUND_SHELL_SHFMT
ERRORS_FOUND_STATES=0                   # Count of errors found
export ERRORS_FOUND_STATES              # Workaround SC2034
ERRORS_FOUND_SQL=0                      # Count of errors found
export ERRORS_FOUND_SQL                 # Workaround SC2034
ERRORS_FOUND_TERRAFORM=0                # Count of errors found
export ERRORS_FOUND_TERRAFORM           # Workaround SC2034
ERRORS_FOUND_TERRAFORM_TERRASCAN=0      # Count of errors found
export ERRORS_FOUND_TERRAFORM_TERRASCAN # Workaround SC2034
ERRORS_FOUND_TSX=0                      # Count of errors found
export ERRORS_FOUND_TSX                 # Workaround SC2034
ERRORS_FOUND_TYPESCRIPT_STANDARD=0      # Count of errors found
export ERRORS_FOUND_TYPESCRIPT_STANDARD # Workaround SC2034
ERRORS_FOUND_TYPESCRIPT_ES=0            # Count of errors found
export ERRORS_FOUND_TYPESCRIPT_ES       # Workaround SC2034
ERRORS_FOUND_XML=0                      # Count of errors found
export ERRORS_FOUND_XML                 # Workaround SC2034
ERRORS_FOUND_YAML=0                     # Count of errors found
export ERRORS_FOUND_YAML                # Workaround SC2034

################################################################################
########################## FUNCTIONS BELOW #####################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  ###############################
  # Give them the possum action #
  ###############################
  /bin/bash /action/lib/possum.sh

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
#### Function GetLinterVersions ################################################
GetLinterVersions() {
  #########################
  # Print version headers #
  #########################
  debug "---------------------------------------------"
  debug "Linter Version Info:"

  ################################
  # Cat the linter versions file #
  ################################
  CAT_CMD=$(cat "${VERSION_FILE}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failure
    warn "Failed to view version file:[${VERSION_FILE}]"
  else
    # Success
    debug "${CAT_CMD}"
  fi

  #########################
  # Print version footers #
  #########################
  debug "---------------------------------------------"
}
################################################################################
#### Function GetLinterRules ###################################################
GetLinterRules() {
  # Need to validate the rules files exist

  ################
  # Pull in vars #
  ################
  LANGUAGE_NAME="${1}" # Name of the language were looking for
  debug "Getting linter rules for ${LANGUAGE_NAME}..."

  #######################################################
  # Need to create the variables for the real variables #
  #######################################################
  LANGUAGE_FILE_NAME="${LANGUAGE_NAME}_FILE_NAME"
  LANGUAGE_LINTER_RULES="${LANGUAGE_NAME}_LINTER_RULES"
  debug "Variable names for language file name: ${LANGUAGE_FILE_NAME}, language linter rules: ${LANGUAGE_LINTER_RULES}"

  ##########################
  # Get the file extension #
  ##########################
  FILE_EXTENSION=$(echo "${!LANGUAGE_FILE_NAME}" | rev | cut -d'.' -f1 | rev)
  FILE_NAME=$(basename "${!LANGUAGE_FILE_NAME}" ".${FILE_EXTENSION}")
  debug "${LANGUAGE_NAME} language rule file (${!LANGUAGE_FILE_NAME}) has ${FILE_NAME} name and ${FILE_EXTENSION} extension"

  ###############################
  # Set the secondary file name #
  ###############################
  SECONDARY_FILE_NAME=''

  #################################
  # Check for secondary file name #
  #################################
  if [[ $FILE_EXTENSION == 'yml' ]]; then
    # Need to see if yaml also exists
    SECONDARY_FILE_NAME="$FILE_NAME.yaml"
  elif [[ $FILE_EXTENSION == 'yaml' ]]; then
    # need to see if yml also exists
    SECONDARY_FILE_NAME="$FILE_NAME.yml"
  fi

  #####################################
  # Validate we have the linter rules #
  #####################################
  if [ -f "${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${!LANGUAGE_FILE_NAME}" ]; then
    info "----------------------------------------------"
    info "User provided file:[${!LANGUAGE_FILE_NAME}], setting rules file..."

    ########################################
    # Update the path to the file location #
    ########################################
    eval "${LANGUAGE_LINTER_RULES}=${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${!LANGUAGE_FILE_NAME}"
  else
    debug "  -> Codebase does NOT have file:[${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${!LANGUAGE_FILE_NAME}]"
    # Check if we have secondary name to check
    if [ -n "$SECONDARY_FILE_NAME" ]; then
      debug "${LANGUAGE_NAME} language rule file has a secondary rules file name to check: ${SECONDARY_FILE_NAME}"
      # We have a secondary name to validate
      if [ -f "${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${SECONDARY_FILE_NAME}" ]; then
        info "----------------------------------------------"
        info "User provided file:[${SECONDARY_FILE_NAME}], setting rules file..."

        ########################################
        # Update the path to the file location #
        ########################################
        eval "${LANGUAGE_LINTER_RULES}=${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${SECONDARY_FILE_NAME}"
      fi
    fi

    ########################################################
    # No user default provided, using the template default #
    ########################################################
    debug "  -> Codebase does NOT have file:[${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${!LANGUAGE_FILE_NAME}], nor file:[${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${SECONDARY_FILE_NAME}], using Default rules at:[${!LANGUAGE_LINTER_RULES}]"
  fi
}
################################################################################
#### Function GetStandardRules #################################################
GetStandardRules() {
  ################
  # Pull In Vars #
  ################
  LINTER="${1}" # Type: javascript | typescript

  #########################################################################
  # Need to get the ENV vars from the linter rules to run in command line #
  #########################################################################
  # Copy orig IFS to var
  ORIG_IFS="${IFS}"
  # Set the IFS to newline
  IFS=$'\n'

  #########################################
  # Get list of all environment variables #
  #########################################
  # Only env vars that are marked as true
  GET_ENV_ARRAY=()
  if [[ ${LINTER} == "javascript" ]]; then
    mapfile -t GET_ENV_ARRAY < <(yq .env "${JAVASCRIPT_LINTER_RULES}" | grep true)
  elif [[ ${LINTER} == "typescript" ]]; then
    mapfile -t GET_ENV_ARRAY < <(yq .env "${TYPESCRIPT_LINTER_RULES}" | grep true)
  fi

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # ERROR
    error "Failed to gain list of ENV vars to load!"
    fatal "[${GET_ENV_ARRAY[*]}]"
  fi

  ##########################
  # Set IFS back to normal #
  ##########################
  # Set IFS back to Orig
  IFS="${ORIG_IFS}"

  ######################
  # Set the env string #
  ######################
  ENV_STRING=''

  #############################
  # Pull out the envs to load #
  #############################
  for ENV in "${GET_ENV_ARRAY[@]}"; do
    #############################
    # remove spaces from return #
    #############################
    ENV="$(echo -e "${ENV}" | tr -d '[:space:]')"
    ################################
    # Get the env to add to string #
    ################################
    ENV="$(echo "${ENV}" | cut -d'"' -f2)"
    debug "ENV:[${ENV}]"
    ENV_STRING+="--env ${ENV} "
  done

  #########################################
  # Remove trailing and ending whitespace #
  #########################################
  if [[ ${LINTER} == "javascript" ]]; then
    JAVASCRIPT_STANDARD_LINTER_RULES="$(echo -e "${ENV_STRING}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  elif [[ ${LINTER} == "typescript" ]]; then
    TYPESCRIPT_STANDARD_LINTER_RULES="$(echo -e "${ENV_STRING}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  fi
}
################################################################################
#### Function DetectOpenAPIFile ################################################
DetectOpenAPIFile() {
  ################
  # Pull in vars #
  ################
  FILE="${1}"

  ###############################
  # Check the file for keywords #
  ###############################
  grep -E '"openapi":|"swagger":|^openapi:|^swagger:' "${FILE}" >/dev/null

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -eq 0 ]; then
    ########################
    # Found string in file #
    ########################
    return 0
  else
    ###################
    # No string match #
    ###################
    return 1
  fi
}
################################################################################
#### Function DetectARMFile ####################################################
DetectARMFile() {
  ################
  # Pull in vars #
  ################
  FILE="${1}" # Name of the file/path we are validating

  ###############################
  # Check the file for keywords #
  ###############################
  grep -E 'schema.management.azure.com' "${FILE}" >/dev/null

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -eq 0 ]; then
    ########################
    # Found string in file #
    ########################
    return 0
  else
    ###################
    # No string match #
    ###################
    return 1
  fi
}
################################################################################
#### Function DetectCloudFormationFile #########################################
DetectCloudFormationFile() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate

  # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-formats.html
  # AWSTemplateFormatVersion is optional
  #######################################
  # Check if file has AWS Template info #
  #######################################
  if grep -q 'AWSTemplateFormatVersion' "${FILE}" >/dev/null; then
    # Found it
    return 0
  fi

  #####################################
  # See if it contains AWS References #
  #####################################
  if grep -q -E '(AWS|Alexa|Custom)::' "${FILE}" >/dev/null; then
    # Found it
    return 0
  fi

  #####################################################
  # No identifiers of a CLOUDFORMATION template found #
  #####################################################
  return 1
}
################################################################################
#### Function DetectKubernetesFile #########################################
DetectKubernetesFile() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate
  debug "Checking if ${FILE} is a Kubernetes descriptor..."

  if grep -q -E '(apiVersion):' "${FILE}" >/dev/null; then
    debug "${FILE} is a Kubernetes descriptor"
    return 0
  fi

  debug "${FILE} is NOT a Kubernetes descriptor"
  return 1

}
################################################################################
#### Function DetectAWSStatesFIle ##############################################
DetectAWSStatesFIle() {
  ################
  # Pull in Vars #
  ################
  FILE="${1}" # File that we need to validate

  # https://states-language.net/spec.html#example
  ###############################
  # check if file has resources #
  ###############################
  if grep '"Resource": *"arn"*' "${FILE}"; then
    # Found it
    return 0
  fi

  #################################################
  # No identifiers of a AWS States Language found #
  #################################################
  return 1
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

    ################################
    # Set the report output folder #
    ################################
    REPORT_OUTPUT_FOLDER="${DEFAULT_WORKSPACE}/${OUTPUT_FOLDER}"

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
#### Function ValidatePowershellModules ########################################
function ValidatePowershellModules() {
  VALIDATE_PSSA_MODULE=$(pwsh -c "(Get-Module -Name PSScriptAnalyzer -ListAvailable | Select-Object -First 1).Name" 2>&1)
  # If module found, ensure Invoke-ScriptAnalyzer command is available
  if [[ ${VALIDATE_PSSA_MODULE} == "PSScriptAnalyzer" ]]; then
    VALIDATE_PSSA_CMD=$(pwsh -c "(Get-Command Invoke-ScriptAnalyzer | Select-Object -First 1).Name" 2>&1)
  else
    fatal "Failed to find module."
  fi

  #########################################
  # validate we found the script analyzer #
  #########################################
  if [[ ${VALIDATE_PSSA_CMD} != "Invoke-ScriptAnalyzer" ]]; then
    fatal "Failed to find module."
  fi

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Failed
    error "Failed find module [PSScriptAnalyzer] for [${LINTER_NAME}] in system!"
    fatal "[PSSA_MODULE ${VALIDATE_PSSA_MODULE}] [PSSA_CMD ${VALIDATE_PSSA_CMD}]"
  else
    # Success
    debug "Successfully found module ${F[W]}[${VALIDATE_PSSA_MODULE}]${F[B]} in system"
    debug "Successfully found command ${F[W]}[${VALIDATE_PSSA_CMD}]${F[B]} in system"
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
        \"target_url\": \"https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}\",
        \"description\": \"${MESSAGE}\", \"context\": \"--> Linted: ${LANGUAGE}\"
      }" 2>&1
    )

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

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
#### Function Reports ##########################################################
Reports() {
  info "----------------------------------------------"
  info "----------------------------------------------"
  info "Generated reports:"
  info "----------------------------------------------"
  info "----------------------------------------------"

  ###################################
  # Prints output report if enabled #
  ###################################
  if [ -z "${FORMAT_REPORT}" ]; then
    info "Reports generated in folder ${REPORT_OUTPUT_FOLDER}"
    #############################################
    # Print info on reports that were generated #
    #############################################
    if [ -d "${REPORT_OUTPUT_FOLDER}" ]; then
      info "Contents of report folder:"
      OUTPUT_CONTENTS_CMD=$(ls "${REPORT_OUTPUT_FOLDER}")
      info "$OUTPUT_CONTENTS_CMD"
    else
      warn "Report output folder (${REPORT_OUTPUT_FOLDER}) does NOT exist."
    fi
  fi

  ################################
  # Prints for warnings if found #
  ################################
  for TEST in "${WARNING_ARRAY_TEST[@]}"; do
    warn "Expected file to compare with was not found for ${TEST}"
  done
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
#### Function CheckInArray #####################################################
CheckInArray() {
  ###############
  # Pull in Var #
  ###############
  NEEDLE="$1" # Language we need to match

  ######################################
  # Check if Language was in the array #
  ######################################
  for LANG in "${UNIQUE_LINTED_ARRAY[@]}"; do
    if [[ "${LANG}" == "${NEEDLE}" ]]; then
      ############
      # Found it #
      ############
      return 0
    fi
  done

  ###################
  # Did not find it #
  ###################
  return 1
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

##############################################################
# check flag for validating the report folder does not exist #
##############################################################
if [ -n "${OUTPUT_FORMAT}" ]; then
  if [ -d "${REPORT_OUTPUT_FOLDER}" ]; then
    error "ERROR! Found ${REPORT_OUTPUT_FOLDER}"
    fatal "Please remove the folder and try again."
  fi
fi

#######################
# Get GitHub Env Vars #
#######################
# Need to pull in all the GitHub variables
# needed to connect back and update checks
GetGitHubVars

########################################################
# Initialize variables that depend on GitHub variables #
########################################################
DEFAULT_ANSIBLE_DIRECTORY="${GITHUB_WORKSPACE}/ansible"          # Default Ansible Directory
export DEFAULT_ANSIBLE_DIRECTORY                                 # Workaround SC2034
DEFAULT_KUBERNETES_DIRECTORY="${GITHUB_WORKSPACE}/kubernetes"    # Default Kubernetes Directory
export DEFAULT_KUBERNETES_DIRECTORY                              # Workaround SC2034
REPORT_OUTPUT_FOLDER="${GITHUB_WORKSPACE}/${OUTPUT_FOLDER}"      # Location for the report folder

#########################################
# Get the languages we need to validate #
#########################################
GetValidationInfo

########################
# Get the linter rules #
########################
# Get Ansible rules
GetLinterRules "ANSIBLE"
# Get ARM rules
GetLinterRules "ARM"
# Get CLOUDFORMATION rules
GetLinterRules "CLOUDFORMATION"
# Get Coffeescript rules
GetLinterRules "COFFEESCRIPT"
# Get CSS rules
GetLinterRules "CSS"
# Get DART rules
GetLinterRules "DART"
# Get Docker rules
GetLinterRules "DOCKERFILE"
# Get Docker rules
GetLinterRules "DOCKERFILE_HADOLINT"
# Get Golang rules
GetLinterRules "GO"
# Get Groovy rules
GetLinterRules "GROOVY"
# Get HTML rules
GetLinterRules "HTML"
# get Java rules
GetLinterRules "JAVA"
# Get JavaScript rules
GetLinterRules "JAVASCRIPT"
# Get LATEX rules
GetLinterRules "LATEX"
# Get LUA rules
GetLinterRules "LUA"
# Get Markdown rules
GetLinterRules "MARKDOWN"
# Get PHPCS rules
GetLinterRules "PHP_PHPCS"
# Get PHP_PHPSTAN rules
GetLinterRules "PHP_PHPSTAN"
# Get PHP_PSALM rules
GetLinterRules "PHP_PSALM"
# Get PowerShell rules
GetLinterRules "POWERSHELL"
# Get Protobuff linter rules
GetLinterRules "PROTOBUF"
# Get Python pylint rules
GetLinterRules "PYTHON_PYLINT"
# Get Python flake8 rules
GetLinterRules "PYTHON_FLAKE8"
# Get Python black rules
GetLinterRules "PYTHON_BLACK"
# Get R rules
GetLinterRules "R"
# Get Ruby rules
GetLinterRules "RUBY"
# Get SQL rules
GetLinterRules "SQL"
# Get Terraform rules
GetLinterRules "TERRAFORM"
# Get TypeScript rules
GetLinterRules "TYPESCRIPT"
# Get YAML rules
GetLinterRules "YAML"

##################################
# Get and print all version info #
##################################
GetLinterVersions

###########################################
# Check to see if this is a test case run #
###########################################
if [[ ${TEST_CASE_RUN} != "false" ]]; then

  #############################################
  # Set the multi status to off for test runs #
  #############################################
  MULTI_STATUS='false'

  ###########################
  # Run only the test cases #
  ###########################
  # Code will exit from inside this loop
  RunTestCases
fi

#############################################
# check flag for validation of all codebase #
#############################################
if [ "${VALIDATE_ALL_CODEBASE}" == "false" ]; then
  ########################################
  # Get list of files changed if env set #
  ########################################
  BuildFileList
fi

###################
# ANSIBLE LINTING #
###################
if [ "${VALIDATE_ANSIBLE}" == "true" ]; then
  ##########################
  # Lint the Ansible files #
  ##########################
  # Due to the nature of how we want to validate Ansible, we cannot use the
  # standard loop, since it looks for an ansible folder, excludes certain
  # files, and looks for additional changes, it should be an outlier
  LintAnsibleFiles "${ANSIBLE_LINTER_RULES}" # Passing rules but not needed, dont want to exclude unused var
fi

########################
# ARM Template LINTING #
########################
if [ "${VALIDATE_ARM}" == "true" ]; then
  # If we are validating all codebase we need to build file list because not every json file is an ARM file
  if [ "${VALIDATE_ALL_CODEBASE}" == "true" ]; then
    ###############################################################################
    # Set the file seperator to newline to allow for grabbing objects with spaces #
    ###############################################################################
    IFS=$'\n'

    mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" -path "*/node_modules" -prune -o -type f -regex ".*\.\(json\)\$" 2>&1)
    for FILE in "${LIST_FILES[@]}"; do
      if DetectARMFile "${FILE}"; then
        FILE_ARRAY_ARM+=("${FILE}")
      fi
    done

    ###########################
    # Set IFS back to default #
    ###########################
    IFS="${DEFAULT_IFS}"
  fi

  ###############################
  # Lint the ARM Template files #
  ###############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "ARM" "arm-ttk" "Import-Module ${ARM_TTK_PSD1} ; \${config} = \$(Import-PowerShellDataFile -Path ${ARM_LINTER_RULES}) ; Test-AzTemplate @config -TemplatePath" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_ARM[@]}"
fi

################
# BASH LINTING #
################
if [ "${VALIDATE_BASH}" == "true" ]; then
  #######################
  # Lint the bash files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "BASH" "shellcheck" "shellcheck --color --external-sources" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_BASH[@]}"
fi

#####################
# BASH_EXEC LINTING #
#####################
if [ "${VALIDATE_BASH_EXEC}" == "true" ]; then
  #######################
  # Lint the bash files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "BASH_EXEC" "bash-exec" "bash-exec" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_BASH[@]}"
fi

##########################
# CLOUDFORMATION LINTING #
##########################
if [ "${VALIDATE_CLOUDFORMATION}" == "true" ]; then
  # If we are validating all codebase we need to build file list because not every yml/json file is an CLOUDFORMATION file
  if [ "${VALIDATE_ALL_CODEBASE}" == "true" ]; then
    ###############################################################################
    # Set the file seperator to newline to allow for grabbing objects with spaces #
    ###############################################################################
    IFS=$'\n'

    mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" -path "*/node_modules" -prune -o -type f -regex ".*\.\(yml\|yaml\|json\)\$" 2>&1)
    for FILE in "${LIST_FILES[@]}"; do
      if DetectCloudFormationFile "${FILE}"; then
        FILE_ARRAY_CLOUDFORMATION+=("${FILE}")
      fi
    done

    ###########################
    # Set IFS back to default #
    ###########################
    IFS="${DEFAULT_IFS}"
  fi

  #################################
  # Lint the CloudFormation files #
  #################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "CLOUDFORMATION" "cfn-lint" "cfn-lint --config-file ${CLOUDFORMATION_LINTER_RULES}" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_CLOUDFORMATION[@]}"
fi

###################
# CLOJURE LINTING #
###################
if [ "${VALIDATE_CLOJURE}" == "true" ]; then
  #################################
  # Get Clojure standard rules #
  #################################
  GetStandardRules "clj-kondo"
  #########################
  # Lint the Clojure files #
  #########################
  LintCodebase "CLOJURE" "clj-kondo" "clj-kondo --config ${CLOJURE_LINTER_RULES} --lint" ".*\.\(clj\|cljs\|cljc\|edn\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_CLOJURE[@]}"
fi

########################
# COFFEESCRIPT LINTING #
########################
if [ "${VALIDATE_COFFEE}" == "true" ]; then
  #########################
  # Lint the coffee files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "COFFEESCRIPT" "coffeelint" "coffeelint -f ${COFFEESCRIPT_LINTER_RULES}" ".*\.\(coffee\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_COFFEESCRIPT[@]}"
fi

##################
# CSHARP LINTING #
##################
if [ "${VALIDATE_CSHARP}" == "true" ]; then
  #########################
  # Lint the C# files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "CSHARP" "dotnet-format" "dotnet-format --folder --check --exclude / --include" ".*\.\(cs\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_CSHARP[@]}"
fi

###############
# CSS LINTING #
###############
if [ "${VALIDATE_CSS}" == "true" ]; then
  #################################
  # Get CSS standard rules #
  #################################
  GetStandardRules "stylelint"
  #############################
  # Lint the CSS files #
  #############################
  LintCodebase "CSS" "stylelint" "stylelint --config ${CSS_LINTER_RULES}" ".*\.\(css\|scss\|sass\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_CSS[@]}"
fi

################
# DART LINTING #
################
if [ "${VALIDATE_DART}" == "true" ]; then
  #######################
  # Lint the Dart files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "DART" "dart" "dartanalyzer --fatal-infos --fatal-warnings --options ${DART_LINTER_RULES}" ".*\.\(dart\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_DART[@]}"
fi

##################
# DOCKER LINTING #
##################
if [ "${VALIDATE_DOCKERFILE}" == "true" ]; then
  #########################
  # Lint the docker files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  # NOTE: dockerfilelint's "-c" option expects the folder *containing* the DOCKER_LINTER_RULES file
  LintCodebase "DOCKERFILE" "dockerfilelint" "dockerfilelint -c $(dirname ${DOCKERFILE_LINTER_RULES})" ".*\(Dockerfile\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_DOCKERFILE[@]}"
fi

###########################
# DOCKER LINTING HADOLINT #
###########################
if [ "${VALIDATE_DOCKERFILE_HADOLINT}" == "true" ]; then
  #########################
  # Lint the docker files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "DOCKERFILE_HADOLINT" "hadolint" "hadolint -c ${DOCKERFILE_HADOLINT_LINTER_RULES}" ".*\(Dockerfile\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_DOCKERFILE[@]}"
fi

########################
# EDITORCONFIG LINTING #
########################
if [ "${VALIDATE_EDITORCONFIG}" == "true" ]; then
  ####################################
  # Lint the files with editorconfig #
  ####################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "EDITORCONFIG" "editorconfig-checker" "editorconfig-checker" "^.*$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_ENV[@]}"
fi

###############
# ENV LINTING #
###############
if [ "${VALIDATE_ENV}" == "true" ]; then
  #######################
  # Lint the env files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "ENV" "dotenv-linter" "dotenv-linter" ".*\.\(env\).*\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_ENV[@]}"
fi

##################
# GOLANG LINTING #
##################
if [ "${VALIDATE_GO}" == "true" ]; then
  #########################
  # Lint the golang files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "GO" "golangci-lint" "golangci-lint run -c ${GO_LINTER_RULES}" ".*\.\(go\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_GO[@]}"
fi

##################
# GROOVY LINTING #
##################
if [ "$VALIDATE_GROOVY" == "true" ]; then
  #########################
  # Lint the groovy files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "GROOVY" "npm-groovy-lint" "npm-groovy-lint -c $GROOVY_LINTER_RULES --failon warning" ".*\.\(groovy\|jenkinsfile\|gradle\|nf\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_GROOVY[@]}"
fi

################
# HTML LINTING #
################
if [ "${VALIDATE_HTML}" == "true" ]; then
  ###########################
  # Get HTML standard rules #
  ###########################
  GetStandardRules "htmlhint"
  #######################
  # Lint the HTML files #
  #######################
  LintCodebase "HTML" "htmlhint" "htmlhint --config ${HTML_LINTER_RULES}" ".*\.\(html\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_HTML[@]}"
fi

################
# JAVA LINTING #
################
if [ "$VALIDATE_JAVA" == "true" ]; then
  #######################
  # Lint the JAVA files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "JAVA" "checkstyle" "java -jar /usr/bin/checkstyle -c ${JAVA_LINTER_RULES}" ".*\.\(java\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_JAVA[@]}"
fi

######################
# JAVASCRIPT LINTING #
######################
if [ "${VALIDATE_JAVASCRIPT_ES}" == "true" ]; then
  #############################
  # Lint the Javascript files #
  #############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "JAVASCRIPT_ES" "eslint" "eslint --no-eslintrc -c ${JAVASCRIPT_LINTER_RULES}" ".*\.\(js\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_JAVASCRIPT_ES[@]}"
fi

######################
# JAVASCRIPT LINTING #
######################
if [ "${VALIDATE_JAVASCRIPT_STANDARD}" == "true" ]; then
  #################################
  # Get Javascript standard rules #
  #################################
  GetStandardRules "javascript"
  #############################
  # Lint the Javascript files #
  #############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "JAVASCRIPT_STANDARD" "standard" "standard ${JAVASCRIPT_STANDARD_LINTER_RULES}" ".*\.\(js\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_JAVASCRIPT_STANDARD[@]}"
fi

################
# JSON LINTING #
################
if [ "${VALIDATE_JSON}" == "true" ]; then
  #######################
  # Lint the json files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "JSON" "jsonlint" "jsonlint" ".*\.\(json\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_JSON[@]}"
fi

###############
# JSX LINTING #
###############
if [ "${VALIDATE_JSX}" == "true" ]; then
  ######################
  # Lint the JSX files #
  ######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "JSX" "eslint" "eslint --no-eslintrc -c ${JAVASCRIPT_LINTER_RULES}" ".*\.\(jsx\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_JSX[@]}"
fi

##################
# KOTLIN LINTING #
##################
if [ "${VALIDATE_KOTLIN}" == "true" ]; then
  #######################
  # Lint the Kotlin files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "KOTLIN" "ktlint" "ktlint" ".*\.\(kt\|kts\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_KOTLIN[@]}"
fi

##############################
# KUBERNETES Kubeval LINTING #
##############################
if [ "${VALIDATE_KUBERNETES_KUBEVAL}" == "true" ]; then
  if [ -d "${KUBERNETES_DIRECTORY}" ]; then
    if [ "${VALIDATE_ALL_CODEBASE}" == "true" ]; then
      ###############################################################################
      # Set the file seperator to newline to allow for grabbing objects with spaces #
      ###############################################################################
      IFS=$'\n'

      mapfile -t LIST_FILES < <(find "${KUBERNETES_DIRECTORY}" -path "*/node_modules" -prune -o -type f -regex ".*\.\(yml\|yaml\|json\)\$" 2>&1)
      for FILE in "${LIST_FILES[@]}"; do
        if DetectKubernetesFile "${FILE}"; then
          FILE_ARRAY_KUBERNETES+=("${FILE}")
        fi
      done

      ###########################
      # Set IFS back to default #
      ###########################
      IFS="${DEFAULT_IFS}"
    fi

    LintCodebase "KUBERNETES_KUBEVAL" "kubeval" "kubeval --strict" ".*\.\(yml\|yaml\|json\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_KUBERNETES[@]}"
  else
    warn "No Kubernetes directory found at:[${KUBERNETES_DIRECTORY}]"
    debug "skipping Kubeval lint"
  fi
fi

#################
# LATEX LINTING #
#################
if [ "${VALIDATE_LATEX}" == "true" ]; then
  ########################
  # Lint the LATEX files #
  ########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "LATEX" "chktex" "chktex -q -l ${LATEX_LINTER_RULES}" ".*\.\(tex\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_LATEX[@]}"
fi

###############
# LUA LINTING #
###############
if [ "${VALIDATE_LUA}" == "true" ]; then
  ######################
  # Lint the Lua files #
  ######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "LUA" "lua" "luacheck --config ${LUA_LINTER_RULES}" ".*\.\(lua\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_LUA[@]}"
fi

####################
# MARKDOWN LINTING #
####################
if [ "${VALIDATE_MARKDOWN}" == "true" ]; then
  ###########################
  # Lint the Markdown Files #
  ###########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "MARKDOWN" "markdownlint" "markdownlint -c ${MARKDOWN_LINTER_RULES}" ".*\.\(md\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_MARKDOWN[@]}"
fi

###################
# OPENAPI LINTING #
###################
if [ "${VALIDATE_OPENAPI}" == "true" ]; then
  # If we are validating all codebase we need to build file list because not every yml/json file is an OpenAPI file
  if [ "${VALIDATE_ALL_CODEBASE}" == "true" ]; then
    ###############################################################################
    # Set the file seperator to newline to allow for grabbing objects with spaces #
    ###############################################################################
    IFS=$'\n'

    mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" -path "*/node_modules" -prune -o -type f -regex ".*\.\(yml\|yaml\|json\)\$" 2>&1)
    for FILE in "${LIST_FILES[@]}"; do
      if DetectOpenAPIFile "${FILE}"; then
        FILE_ARRAY_OPENAPI+=("${FILE}")
      fi
    done

    ###########################
    # Set IFS back to default #
    ###########################
    IFS="${DEFAULT_IFS}"
  fi

  ##########################
  # Lint the OpenAPI files #
  ##########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "OPENAPI" "spectral" "spectral lint -r ${OPENAPI_LINTER_RULES}" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_OPENAPI[@]}"
fi

################
# PERL LINTING #
################
if [ "${VALIDATE_PERL}" == "true" ]; then
  #######################
  # Lint the perl files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PERL" "perl" "perlcritic" ".*\.\(pl\|pm\|t\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PERL[@]}"
fi

################
# PHP LINTING #
################
if [ "${VALIDATE_PHP_BUILTIN}" == "true" ]; then
  ################################################
  # Lint the PHP files using built-in PHP linter #
  ################################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PHP_BUILTIN" "php" "php -l" ".*\.\(php\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PHP_BUILTIN[@]}"
fi

if [ "${VALIDATE_PHP_PHPCS}" == "true" ]; then
  ############################################
  # Lint the PHP files using PHP CodeSniffer #
  ############################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PHP_PHPCS" "phpcs" "phpcs --standard=${PHP_PHPCS_LINTER_RULES}" ".*\.\(php\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PHP_PHPCS[@]}"
fi

if [ "${VALIDATE_PHP_PHPSTAN}" == "true" ]; then
  #######################
  # Lint the PHP files using PHPStan #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PHP_PHPSTAN" "phpstan" "phpstan analyse --no-progress --no-ansi -c ${PHP_PHPSTAN_LINTER_RULES}" ".*\.\(php\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PHP_PHPSTAN[@]}"
fi

if [ "${VALIDATE_PHP_PSALM}" == "true" ]; then
  ##################################
  # Lint the PHP files using Psalm #
  ##################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PHP_PSALM" "psalm" "psalm --config=${PHP_PSALM_LINTER_RULES}" ".*\.\(php\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PHP_PSALM[@]}"
fi

######################
# POWERSHELL LINTING #
######################
if [ "${VALIDATE_POWERSHELL}" == "true" ]; then
  ###############################################################
  # For POWERSHELL, ensure PSScriptAnalyzer module is available #
  ###############################################################
  ValidatePowershellModules

  #############################
  # Lint the powershell files #
  #############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "POWERSHELL" "pwsh" "Invoke-ScriptAnalyzer -EnableExit -Settings ${POWERSHELL_LINTER_RULES} -Path" ".*\.\(ps1\|psm1\|psd1\|ps1xml\|pssc\|psrc\|cdxml\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_POWERSHELL[@]}"
fi

####################
# PROTOBUF LINTING #
####################
if [ "${VALIDATE_PROTOBUF}" == "true" ]; then
  #######################
  # Lint the Protocol Buffers files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PROTOBUF" "protolint" "protolint lint --config_path ${PROTOBUF_LINTER_RULES}" ".*\.\(proto\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PROTOBUF[@]}"
fi

########################
# PYTHON BLACK LINTING #
########################
if [ "${VALIDATE_PYTHON_BLACK}" == "true" ]; then
  #########################
  # Lint the python files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PYTHON_BLACK" "black" "black --config ${PYTHON_BLACK_LINTER_RULES} --diff --check" ".*\.\(py\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PYTHON_BLACK[@]}"
fi

#########################
# PYTHON PYLINT LINTING #
#########################
if [ "${VALIDATE_PYTHON_PYLINT}" == "true" ]; then
  #########################
  # Lint the python files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PYTHON_PYLINT" "pylint" "pylint --rcfile ${PYTHON_PYLINT_LINTER_RULES}" ".*\.\(py\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PYTHON_PYLINT[@]}"
fi

#########################
# PYTHON FLAKE8 LINTING #
#########################
if [ "${VALIDATE_PYTHON_FLAKE8}" == "true" ]; then
  #########################
  # Lint the python files #
  #########################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "PYTHON_FLAKE8" "flake8" "flake8 --config=${PYTHON_FLAKE8_LINTER_RULES}" ".*\.\(py\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_PYTHON_FLAKE8[@]}"
fi

#############
# R LINTING #
#############
if [ "${VALIDATE_R}" == "true" ]; then
  ##########################
  # Check for local config #
  ##########################
  if [ ! -f "${GITHUB_WORKSPACE}/.lintr" ] && ((${#FILE_ARRAY_R[@]})); then
    info "No .lintr configuration file found, using defaults."
    cp $R_LINTER_RULES "$GITHUB_WORKSPACE"
  fi

  ######################
  # Lint the R files   #
  ######################
  LintCodebase "R" "lintr" "lintr::lint(File)" ".*\.\(r\|R\|Rmd\|rmd\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_R[@]}"
fi

################
# RAKU LINTING #
################
if [ "${VALIDATE_RAKU}" == "true" ]; then
  #######################
  # Lint the raku files #
  #######################
  if [ -e "${GITHUB_WORKSPACE}/META6.json" ]; then
    cd "${GITHUB_WORKSPACE}" && zef install --deps-only --/test .
  fi
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "RAKU" "raku" "raku -I ${GITHUB_WORKSPACE}/lib -c" ".*\.\(raku\|rakumod\|rakutest\|pm6\|pl6\|p6\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_RAKU[@]}"
fi

################
# RUBY LINTING #
################
if [ "${VALIDATE_RUBY}" == "true" ]; then
  #######################
  # Lint the ruby files #
  #######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "RUBY" "rubocop" "rubocop -c ${RUBY_LINTER_RULES} --force-exclusion" ".*\.\(rb\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_RUBY[@]}"
fi

#################
# SHFMT LINTING #
#################
if [ "${VALIDATE_SHELL_SHFMT}" == "true" ]; then
  ####################################
  # Lint the files with shfmt #
  ####################################
  EDITORCONFIG_FILE_PATH="${GITHUB_WORKSPACE}"/.editorconfig
  if [ -e "$EDITORCONFIG_FILE_PATH" ]; then
    # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
    LintCodebase "SHELL_SHFMT" "shfmt" "shfmt -d" ".*\.\(sh\|bash\|dash\|ksh\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_BASH[@]}"
  else
    ###############################
    # No .editorconfig file found #
    ###############################
    warn "No .editorconfig found at:[$EDITORCONFIG_FILE_PATH]"
    debug "skipping shfmt"
  fi
fi

##################
# SNAKEMAKE LINT #
##################
if [ "${VALIDATE_SNAKEMAKE_LINT}" == "true" ]; then
  ################################
  # Lint the files with snakefmt #
  ################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "SNAKEMAKE_LINT" "snakemake" "snakemake --lint -s" "\(Snakefile|.*\.smk\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_SNAKEMAKE[@]}"
fi

######################
# SNAKEMAKE SNAKEFMT #
######################
if [ "${VALIDATE_SNAKEMAKE_SNAKEFMT}" == "true" ]; then
  ################################
  # Lint the files with snakefmt #
  ################################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "SNAKEMAKE_SNAKEFMT" "snakefmt" "snakefmt --config ${SNAKEMAKE_SNAKEFMT_LINTER_RULES} --diff" "\(Snakefile|.*\.smk\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_SNAKEMAKE[@]}"
fi

######################
# AWS STATES LINTING #
######################
if [ "${VALIDATE_STATES}" == "true" ]; then
  # If we are validating all codebase we need to build file list because not every json file is an aws states file
  if [ "${VALIDATE_ALL_CODEBASE}" == "true" ]; then
    ###############################################################################
    # Set the file seperator to newline to allow for grabbing objects with spaces #
    ###############################################################################
    IFS=$'\n'

    mapfile -t LIST_FILES < <(find "${GITHUB_WORKSPACE}" -path "*/node_modules" -prune -o -type f -regex ".*\.\(json\)\$" 2>&1)
    for FILE in "${LIST_FILES[@]}"; do
      if DetectAWSStatesFIle "${FILE}"; then
        FILE_ARRAY_STATES+=("${FILE}")
      fi
    done

    ###########################
    # Set IFS back to default #
    ###########################
    IFS="${DEFAULT_IFS}"
  fi

  #########################
  # Lint the STATES files #
  #########################
  LintCodebase "STATES" "asl-validator" "asl-validator --json-path" "disabledfileext" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_STATES[@]}"
fi

###############
# SQL LINTING #
###############
if [ "${VALIDATE_SQL}" == "true" ]; then
  ######################
  # Lint the SQL files #
  ######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "SQL" "sql-lint" "sql-lint --config ${SQL_LINTER_RULES}" ".*\.\(sql\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_SQL[@]}"
fi

#####################
# TERRAFORM LINTING #
#####################
if [ "${VALIDATE_TERRAFORM}" == "true" ]; then
  ############################
  # Lint the Terraform files #
  ############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "TERRAFORM" "tflint" "tflint -c ${TERRAFORM_LINTER_RULES}" ".*\.\(tf\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_TERRAFORM[@]}"
fi

###############################
# TERRAFORM TERRASCAN LINTING #
###############################
if [ "${VALIDATE_TERRAFORM_TERRASCAN}" == "true" ]; then
  ############################
  # Lint the Terraform files #
  ############################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "TERRAFORM_TERRASCAN" "terrascan" "terrascan scan -p /root/.terrascan/pkg/policies/opa/rego/ -t aws -f " ".*\.\(tf\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_TERRAFORM_TERRASCAN[@]}"
fi

###############
# TSX LINTING #
###############
if [ "${VALIDATE_TSX}" == "true" ]; then
  ######################
  # Lint the TSX files #
  ######################
  LintCodebase "TSX" "eslint" "eslint --no-eslintrc -c ${TYPESCRIPT_LINTER_RULES}" ".*\.\(tsx\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_TSX[@]}"
fi

######################
# TYPESCRIPT LINTING #
######################
if [ "${VALIDATE_TYPESCRIPT_ES}" == "true" ]; then
  #############################
  # Lint the Typescript files #
  #############################
  LintCodebase "TYPESCRIPT_ES" "eslint" "eslint --no-eslintrc -c ${TYPESCRIPT_LINTER_RULES}" ".*\.\(ts\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_TYPESCRIPT_ES[@]}"
fi

######################
# TYPESCRIPT LINTING #
######################
if [ "${VALIDATE_TYPESCRIPT_STANDARD}" == "true" ]; then
  #################################
  # Get Typescript standard rules #
  #################################
  GetStandardRules "typescript"
  #############################
  # Lint the Typescript files #
  #############################
  LintCodebase "TYPESCRIPT_STANDARD" "standard" "standard --parser @typescript-eslint/parser --plugin @typescript-eslint/eslint-plugin ${TYPESCRIPT_STANDARD_LINTER_RULES}" ".*\.\(ts\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_TYPESCRIPT_STANDARD[@]}"
fi

###############
# XML LINTING #
###############
if [ "${VALIDATE_XML}" == "true" ]; then
  ######################
  # Lint the XML Files #
  ######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "XML" "xmllint" "xmllint" ".*\.\(xml\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_XML[@]}"
fi

################
# YAML LINTING #
################
if [ "${VALIDATE_YAML}" == "true" ]; then
  ######################
  # Lint the Yml Files #
  ######################
  # LintCodebase "FILE_TYPE" "LINTER_NAME" "LINTER_CMD" "FILE_TYPES_REGEX" "FILTER_REGEX_INCLUDE" "FILTER_REGEX_EXCLUDE" "FILE_ARRAY"
  LintCodebase "YAML" "yamllint" "yamllint -c ${YAML_LINTER_RULES}" ".*\.\(yml\|yaml\)\$" "${FILTER_REGEX_INCLUDE}" "${FILTER_REGEX_EXCLUDE}" "${FILE_ARRAY_YAML[@]}"
fi

###########
# Reports #
###########
Reports

##########
# Footer #
##########
Footer
