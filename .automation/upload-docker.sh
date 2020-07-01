#!/usr/bin/env bash

################################################################################
############# Deploy Container to DockerHub @admiralawkbar #####################
################################################################################

# NOTES: This script is used to upload a Dockerfile to DockerHub
# under the GitHub organization
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
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"  # GitHub Workspace
DOCKER_USERNAME="${DOCKER_USERNAME}"    # Username to login to DockerHub
DOCKER_PASSWORD="${DOCKER_PASSWORD}"    # Password to login to DockerHub
GPR_USERNAME="${GPR_USERNAME}"          # Username to login to GitHub package registry
GPR_TOKEN="${GPR_TOKEN}"                # Password to login to GitHub package registry
REGISTRY="${REGISTRY}"                  # What registry to upload | <GPR> or <Docker>
IMAGE_REPO="${IMAGE_REPO}"              # Image repo to upload the image
IMAGE_VERSION="${IMAGE_VERSION}"        # Version to tag the image
DOCKERFILE_PATH="${DOCKERFILE_PATH}"    # Path to the Dockerfile to be uploaded
MAJOR_TAG=''                            # Major tag version if we need to update it
UPDATE_MAJOR_TAG=0                      # Flag to deploy the major tag version as well

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header()
{
  echo ""
  echo "-------------------------------------------------------"
  echo "---- GitHub Actions Upload image to [$REGISTRY] ----"
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

  #############################
  # Validate GITHUB_WORKSPACE #
  #############################
  if [ -z "$GITHUB_WORKSPACE" ]; then
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [GITHUB_WORKSPACE]!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$GITHUB_WORKSPACE]"
    exit 1
  else
    echo -e "${NC}${F[B]}Successfully found:${F[W]}[GITHUB_WORKSPACE]${F[B]}, value:${F[W]}[$GITHUB_WORKSPACE]${NC}"
  fi

  #####################
  # Validate REGISTRY #
  #####################
  if [ -z "$REGISTRY" ]; then
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [REGISTRY]!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$REGISTRY]"
    exit 1
  else
    echo -e "${NC}${F[B]}Successfully found:${F[W]}[REGISTRY]${F[B]}, value:${F[W]}[$REGISTRY]${NC}"
  fi

  #####################################################
  # See if we need values for GitHub package Registry #
  #####################################################
  if [[ "$REGISTRY" == "GPR" ]]; then
    #########################
    # Validate GPR_USERNAME #
    #########################
    if [ -z "$GPR_USERNAME" ]; then
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [GPR_USERNAME]!"
      echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$GPR_USERNAME]"
      exit 1
    else
      echo -e "${NC}${F[B]}Successfully found:${F[W]}[GPR_USERNAME]${F[B]}, value:${F[W]}[$GPR_USERNAME]${NC}"
    fi

    ######################
    # Validate GPR_TOKEN #
    ######################
    if [ -z "$GPR_TOKEN" ]; then
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [GPR_TOKEN]!"
      echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$GPR_TOKEN]"
      exit 1
    else
      echo -e "${NC}${F[B]}Successfully found:${F[W]}[GPR_TOKEN]${F[B]}, value:${F[W]}[********]${NC}"
    fi
  ########################################
  # See if we need values for Ducker hub #
  ########################################
  elif [[ "$REGISTRY" == "Docker" ]]; then
    ############################
    # Validate DOCKER_USERNAME #
    ############################
    if [ -z "$DOCKER_USERNAME" ]; then
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [DOCKER_USERNAME]!"
      echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$DOCKER_USERNAME]"
      exit 1
    else
      echo -e "${NC}${F[B]}Successfully found:${F[W]}[DOCKER_USERNAME]${F[B]}, value:${F[W]}[$DOCKER_USERNAME]${NC}"
    fi

    ############################
    # Validate DOCKER_PASSWORD #
    ############################
    if [ -z "$DOCKER_PASSWORD" ]; then
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [DOCKER_PASSWORD]!"
      echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$DOCKER_PASSWORD]"
      exit 1
    else
      echo -e "${NC}${F[B]}Successfully found:${F[W]}[DOCKER_PASSWORD]${F[B]}, value:${F[B]}[********]${NC}"
    fi
  ###########################################
  # We were not passed a registry to update #
  ###########################################
  else
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to find a valid registry!"
    echo "Registry:[$REGISTRY]"
    exit 1
  fi


  #######################
  # Validate IMAGE_REPO #
  #######################
  if [ -z "$IMAGE_REPO" ]; then
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [IMAGE_REPO]!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$IMAGE_REPO]"
    exit 1
  else
    echo -e "${NC}${F[B]}Successfully found:${F[W]}[IMAGE_REPO]${F[B]}, value:${F[W]}[$IMAGE_REPO]${NC}"
    ###############################################
    # Need to see if GPR registry and update name #
    ###############################################
    if [[ "$REGISTRY" == "GPR" ]]; then
      NAME="docker.pkg.github.com/$IMAGE_REPO/super-linter"
      IMAGE_REPO="$NAME"
      echo "Updated [IMAGE_REPO] to:[$IMAGE_REPO] for GPR"
    fi
  fi

  ##########################
  # Validate IMAGE_VERSION #
  ##########################
  if [ -z "$IMAGE_VERSION" ]; then
    echo -e "${NC}${F[Y]}WARN!${NC} Failed to get [IMAGE_VERSION]!"
    echo "Pulling from Branch Name..."
    ##############################
    # Get the name of the branch #
    ##############################
    BRANCH_NAME=$(git -C "$GITHUB_WORKSPACE" branch --contains "$GITHUB_SHA" |awk '{print $2}' 2>&1)

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get branch name!"
      echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$BRANCH_NAME]"
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
    echo -e "${NC}${F[B]}Successfully found:${F[W]}[IMAGE_VERSION]${F[B]}, value:${F[W]}[$IMAGE_VERSION]${NC}"
  fi

  ##################################
  # Set regex for getting tag info #
  ##################################
  REGEX='(v[0-9]+\.[0-9]+\.[0-9]+)' # Matches 'v1.2.3'

  ######################################################################
  # Check if this is a latest to a versioned release at create new tag #
  ######################################################################
  if [[ "$IMAGE_VERSION" =~ $REGEX ]]; then
    # Need to get the major version, and set flag to update

    #####################
    # Set the major tag #
    #####################
    MAJOR_TAG=$(echo "$IMAGE_VERSION" | cut -d '.' -f1)

    ###################################
    # Set flag for updating major tag #
    ###################################
    UPDATE_MAJOR_TAG=1

    echo "- Also deploying a major tag of:[$MAJOR_TAG]"
  fi

  ############################
  # Validate DOCKERFILE_PATH #
  ############################
  if [ -z "$DOCKERFILE_PATH" ]; then
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get [DOCKERFILE_PATH]!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$DOCKERFILE_PATH]"
    exit 1
  else
    echo -e "${NC}${F[B]}Successfully found:${F[W]}[DOCKERFILE_PATH]${F[B]}, value:${F[W]}[$DOCKERFILE_PATH]${NC}"
  fi
}
################################################################################
#### Function Authenticate #####################################################
Authenticate()
{
  ################
  # Pull in Vars #
  ################
  USERNAME="$1"   # Name to auth with
  PASSWORD="$2"   # Password to auth with
  URL="$3"        # Url to auth towards
  NAME="$4"       # name of the service

  ################
  # Print header #
  ################
  echo ""
  echo "----------------------------------------------"
  echo "Login to $NAME..."
  echo "----------------------------------------------"
  echo ""

  ###################
  # Auth to service #
  ###################
  LOGIN_CMD=$(docker login "$URL" --username "$USERNAME" --password "$PASSWORD" 2>&1)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # ERROR
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to authenticate to $NAME!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$LOGIN_CMD]"
    exit 1
  else
    # SUCCESS
    echo -e "${NC}${F[B]}Successfully authenticated to $NAME!${NC}"
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
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} failed to find Dockerfile at:[$DOCKERFILE_PATH]"
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
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} failed to [build] Dockerfile!"
    exit 1
  else
    # SUCCESS
    echo -e "${NC}${F[B]}Successfully Built image!${NC}"
  fi

  ########################################################
  # Need to see if we need to tag a major update as well #
  ########################################################
  if [ $UPDATE_MAJOR_TAG -eq 1 ]; then
    # Tag the image with the major tag as well
    docker build -t "$IMAGE_REPO:$MAJOR_TAG" -f "$DOCKERFILE_PATH" . 2>&1

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # ERROR
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} failed to [tag] Dockerfile!"
      exit 1
    else
      # SUCCESS
      echo -e "${NC}${F[B]}Successfully tagged image!${NC}"
    fi
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
  echo "Uploading the DockerFile image to $REGISTRY..."
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
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} failed to [upload] Dockerfile!"
    exit 1
  else
    # SUCCESS
    echo -e "${NC}${F[B]}Successfully Uploaded Docker image:${F[W]}[$IMAGE_VERSION]${F[B]} to $REGISTRY!${NC}"
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
    echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Failed to get information about built Image!"
    echo -e "${NC}${B[R]}${F[W]}ERROR:${NC}[$GET_INFO_CMD]"
    exit 1
  else
    ################
    # Get the data #
    ################
    REPO=$(echo "$GET_INFO_CMD" | awk '{print $1}')
    TAG=$(echo "$GET_INFO_CMD" | awk '{print $2}')
    IMAGE_ID=$(echo "$GET_INFO_CMD" | awk '{print $3}')
    SIZE="${GET_INFO_CMD##* }"

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

  ###############################################################
  # Check if we need to upload the major tagged version as well #
  ###############################################################
  if [ $UPDATE_MAJOR_TAG -eq 1 ]; then
    ############################################
    # Upload the docker image that was created #
    ############################################
    docker push "$IMAGE_REPO:$MAJOR_TAG" 2>&1

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # ERROR
      echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} failed to [upload] MAJOR_TAG:[$MAJOR_TAG] Dockerfile!"
      exit 1
    else
      # SUCCESS
      echo -e "${NC}${F[B]}Successfully Uploaded TAGOR_TAG:${F[W]}[$MAJOR_TAG]${F[B]} Docker image to $REGISTRY!${NC}"
    fi
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

###################
# Build the image #
###################
BuildImage

######################
# Login to DockerHub #
######################
if [[ "$REGISTRY" == "Docker" ]]; then
  # Authenticate "Username" "Password" "Url" "Name"
  Authenticate "$DOCKER_USERNAME" "$DOCKER_PASSWORD" "" "Dockerhub"

####################################
# Login to GitHub Package Registry #
####################################
elif [[ "$REGISTRY" == "GPR" ]]; then
  # Authenticate "Username" "Password" "Url" "Name"
  Authenticate "$GPR_USERNAME" "$GPR_TOKEN" "https://docker.pkg.github.com" "GitHub Package Registry"

else
  #########
  # ERROR #
  #########
  echo -e "${NC}${B[R]}${F[W]}ERROR!${NC} Registry not set correctly!"
  echo "Registry:[$REGISTRY]"
  exit 1
fi

####################
# Upload the image #
####################
UploadImage

##########
# Footer #
##########
Footer
