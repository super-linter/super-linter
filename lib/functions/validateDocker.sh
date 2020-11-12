#!/usr/bin/env bash

#############################################################################
############# Validate build docker image for possible extra errors #########
#############################################################################

###########
# Globals #
###########
((LOG_TRACE = LOG_DEBUG = LOG_VERBOSE = LOG_NOTICE = LOG_WARN = LOG_ERROR = "true")) # Enable all loging
ERROR=0                                                                              # Error count

export LOG_TRACE LOG_DEBUG LOG_VERBOSE LOG_NOTICE LOG_WARN LOG_ERROR

#########################
# Source Function Files #
#########################
# shellcheck source=/dev/null
source /action/lib/functions/log.sh

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  info "---------------------------------------"
  info "----- Post-build validate docker ------"
  info "---------------------------------------"
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

##########
# Header #
##########
Header

#################
# Validate libs #
#################
ValidateLibs

#################
# Report status #
#################
Footer
