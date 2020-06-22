#!/bin/bash

################################################################################
############# Deploy Container to DockerHub @admiralawkbar #####################
################################################################################

# NOTES: This script is used to upload a Dockerfile to DockerHub
# under the GitHub organization
# Its based on being built from a GitHub Action, but could be easily updated
# To be ran in a different medium.
#
# PRE-Reqs:
# - Dockerfile
# - System with Docker installed
# - Global variables met

###########
# Globals #
###########
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"  # GitHub Workspace
DOCKER_USERNAME="${DOCKER_USERNAME}"    # Username to login to DockerHub
DOCKER_PASSWORD="${DOCKER_PASSWORD}"    # Password to login to DockerHub
IMAGE_REPO="${IMAGE_REPO}"              # Image repo to upload the image
IMAGE_VERSION="${IMAGE_VERSION}"        # Version to tag the image
DOCKERFILE_PATH="${DOCKERFILE_PATH}"    # Path to the Dockerfile to be uploaded

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "-------------------------------------------------------"
  echo "------ GitHub Actions Upload image to DockerHub -------"
  echo "-------------------------------------------------------"
  echo ""
}
################################################################################
#### Function ValidateInput ####################################################
ValidateInput()
{
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
  if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERROR! Failed to get [GITHUB_WORKSPACE]!"
    echo "ERROR:[$GITHUB_WORKSPACE]"
    exit 1
  else
    echo "Successfully found:[GITHUB_WORKSPACE], value:[$GITHUB_WORKSPACE]"
  fi

  ############################
  # Validate DOCKER_USERNAME #
  ############################
  if [ -z "$DOCKER_USERNAME" ]; then
    echo "ERROR! Failed to get [DOCKER_USERNAME]!"
    echo "ERROR:[$DOCKER_USERNAME]"
    exit 1
  else
    echo "Successfully found:[DOCKER_USERNAME], value:[$DOCKER_USERNAME]"
  fi

  ############################
  # Validate DOCKER_PASSWORD #
  ############################
  if [ -z "$DOCKER_PASSWORD" ]; then
    echo "ERROR! Failed to get [DOCKER_PASSWORD]!"
    echo "ERROR:[$DOCKER_PASSWORD]"
    exit 1
  else
    echo "Successfully found:[DOCKER_PASSWORD], value:[********]"
  fi

  #######################
  # Validate IMAGE_REPO #
  #######################
  if [ -z "$IMAGE_REPO" ]; then
    echo "ERROR! Failed to get [IMAGE_REPO]!"
    echo "ERROR:[$IMAGE_REPO]"
    exit 1
  else
    echo "Successfully found:[IMAGE_REPO], value:[$IMAGE_REPO]"
  fi

  ##########################
  # Validate IMAGE_VERSION #
  ##########################
  if [ -z "$IMAGE_VERSION" ]; then
    echo "WARN! Failed to get [IMAGE_VERSION]!"
    echo "Pulling from Branch Name..."
    ##############################
    # Get the name of the branch #
    ##############################
    BRANCH_NAME=$(git branch --contains "$GITHUB_SHA" |awk '{print $2}' 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to get branch name!"
      echo "ERROR:[$BRANCH_NAME]"
      exit 1
    fi

    ##################################
    # Remove non alpha-numeric chars #
    ##################################
    BRANCH_NAME=$(echo "$BRANCH_NAME" | tr -cd '[:alnum:]')

    ############################################
    # Set the IMAGE_VERSION to the BRANCH_NAME #
    ############################################
    IMAGE_VERSION="$BRANCH_NAME"
    echo "Tag:[$IMAGE_VERSION]"
  else
    echo "Successfully found:[IMAGE_VERSION], value:[$IMAGE_VERSION]"
  fi

  ############################
  # Validate DOCKERFILE_PATH #
  ############################
  if [ -z "$DOCKERFILE_PATH" ]; then
    echo "ERROR! Failed to get [DOCKERFILE_PATH]!"
    echo "ERROR:[$DOCKERFILE_PATH]"
    exit 1
  else
    echo "Successfully found:[DOCKERFILE_PATH], value:[$DOCKERFILE_PATH]"
  fi
}
################################################################################
#### Function LoginToDocker ####################################################
LoginToDocker()
{
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
  LOGIN_CMD=$(docker login --username "$DOCKER_USERNAME" --password "$DOCKER_PASSWORD" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to authenticate to DockerHub!"
    echo "ERROR:[$LOGIN_CMD]"
    exit 1
  else
    # SUCCESS
    echo "Successfully authenticated to DockerHub!"
  fi
}
################################################################################
#### Function BuildImage #######################################################
BuildImage()
{
  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Building the DockerFile image..."
  echo "----------------------------------------------"
  echo ""


  ################################
  # Validate the DOCKERFILE_PATH #
  ################################
  if [ ! -f "$DOCKERFILE_PATH" ]; then
    # No file found
    echo "ERROR! failed to find Dockerfile at:[$DOCKERFILE_PATH]"
    echo "Please make sure you give full path!"
    echo "Example:[/configs/Dockerfile] or [Dockerfile] if at root directory"
    exit 1
  fi

  ###################
  # Build the image #
  ###################
  docker build --no-cache -t "$IMAGE_REPO:$IMAGE_VERSION" -f "$DOCKERFILE_PATH" . 2>&1

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # ERROR
    echo "ERROR! failed to [build] Dockerfile!"
    exit 1
  else
    # SUCCESS
    echo "Successfully Built image!"
    echo "Info:[$BUILD_CMD]"
  fi
}
################################################################################
#### Function UploadImage ######################################################
UploadImage()
{
  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Uploading the DockerFile image..."
  echo "----------------------------------------------"
  echo ""

  ############################################
  # Upload the docker image that was created #
  ############################################
  docker push "$IMAGE_REPO:$IMAGE_VERSION" 2>&1

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # ERROR
    echo "ERROR! failed to [upload] Dockerfile!"
    exit 1
  else
    # SUCCESS
    echo "Successfully Uploaded Docker image to DockerHub!"
  fi

  #########################
  # Get Image information #
  #########################
  IFS=$'\n' # Set the delimit to newline
  GET_INFO_CMD=$(docker images | grep "$IMAGE_REPO" | grep "$IMAGE_VERSION" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to get information about built Image!"
    echo "ERROR:[$GET_INFO_CMD]"
    exit 1
  else
    ################
    # Get the data #
    ################
    REPO=$(echo "$GET_INFO_CMD" | awk '{print $1}')
    TAG=$(echo "$GET_INFO_CMD" | awk '{print $2}')
    IMAGE_ID=$(echo "$GET_INFO_CMD" | awk '{print $3}')
    # shellcheck disable=SC2116
    SIZE=$(echo "${GET_INFO_CMD##* }")

    ###################
    # Print the goods #
    ###################
    echo "----------------------------------------------"
    echo "Docker Image Details:"
    echo "Repository:[$REPO]"
    echo "Tag:[$TAG]"
    echo "Image_ID:[$IMAGE_ID]"
    echo "Size:[$SIZE]"
    echo "----------------------------------------------"
  fi
}
################################################################################
#### Function Footer ###########################################################
Footer()
{
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

###################
# Build the image #
###################
BuildImage

####################
# Upload the image #
####################
UploadImage

##########
# Footer #
##########
Footer
