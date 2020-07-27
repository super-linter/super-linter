#!/usr/bin/env bash

################################################################################
############# Cleanup Image on DockerHub @admiralawkbar ########################
################################################################################

# NOTES: This script is used to remove a tagged image on DockerHub
# Its based on being built from a GitHub Action, but could be easily updated
# To be ran in a different medium.
#
# PRE-Requirements:
# - Dockerfile
# - System with Docker installed
# - Global variables met

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}" # GitHub Workspace
DOCKER_USERNAME="${DOCKER_USERNAME}"   # Username to login to DockerHub
DOCKER_PASSWORD="${DOCKER_PASSWORD}"   # Password to login to DockerHub
IMAGE_REPO="${IMAGE_REPO}"             # Image repo to upload the image
IMAGE_VERSION="${IMAGE_VERSION}"       # Version to tag the image
DOCKERFILE_PATH="${DOCKERFILE_PATH}"   # Path to the Dockerfile to be uploaded

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  echo ""
  echo "-------------------------------------------------------"
  echo "----- GitHub Actions remove image from DockerHub ------"
  echo "-------------------------------------------------------"
  echo ""
}
################################################################################
#### Function ValidateInput ####################################################
ValidateInput() {
  # Need to validate we have the basic variables
  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Gathering variables..."
  echo "----------------------------------------------"
  echo ""

  ############################
  # Validate GITHUB_WORKSPACE #
  ############################
  if [ -z "${GITHUB_WORKSPACE}" ]; then
    error "Failed to get [GITHUB_WORKSPACE]!${NC}"
    fatal "[${GITHUB_WORKSPACE}]${NC}"
  else
    echo "Successfully found:[GITHUB_WORKSPACE], value:[${GITHUB_WORKSPACE}]"
  fi

  #######################
  # Validate IMAGE_REPO #
  #######################
  if [ -z "${IMAGE_REPO}" ]; then
    # No repo was pulled
    error "Failed to get [IMAGE_REPO]!${NC}"
    fatal "[${IMAGE_REPO}]${NC}"
  elif [[ ${IMAGE_REPO} == "github/super-linter" ]]; then
    # Found our main repo
    echo "Successfully found:[IMAGE_REPO], value:[${IMAGE_REPO}]"
  else
    # This is a fork and we cant pull vars or any info
    warn "No image to cleanup as this is a forked branch, and not being built with current automation!${NC}"
    exit 0
  fi

  ##########################
  # Validate IMAGE_VERSION #
  ##########################
  if [ -z "${IMAGE_VERSION}" ]; then
    error "Failed to get [IMAGE_VERSION]!${NC}"
    fatal "[${IMAGE_VERSION}]${NC}"
  else
    echo "Successfully found:[IMAGE_VERSION], value:[${IMAGE_VERSION}]"
  fi

  ############################
  # Validate DOCKER_USERNAME #
  ############################
  if [ -z "${DOCKER_USERNAME}" ]; then
    error "Failed to get [DOCKER_USERNAME]!${NC}"
    fatal "[${DOCKER_USERNAME}]${NC}"
  else
    echo "Successfully found:[DOCKER_USERNAME], value:[${DOCKER_USERNAME}]"
  fi

  ############################
  # Validate DOCKER_PASSWORD #
  ############################
  if [ -z "${DOCKER_PASSWORD}" ]; then
    error "Failed to get [DOCKER_PASSWORD]!${NC}"
    fatal "[${DOCKER_PASSWORD}]${NC}"
  else
    echo "Successfully found:[DOCKER_PASSWORD], value:[********]"
  fi

  ##################################################
  # Check if we need to get the name of the branch #
  ##################################################
  if [[ ${IMAGE_VERSION} != "latest" ]]; then
    ##################################
    # Remove non alpha-numeric chars #
    ##################################
    IMAGE_VERSION=$(echo "${IMAGE_VERSION}" | tr -cd '[:alnum:]')
  else
    #############################################
    # Image is 'latest' and we will not destroy #
    #############################################
    error "Image Tag is set to:[latest]..."
    error "We will never destroy latest..."
    fatal "Bye!"
  fi
}
################################################################################
#### Function LoginToDocker ####################################################
LoginToDocker() {
  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Login to DockerHub..."
  echo "----------------------------------------------"
  echo ""

  ######################
  # Login to DockerHub #
  ######################
  LOGIN_CMD=$(docker login --username "${DOCKER_USERNAME}" --password "${DOCKER_PASSWORD}" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # ERROR
    error "Failed to authenticate to DockerHub!${NC}"
    fatal "[${LOGIN_CMD}]${NC}"
  else
    # SUCCESS
    echo "Successfully authenticated to DockerHub!"
  fi
}
################################################################################
#### Function RemoveImage ######################################################
RemoveImage() {
  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Removing the DockerFile image:[${IMAGE_REPO}:${IMAGE_VERSION}]"
  echo "----------------------------------------------"
  echo ""

  #####################################
  # Create Token to auth to DockerHub #
  #####################################
  TOKEN=$(curl -s -k \
    -H "Content-Type: application/json" \
    -X POST \
    -d "{\"username\": \"${DOCKER_USERNAME}\", \"password\": \"${DOCKER_PASSWORD}\"}" \
    "https://hub.docker.com/v2/users/login/" | jq -r .token 2>&1)

  #######################
  # Load the ERROR_CODE #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # ERROR
    error "Failed to gain token from DockerHub!${NC}"
    fatal "[${TOKEN}]${NC}"
  else
    # SUCCESS
    echo "Successfully gained auth token from DockerHub!"
  fi

  #################################
  # Remove the tag from DockerHub #
  #################################
  REMOVE_CMD=$(curl "https://hub.docker.com/v2/repositories/${IMAGE_REPO}/tags/${IMAGE_VERSION}/" \
    -X DELETE \
    -H "Authorization: JWT ${TOKEN}" 2>&1)

  #######################
  # Load the ERROR_CODE #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ ${ERROR_CODE} -ne 0 ]; then
    # ERROR
    error "Failed to remove tag from DockerHub!${NC}"
    fatal "[${REMOVE_CMD}]${NC}"
  else
    # SUCCESS
    echo "Successfully [removed] Docker image tag:[${IMAGE_VERSION}] from DockerHub!"
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  echo ""
  echo "-------------------------------------------------------"
  echo "The step has completed"
  echo "-------------------------------------------------------"
  echo ""
}
################################################################################
################################## MAIN ########################################
################################################################################

##########
# Header #
##########
Header

##################
# Validate Input #
##################
ValidateInput

######################
# Login to DockerHub #
######################
LoginToDocker

####################
# Remove the image #
####################
RemoveImage

##########
# Footer #
##########
Footer
