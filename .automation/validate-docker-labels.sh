#!/usr/bin/env bash

################################################################################
############# Clean all code base for additonal testing @admiralawkbar #########
################################################################################

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"  # GitHub Workspace
GITHUB_SHA="${GITHUB_SHA}"              # Sha used to create this branch
BUILD_DATE="${BUILD_DATE}"
BUILD_REVISION="${GITHUB_SHA}"
BUILD_VERSION="${GITHUB_SHA}"
ERROR=0

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
  info "--------------------------------------------------"
  info "----- GitHub Actions validate docker labels ------"
  info "--------------------------------------------------"
}
################################################################################
#### Function ValidateLabel ####################################################
ValidateLabel() {
  LABEL=$(docker inspect --format "{{ index .Config.Labels \"$1\" }}" github/super-linter:"${GITHUB_SHA}")
  if [[ ${LABEL} != "$2" ]]; then
    error "Assert failed [$1 - '${LABEL}' != '$2']"
    ERROR=1
  else
    info "Assert passed [$1]"
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer() {
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

####################
# Validate created #
####################
ValidateLabel "org.opencontainers.image.created" "${BUILD_DATE}"

#####################
# Validate revision #
#####################
ValidateLabel "org.opencontainers.image.revision" "${BUILD_REVISION}"

####################
# Validate version #
####################
ValidateLabel "org.opencontainers.image.version" "${BUILD_VERSION}"

#################
# Report status #
#################
Footer
