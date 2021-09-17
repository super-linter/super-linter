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
LINTLY_SUPPORT_ARRAY['CLOUDFORMATION_CFN_NAG']="cfn-nag"
LINTLY_SUPPORT_ARRAY['GITLEAKS']="gitleaks"
LINTLY_SUPPORT_ARRAY['DEPS_CHECKER']='deps-checker'
LINTLY_SUPPORT_ARRAY['SEMGREP']='semgrep'
export LINTLY_SUPPORT_ARRAY # Workaround SC2034

########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function AddLinterOptsForLintly ###########################################
function AddLinterOptsForLintly() {
  [[ ! "${LINTER_OPTS[PYTHON_BANDIT]}" =~ "json" ]] && LINTER_OPTS[PYTHON_BANDIT]+=" --format=json --silent"
  [[ ! "${LINTER_OPTS[PYTHON_PYLINT]}" =~ "json" ]] && LINTER_OPTS[PYTHON_PYLINT]+=" --output-format=json"
  [[ ! "${LINTER_OPTS[DOCKERFILE_HADOLINT]}" =~ "json" ]] && LINTER_OPTS[DOCKERFILE_HADOLINT]+=" --format json"
  [[ ! "${LINTER_OPTS[SEMGREP]}" =~ "json" ]] && LINTER_OPTS[SEMGREP]+=" --json"
  [[ ! "${LINTER_OPTS[TERRAFORM_TERRASCAN]}" =~ "json" ]] && LINTER_OPTS[TERRAFORM_TERRASCAN]+=" -o json"
  [[ ! "${LINTER_OPTS[CLOUDFORMATION_CFN_NAG]}" =~ "json" ]] && LINTER_OPTS[CLOUDFORMATION_CFN_NAG]+=" --output-format=json"
}
################################################################################
#### Function InvokeLintly #####################################################
function InvokeLintly() {
  # Call comes through as:
  # InvokeLintly "${FILE_TYPE}" ${FILE} "${LINTER_COMMAND_OUTPUT_FILE}"

  ####################
  # Pull in the vars #
  ####################
  FILE_TYPE="${1}"
  FILE="${2}"
  LINTER_COMMAND_OUTPUT_FILE="${3}"
  LINTLY_FORMAT="${LINTLY_SUPPORT_ARRAY[${FILE_TYPE}]}"

  debug "----<<<<INVOKING Invokelintly>>>>----"
  debug "FORMAT: ${LINTLY_FORMAT}"
  debug "OUTPUT: $(<"${LINTER_COMMAND_OUTPUT_FILE}")"
  debug ""
  debug "DONE DISPLAYING ARGUMENTS"

  LINTLY_LOG=""
  if [[ ${ACTIONS_RUNNER_DEBUG} ]]; then LINTLY_LOG="--log"; fi

  # Some linter tools may not provide a full path and filename. Use env var to "hint" to Lintly
  # what the repo-relative path should be.
  export LINTLY_FILE_OVERRIDE="${FILE}"
  # Lintly will comment on the PR
  lintly "${LINTLY_LOG}" --format="${LINTLY_FORMAT}" <"${LINTER_COMMAND_OUTPUT_FILE}"

  debug "$?"
  debug "^^ exit code ^^"
}
################################################################################
#### Function OutputToLintly ###################################################
function OutputToLintly() {
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
