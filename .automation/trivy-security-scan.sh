#!/usr/bin/env bash

################################################################################
############# Trivy Security Scan @admiralawkbar ###############################
################################################################################

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"  # GitHub Workspace
REPORT_NAME='report.sarif'              # Name of the generated report
TEMPLATE_NAME='sarif.tpl'               # Name of the template file
ERRORS_FOUND=0                          # Flag for errors founsd in scan

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  echo "-------------------------------------------------------"
  echo "--------- Trivy Security Scan on Super-Linter ---------"
  echo "-------------------------------------------------------"
}
################################################################################
#### Function RunScan ##########################################################
RunScan() {
  ###########################
  # Run the Trivy code scan #
  ###########################
  RUN_CMD=$(${GITHUB_WORKSPACE}/trivy fs --format template --template @${GITHUB_WORKSPACE}/${TEMPLATE_NAME} -o ${REPORT_NAME} --exit-code 1 ${GITHUB_WORKSPACE} 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error
    echo "ERRORS detected in scan!"
    echo "[${RUN_CMD}]"
    # bump the count
    ERRORS_FOUND=1
  else
    # Success
    echo "Successfully scanned codebase!"
  fi
}
################################################################################
#### Function OutputReport #####################################################
OutputReport() {
  ########################################
  # Output the report that was generated #
  ########################################
  echo ""
  echo "-------- [${REPORT_NAME}] Results: --------"
  ${GITHUB_WORKSPACE}/trivy fs ${GITHUB_WORKSPACE} 2>&1
  echo "-----------------------------------------"
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  echo ""
  echo "-------------------------------------------------------"
  echo "The step has completed with error code:[${ERRORS_FOUND}]"
  echo "-------------------------------------------------------"

  ########################
  # Exit with error code #
  ########################
  exit "${ERRORS_FOUND}"
}
################################################################################
################################## MAIN ########################################
################################################################################

##########
# Header #
##########
Header

################
# Run the scan #
################
RunScan

#################
# Output Report #
#################
OutputReport

##########
# Footer #
##########
Footer
