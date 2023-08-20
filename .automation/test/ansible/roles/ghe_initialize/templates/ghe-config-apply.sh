#!/usr/bin/env bash

################################################################################
# Script to run ghe-config-apply on the primary GHES instance
# and wait for any previous runs to complete
################################################################################

###########
# Globals #
###########
GHE_CONFIG_PID='/var/run/ghe-config.pid' # PID file when a config is running
GHE_APPLY_COMMAND='ghe-config-apply'     # Command running when a config run
SLEEP_SECONDS=20                         # Seconds to sleep before next check
PID_CHECK_LIMIT=15                       # How many times to check the pid before moving on
PID_CHECK=0                              # Count of times to check the pid
PROCESS_CHECK_LIMIT=15                   # How many times to check the process before moving on
PROCESS_CHECK=0                          # Count of times to check the process

################################################################################
########################### SUB ROUTINES BELOW #################################
################################################################################
################################################################################
#### Function CheckShellErrors #################################################
CheckShellErrors() {
  COUNTER=$1
  ##############################
  # Check the shell for errors #
  ##############################
  if [ "${ERROR_CODE}" -ne 0 ]; then
    error "Failed to sleep!"
    error "[${SLEEP_CMD}]"
    info "Will try to call apply as last effort..."
    ####################################
    # Call config apply as last effort #
    ####################################
    RunConfigApply
  else
    #####################
    # Increment counter #
    #####################
    ((COUNTER++))
    ##########################################
    # Try to check for the pid/process again #
    ##########################################
    $2
  fi
  return "$COUNTER"
}
################################################################################
#### Function CheckGHEPid ######################################################
CheckGHEPid() {
  ##################################
  # Check to prevent infinite loop #
  ##################################
  if [ ${PID_CHECK} -gt ${PID_CHECK_LIMIT} ]; then
    # Over the limit, move on
    info "We have checked the pid ${PID_CHECK} times, moving on..."
  else
    ################################################
    # Check to see if the PID is alive and running #
    ################################################
    if [ ! -f "${GHE_CONFIG_PID}" ]; then
      # File not found
      info "We're good to move forward, no .pid file found at:[${GHE_CONFIG_PID}]"
    else
      # Found the pid running, need to sleep
      info "Current PID found, sleeping ${SLEEP_SECONDS} seconds before next check..."
      ################
      # Sleep it off #
      ################
      SLEEP_CMD=$(sleep ${SLEEP_SECONDS} 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      PID_CHECK=CheckShellErrors "PID_CHECK" "CheckGHEPid"
    fi
  fi
}
################################################################################
#### Function CheckGHEProcess ##################################################
CheckGHEProcess() {
  ##################################
  # Check to prevent infinite loop #
  ##################################
  if [ ${PROCESS_CHECK} -gt ${PROCESS_CHECK_LIMIT} ]; then
    # Over the limit, move on
    info "We have checked the process ${PROCESS_CHECK} times, moving on..."
  else
    ####################################################
    # Check to see if the process is alive and running #
    ####################################################
    CHECK_PROCESS_CMD=$(pgrep -f "${GHE_APPLY_COMMAND}" 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ ${ERROR_CODE} -ne 0 ]; then
      # No process running on the system
      info "Were good to move forward, no process like:[${GHE_APPLY_COMMAND}] running currently on the system"
    else
      # Found the process running, need to sleep
      info "Current process alive:[${CHECK_PROCESS_CMD}], sleeping ${SLEEP_SECONDS} seconds before next check..."
      ################
      # Sleep it off #
      ################
      SLEEP_CMD=$(sleep ${SLEEP_SECONDS} 2>&1)

      #######################
      # Load the error code #
      #######################
      ERROR_CODE=$?

      PROCESS_CHECK=CheckShellErrors "PROCESS_CHECK" "CheckGHEProcess"
    fi
  fi
}
################################################################################
#### Function RunConfigApply ###################################################
RunConfigApply() {
  ##########
  # Header #
  ##########
  info "Running ${GHE_APPLY_COMMAND} to the server..."

  ##############################################
  # Run the command to apply changes to server #
  ##############################################
  APPLY_CMD=$(ghe-config-apply 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # Errors
    error "Failed to run config apply command!"
    fatal "[${APPLY_CMD}]"
  else
    # Success
    info "Successfully ran ${F[C]}${GHE_APPLY_COMMAND}"
  fi
}
################################################################################
################################## MAIN ########################################
################################################################################

######################
# Check for pid file #
######################
CheckGHEPid

#############################
# Check for running process #
#############################
CheckGHEProcess

####################
# Run config apply #
####################
RunConfigApply

###########################################
# We're going to run it again after a nap #
# to make sure there is no crazy actions  #
###########################################
sleep 300s

######################
# Check for pid file #
######################
CheckGHEPid

#############################
# Check for running process #
#############################
CheckGHEProcess

####################
# Run config apply #
####################
RunConfigApply
