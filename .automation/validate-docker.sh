#!/usr/bin/env bash

#############################################################################
############# Validate build docker image for possible extra errors #########
#############################################################################

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"  # GitHub Workspace
GITHUB_SHA="${GITHUB_SHA}"              # Sha used to create this branch
BUILD_DATE="${BUILD_DATE}"              # Date the container was built
ERROR=0                                 # Error count

#########################
# Source Function Files #
#########################
# shellcheck source=/dev/null
source "${GITHUB_WORKSPACE}/lib/log.sh" # Source the function script(s)

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  info "-------------------------------------------"
  info "----- GitHub Actions validate docker ------"
  info "-------------------------------------------"
}
################################################################################
#### Function ValidatePowershellModules ########################################
function ValidatePowershellModules() {
  VALIDATE_PSSA_MODULE=$(pwsh -c "(Get-Module -Name PSScriptAnalyzer -ListAvailable | Select-Object -First 1).Name" 2>&1)
  VALIDATE_PSSA_CMD=$(pwsh -c "(Get-Command Invoke-ScriptAnalyzer | Select-Object -First 1).Name" 2>&1)
  # If module found, ensure Invoke-ScriptAnalyzer command is available
  if [[ ${VALIDATE_PSSA_MODULE} == "PSScriptAnalyzer" ]] && [[ ${VALIDATE_PSSA_CMD} == "Invoke-ScriptAnalyzer" ]]; then
    # Success
    debug "Successfully found module ${F[W]}[${VALIDATE_PSSA_MODULE}]${F[B]} in system"
    debug "Successfully found command ${F[W]}[${VALIDATE_PSSA_CMD}]${F[B]} in system"
  else
    # Failed
    ERROR=1
    error "Failed find module [PSScriptAnalyzer] in system!"
    error "[PSSA_MODULE: ${VALIDATE_PSSA_MODULE}] [PSSA_CMD: ${VALIDATE_PSSA_CMD}]"
  fi
}
################################################################################
#### Function ValidateLabel ####################################################
ValidateLibs() {
  ValidatePowershellModules
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  #####################################
  # Check if any errors were reported #
  #####################################
  if [[ ${ERROR} -gt 0 ]]; then
    fatal "There were some failed assertions. See above"
  else
    info "-------------------------------------------------------"
    info "The step has completed"
    info "-------------------------------------------------------"
  fi
}
################################################################################
################################## MAIN ########################################
################################################################################

#################
# Validate libs #
#################
ValidateLibs

#################
# Report status #
#################
Footer
