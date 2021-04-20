#!/usr/bin/env bash


################################################################################
################################################################################
########### Super-Linter lintly Function(s) @scriptsrc #########################
################################################################################
################################################################################

##################################
# Lintly language suppport array #
##################################
declare -A LINTLY_SUPPORT_ARRAY
LINTLY_SUPPORT_ARRAY['PYTHON_FLAKE8']="flake8"
LINTLY_SUPPORT_ARRAY['PYTHON_BANDIT']="bandit-json"
LINTLY_SUPPORT_ARRAY['PYTHON_BLACK']="black"
LINTLY_SUPPORT_ARRAY['PYTHON_PYLINT']="pylint-json"
LINTLY_SUPPORT_ARRAY['JAVASCRIPT_ES']="eslint"
LINTLY_SUPPORT_ARRAY['TYPESCRIPT_ES']="eslint"
LINTLY_SUPPORT_ARRAY['TERRAFORM_TERRASCAN']="terrascan"
LINTLY_SUPPORT_ARRAY['CSS']="stylelint"
LINTLY_SUPPORT_ARRAY['DOCKERFILE_HADOLINT']="hadolint"
LINTLY_SUPPORT_ARRAY['CLOUDFORMATION']="cfn-lint"
export LINTLY_SUPPORT_ARRAY                      # Workaround SC2034

# Not yet implemented by super-linter
# LINTLY_SUPPORT_ARRAY['ANY']="gitleaks"
# LINTLY_SUPPORT_ARRAY['CLOUDFORMATION_CFNNAG']="cfn-nag"

########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function AddLinterOptsForLintly ###########################################
function AddLinterOptsForLintly() {
  [[ ! "${LINTER_OPTS[PYTHON_BANDIT]}" =~ "json" ]] && LINTER_OPTS[PYTHON_BANDIT]+=" --format=json --silent"
  [[ ! "${LINTER_OPTS[PYTHON_PYLINT]}" =~ "json" ]] && LINTER_OPTS[PYTHON_PYLINT]+=" --output-format=json"
  [[ ! "${LINTER_OPTS[DOCKERFILE_HADOLINT]}" =~ "json" ]] && LINTER_OPTS[DOCKERFILE_HADOLINT]+=" --format json"
  [[ ! "${LINTER_OPTS[TERRAFORM_TERRASCAN]}" =~ "json" ]] && LINTER_OPTS[TERRAFORM_TERRASCAN]+=" -o json"
}
################################################################################
#### Function InvokeLintly #####################################################
function InvokeLintly() {
  # Call comes through as:
  # InvokeLintly "${LINTLY_FORMAT}" "${LINTER_COMMAND_OUTPUT}"

  ####################
  # Pull in the vars #
  ####################
  LINTLY_FORMAT="${1}"
  LINTLY_FILE_OVERRIDE="${2}"
  LINTER_COMMAND_OUTPUT="${3}"

  debug "----<<<<INVOKING Invokelintly>>>>----"
  debug "FORMAT: ${LINTLY_FORMAT}"
  debug "OUTPUT: ${LINTER_COMMAND_OUTPUT}"
  debug ""
  debug "DONE DISPLAYING ARGUMENTS"

  LINTLY_LOG=""
  if [[ ${ACTIONS_RUNNER_DEBUG} == true ]]; then LINTLY_LOG="--log"; fi

  # Lintly will comment on the PR
  export LINTLY_FILE_OVERRIDE="${LINTLY_FILE_OVERRIDE}"
  echo "$LINTER_COMMAND_OUTPUT" | lintly "${LINTLY_LOG}" --format="${LINTLY_FORMAT}"

  debug "$?"
  debug "^^ exit code ^^"
}
################################################################################
#### Function IsLintly #########################################################
function IsLintly() {
  [[ "${OUTPUT_MODE}" == lintly ]]
}
################################################################################
#### Function SupportsLintly ###################################################
function SupportsLintly() {
  # Call comes through as:
  # SupportsLintly "${LANGUAGE}"

  ####################
  # Pull in the vars #
  ####################
  LANGUAGE="${1}"
  [[ -v LINTLY_SUPPORT_ARRAY["${LANGUAGE}"] ]]
}
