#!/bin/bash

################################################################################
################################################################################
############# EntryPoint for Docker NodeJS Deploy Serverless ###################
################################################################################
################################################################################

#########
# NOTE: #
#########
# - https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-deploying.html
# - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where
# - https://developer.github.com/v3/checks/runs/

###########
# Globals #
###########
AWS_REGION=''                               # AWS region to deploy
S3_BUCKET=''                                # AWS S3 bucket to package and deploy
AWS_SAM_TEMPLATE=''                         # Path to the SAM template in the user repository
CHECK_NAME='GitHub AWS Deploy Serverless'   # Name of the GitHub Action
CHECK_ID=''                                 # GitHub Check ID that is created
AWS_STACK_NAME=''                           # AWS Cloud Formation Stack name of SAM
SAM_CMD='sam'                               # Path to AWS SAM Exec
RUNTIME=''                                  # Runtime for AWS SAM App

###################
# GitHub ENV Vars #
###################
GITHUB_SHA="${GITHUB_SHA}"                        # GitHub sha from the commit
GITHUB_EVENT_PATH="${GITHUB_EVENT_PATH}"          # Github Event Path
GITHUB_TOKEN=''                                   # GitHub token
GITHUB_WORKSPACE="${GITHUB_WORKSPACE}"            # Github Workspace
GITHUB_URL='https://api.github.com'               # GitHub API URL

###################
# AWS Secret Vars #
###################
# shellcheck disable=SC2034
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY}"             # aws_access_key_id to auth
# shellcheck disable=SC2034
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_KEY}"         # aws_secret_access_key to auth

##############
# Built Vars #
##############
GITHUB_ORG=''           # Name of the GitHub Org
GITHUB_REPO=''          # Name of the GitHub repo
USER_CONFIG_FILE="$GITHUB_WORKSPACE/.github/aws-config.yml"   # File with users configurations
START_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")                      # YYYY-MM-DDTHH:MM:SSZ
FINISHED_DATE=''        # YYYY-MM-DDTHH:MM:SSZ when complete
ACTION_CONCLUSTION=''   # success, failure, neutral, cancelled, timed_out, or action_required.
ACTION_OUTPUT=''        # String to pass back to the user on the output
ERROR_FOUND=0           # Set to 1 if any errors occur in the build before the package and deploy
ERROR_CAUSE=''          # String to pass of error that was detected

################
# Default Vars #
################
DEFAULT_OUTPUT='json'                     # Default Output format
DEFAULT_REGION='us-west-2'                # Default region to deploy
LOCAL_CONFIG_FILE='/root/.aws/config'     # AWS Config file
AWS_PACKAGED='packaged.yml'               # Created SAM Package
DEBUG=0                                   # Debug=0 OFF | Debug=1 ON
#NVM_SRC='/usr/local/nvm/nvm.sh'          # Source for NVM


######################################################
# Variables we need to set in the ~/.aws/credentials #
# aws_access_key_id                                  #
# aws_secret_access_key                              #
######################################################

#################################################
# Variables we need to set in the ~/.aws/config #
# region                                        #
# output                                        #
#################################################

################################################################################
######################### SUB ROUTINES BELOW ###################################
################################################################################
################################################################################
#### Function ValidateConfigurationFile ########################################
ValidateConfigurationFile()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Validating input file..."

  ####################################################################
  # Validate the config file is in the repository and pull variables #
  ####################################################################
  if [ ! -f "$USER_CONFIG_FILE" ]; then
    # User file not found
    echo "ERROR! Failed to find configuration file in user repository!"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to find configuration file in user repository!'
  else
    echo "Success! Found User config file at:[$USER_CONFIG_FILE]"
  fi

  ########################################
  # Map the variables to local variables #
  ########################################

  #######################
  #######################
  ## Get the s3_bucket ##
  #######################
  #######################
  S3_BUCKET=$(yq -r .s3_bucket "$USER_CONFIG_FILE")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ] || [ "$S3_BUCKET" == "null" ]; then
    echo "ERROR! Failed to get [s3_bucket]!"
    echo "ERROR:[$S3_BUCKET]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [s3_bucket]!'
  else
    echo "Successfully found:[s3_bucket]"
  fi

  ############################################
  # Clean any whitespace that may be entered #
  ############################################
  S3_BUCKET_NO_WHITESPACE="$(echo "${S3_BUCKET}" | tr -d '[:space:]')"
  S3_BUCKET=$S3_BUCKET_NO_WHITESPACE

  ############################
  ############################
  ## Get the AWS Stack Name ##
  ############################
  ############################
  AWS_STACK_NAME=$(yq -r .aws_stack_name "$USER_CONFIG_FILE")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ] || [ "$AWS_STACK_NAME" == "null" ]; then
    echo "ERROR! Failed to get [aws_stack_name]!"
    echo "ERROR:[$AWS_STACK_NAME]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [aws_stack_name]!'
  else
    echo "Successfully found:[aws_stack_name]"
  fi

  ############################################
  # Clean any whitespace that may be entered #
  ############################################
  AWS_STACK_NAME_NO_WHITESPACE="$(echo "${AWS_STACK_NAME}" | tr -d '[:space:]')"
  AWS_STACK_NAME=$AWS_STACK_NAME_NO_WHITESPACE

  ##############################
  ##############################
  ## Get the AWS SAM Template ##
  ##############################
  ##############################
  AWS_SAM_TEMPLATE=$(yq -r .sam_template "$USER_CONFIG_FILE")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ] || [ "$AWS_SAM_TEMPLATE" == "null" ]; then
    echo "ERROR! Failed to get [sam_template]!"
    echo "ERROR:[$AWS_SAM_TEMPLATE]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [sam_template]!'
  else
    echo "Successfully found:[sam_template]"
  fi

  ############################################
  # Clean any whitespace that may be entered #
  ############################################
  AWS_SAM_TEMPLATE_NO_WHITESPACE="$(echo "${AWS_SAM_TEMPLATE}" | tr -d '[:space:]')"
  AWS_SAM_TEMPLATE=$AWS_SAM_TEMPLATE_NO_WHITESPACE

  ####################
  ####################
  ## Get the region ##
  ####################
  ####################
  AWS_REGION=$(yq -r .region "$USER_CONFIG_FILE")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ] || [ "$AWS_REGION" == "null" ]; then
    # Error
    echo "ERROR! Failed to get [region]!"
    echo "ERROR:[$AWS_REGION]"
    # Fall back to default
    echo "No value provided... Defaulting to:[$DEFAULT_REGION]"
    AWS_REGION="$DEFAULT_REGION"
  else
    echo "Successfully found:[region]"
  fi

  ############################################
  # Clean any whitespace that may be entered #
  ############################################
  AWS_REGION_NO_WHITESPACE="$(echo "${AWS_REGION}" | tr -d '[:space:]')"
  AWS_REGION=$AWS_REGION_NO_WHITESPACE
}
################################################################################
#### Function CreateLocalConfiguration #########################################
CreateLocalConfiguration()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Creating local configuration file..."

  ########################################
  # Create the directory if not existant #
  ########################################
  MK_DIR_CMD=$(mkdir /root/.aws)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    echo "ERROR! Failed to create root directory!"
    echo "ERROR:[$MK_DIR_CMD]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to create root directory!'
  fi

  #######################################
  # Create the local file ~/.aws/config #
  #######################################
  CREATE_CONFIG_CMD=$(echo -e "[default]\nregion=$AWS_REGION\noutput=$DEFAULT_OUTPUT" >> $LOCAL_CONFIG_FILE )

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    echo "ERROR! Failed to create file:[$LOCAL_CONFIG_FILE]!"
    echo "ERROR:[$CREATE_CONFIG_CMD]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to create file:[$LOCAL_CONFIG_FILE]!"
  else
    echo "Successfully created:[$LOCAL_CONFIG_FILE]"
  fi
}
################################################################################
#### Function GetGitHubVars ####################################################
GetGitHubVars()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Gathering GitHub information..."

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_SHA" ]; then
    echo "ERROR! Failed to get [GITHUB_SHA]!"
    echo "ERROR:[$GITHUB_SHA]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [GITHUB_SHA]!'
  else
    echo "Successfully found:[GITHUB_SHA]"
  fi

  # ############################
  # # Validate we have a value #
  # ############################
  # if [ -z "$GITHUB_TOKEN" ]; then
  #   echo "ERROR! Failed to get [GITHUB_TOKEN]!"
  #   echo "ERROR:[$GITHUB_TOKEN]"
  #   ###################################################
  #   # Set the ERROR_FOUND flag to 1 to drop out build #
  #   ###################################################
  #   ERROR_FOUND=1
  #   ERROR_CAUSE='Failed to get [GITHUB_TOKEN]!'
  # else
  #   echo "Successfully found:[GITHUB_TOKEN]"
  # fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_WORKSPACE" ]; then
    echo "ERROR! Failed to get [GITHUB_WORKSPACE]!"
    echo "ERROR:[$GITHUB_WORKSPACE]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [GITHUB_WORKSPACE]!'
  else
    echo "Successfully found:[GITHUB_WORKSPACE]"
  fi

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_EVENT_PATH" ]; then
    echo "ERROR! Failed to get [GITHUB_EVENT_PATH]!"
    echo "ERROR:[$GITHUB_EVENT_PATH]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [GITHUB_EVENT_PATH]!'
  else
    echo "Successfully found:[GITHUB_EVENT_PATH]"
  fi

  ##################################################
  # Need to pull the GitHub Vars from the env file #
  ##################################################

  ######################
  # Get the GitHub Org #
  ######################
  # shellcheck disable=SC2002
  GITHUB_ORG=$(cat "$GITHUB_EVENT_PATH" | jq -r '.repository.owner.login' )

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_ORG" ]; then
    echo "ERROR! Failed to get [GITHUB_ORG]!"
    echo "ERROR:[$GITHUB_ORG]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [GITHUB_ORG]!'
  else
    echo "Successfully found:[GITHUB_ORG]"
  fi

  #######################
  # Get the GitHub Repo #
  #######################
  # shellcheck disable=SC2002
  GITHUB_REPO=$(cat "$GITHUB_EVENT_PATH"| jq -r '.repository.name' )

  ############################
  # Validate we have a value #
  ############################
  if [ -z "$GITHUB_REPO" ]; then
    echo "ERROR! Failed to get [GITHUB_REPO]!"
    echo "ERROR:[$GITHUB_REPO]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to get [GITHUB_REPO]!'
  else
    echo "Successfully found:[GITHUB_REPO]"
  fi
}
################################################################################
#### Function ValidateAWSCLI ###################################################
ValidateAWSCLI()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Validating AWS information..."

  ############################################
  ############################################
  ## Validate we have access to the aws cli ##
  ############################################
  ############################################
  VALIDATE_AWS_CMD=$(which aws )

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error failed to find binary
    echo "ERROR! Failed to find aws cli!"
    echo "ERROR:[$VALIDATE_AWS_CMD]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to find aws cli!'
  else
    echo "Successfully validated:[aws cli]"
  fi

  ############################################
  ############################################
  ## Validate we have access to the aws cli ##
  ############################################
  ############################################
  VALIDATE_SAM_CMD=$(which "$SAM_CMD" )

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Error failed to find binary
    echo "ERROR! Failed to find aws sam cli!"
    echo "ERROR:[$VALIDATE_SAM_CMD]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to find aws sam cli!'
  else
    echo "Successfully validated:[aws sam cli]"
  fi

  #######################################
  #######################################
  ## Validate we can see AWS s3 bucket ##
  #######################################
  #######################################
  CHECK_BUCKET_CMD=$(aws s3 ls "$S3_BUCKET" )

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    echo "ERROR! Failed to access AWS S3 bucket:[$S3_BUCKET]"
    echo "ERROR:[$CHECK_BUCKET_CMD]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to access AWS S3 bucket:[$S3_BUCKET]"
  else
    echo "Successfully validated:[aws s3 bucket authorization]"
  fi
}
################################################################################
#### Function CreateCheck ######################################################
CreateCheck()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Creating GitHub Check..."

  ##########################################
  # Call to Github to create the Check API #
  ##########################################
  CREATE_CHECK_CMD=$( curl -k --fail -X POST \
    --url "$GITHUB_URL/repos/$GITHUB_ORG/$GITHUB_REPO/check-runs" \
    -H 'accept: application/vnd.github.antiope-preview+json' \
    -H "authorization: Bearer $GITHUB_TOKEN" \
    -H 'content-type: application/json' \
    --data "{ \"name\": \"$CHECK_NAME\", \"head_sha\": \"$GITHUB_SHA\", \"status\": \"in_progress\", \"started_at\": \"$START_DATE\" }" \
    )

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    echo "ERROR! Failed to create GitHub Check!"
    echo "ERROR:[$CREATE_CHECK_CMD]"
    exit 1
  else
    echo "Successfully Created GitHub Check"
    #############################################
    # Need to get the check ID that was created #
    #############################################
    CHECK_ID=$(echo "$CREATE_CHECK_CMD"| jq -r '.id' )

    ############################
    # Validate we have a value #
    ############################
    if [ -z "$CHECK_ID" ]; then
      echo "ERROR! Failed to get [CHECK_ID]!"
      echo "ERROR:[$CHECK_ID]"
      exit 1
    fi
  fi
}
################################################################################
#### Function RunDeploy ########################################################
RunDeploy()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Running AWS Deploy Process..."

  # Need to complete the following actions to deploy to AWS Serverless:
  # https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-deploying.html
  # - Package SAM template
  # - Deploy packaged SAM template

  # Go into loop if no errors detected
  if [ $ERROR_FOUND -eq 0 ]; then
    #################
    # Build the App #
    #################
    BuidApp
  fi

  # Go into loop if no errors detected
  if [ $ERROR_FOUND -eq 0 ]; then
    ########################
    # Package the template #
    ########################
    PackageTemplate
  fi

  # Go into loop if no errors detected
  if [ $ERROR_FOUND -eq 0 ]; then
    #######################
    # Deploy the template #
    #######################
    DeployTemplate
  fi

  # Go into loop if no errors detected
  if [ $ERROR_FOUND -eq 0 ]; then
    #######################
    # Deploy the template #
    #######################
    GetOutput
  fi
}
################################################################################
#### Function BuidApp ##########################################################
BuidApp()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Building the SAM application..."

  #########################
  # Build the application #
  #########################
  # shellcheck disable=SC2164
  BUILD_CMD=$(cd "$GITHUB_WORKSPACE" ; "$SAM_CMD" build)

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Errors found
    echo "ERROR! Failed to build SAM application!"
    echo "ERROR:[$BUILD_CMD]"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to build SAM application:[$BUILD_CMD]!"
  else
    echo "Successfully built local AWS SAM Application"
  fi
}
################################################################################
#### Function PackageTemplate ##################################################
PackageTemplate()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Packaging the template..."

  ##############################################
  # Check the source code for the SAM template #
  ##############################################
  if [ ! -f "$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE" ]; then
    echo "ERROR! Failed to find:[$AWS_SAM_TEMPLATE] in root of repository!"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to find:[$AWS_SAM_TEMPLATE] in repository!"
  else
    echo "Successfully found:[$AWS_SAM_TEMPLATE]"
  fi

  ############################
  # Package the SAM template #
  ############################
  # shellcheck disable=SC2164
  SAM_PACKAGE_CMD=$(cd "$GITHUB_WORKSPACE"; "$SAM_CMD" package --template-file "$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE" --s3-bucket "$S3_BUCKET" --output-template-file "$AWS_PACKAGED" --region "$AWS_REGION")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Errors found
    echo "ERROR! Failed to package SAM template!"
    echo "ERROR:[$SAM_PACKAGE_CMD]"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ERROR_FOUND=1
    ERROR_CAUSE='Failed to package SAM template!'
  else
    echo "Successfully packaged AWS SAM Application"
  fi
}
################################################################################
#### Function DeployTemplate ###################################################
DeployTemplate()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Deploying the template..."

  ############################################
  # Need to validate the package was created #
  ############################################
  if [ ! -f "$GITHUB_WORKSPACE/$AWS_PACKAGED" ]; then
    echo "ERROR! Failed to find created package:[$AWS_PACKAGED]"
    ###################################################
    # Set the ERROR_FOUND flag to 1 to drop out build #
    ###################################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to find created package:[$AWS_PACKAGED]"
  fi

  ###########################
  # Deploy the SAM template #
  ###########################
  # shellcheck disable=SC2164
  SAM_DEPLOY_CMD=$(cd "$GITHUB_WORKSPACE"; "$SAM_CMD" deploy --template-file "$GITHUB_WORKSPACE/$AWS_PACKAGED" --stack-name "$AWS_STACK_NAME" --capabilities CAPABILITY_IAM --region "$AWS_REGION")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Errors found
    echo "ERROR! Failed to deploy SAM template!"
    echo "ERROR:[$SAM_DEPLOY_CMD]"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ERROR_FOUND=1
    ACTION_CONCLUSTION='failure'
    ACTION_OUTPUT="Failed to deploy SAM App"
  else
    # Success
    echo "Successfully deployed AWS SAM Application"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ACTION_CONCLUSTION='success'
    ACTION_OUTPUT="Successfully Deployed SAM App"
  fi
}
################################################################################
#### Function GetOutput ########################################################
GetOutput()
{
  # Need to get the generated output from the stack
  # to display back to the user for consumption

  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Gathering Output from deployed SAM application..."

  ###########################
  # Get the output from AWS #
  ###########################
  IFS=$'\n' # Set IFS to newline
  OUTPUT_CMD=($(aws cloudformation describe-stacks --stack-name "$AWS_STACK_NAME" --query "Stacks[0].Outputs[*]" --region "$AWS_REGION"))

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    # Errors found
    echo "ERROR! Failed to get output from deployed SAM application!"
    echo "ERROR:[${OUTPUT_CMD[*]}]"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ERROR_FOUND=1
    ACTION_CONCLUSTION='failure'
    ACTION_OUTPUT="Failed to get output from deployed SAM application"
  else
    # Success
    ################################################
    # Itterate through all lines returned from AWS #
    ################################################
    echo "Output from deployed AWS SAM Application:[$AWS_STACK_NAME]:"
    for LINE in "${OUTPUT_CMD[@]}"
    do
      # Print the output to the logfile
      echo "$LINE"
    done
  fi
}
################################################################################
#### Function ValidateSourceAndRuntime #########################################
ValidateSourceAndRuntime()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Validating file:[$AWS_SAM_TEMPLATE] and NodeJS runtime..."

  ##############################################
  # Validate the user has the template.yml and #
  # we have the correct runtime set            #
  ##############################################

  ############################################
  # Look for the template in the source code #
  ############################################
  if [ ! -f "$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE" ]; then
    # Errors found
    echo "ERROR! Failed to find template:[$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE]!"
    #########################################
    # Need to update the ACTION_CONCLUSTION #
    #########################################
    ERROR_FOUND=1
    ERROR_CAUSE="Failed to find template:[$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE]!"
  else
    #################################
    # Get the runtime from template #
    #################################
    GET_RUNTIME_CMD=$(grep "Runtime" "$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE" )

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    #############################################
    # Clean any whitespace that may be returned #
    #############################################
    GET_RUNTIME_CMD_NO_WHITESPACE="$(echo "${GET_RUNTIME_CMD}" | tr -d '[:space:]')"
    GET_RUNTIME_CMD=$GET_RUNTIME_CMD_NO_WHITESPACE

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      # Errors found
      echo "ERROR! Failed to find [Runtime] in:[$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE]!"
      #########################################
      # Need to update the ACTION_CONCLUSTION #
      #########################################
      ERROR_FOUND=1
      ERROR_CAUSE="Failed to find [Runtime] in:[$GITHUB_WORKSPACE/$AWS_SAM_TEMPLATE]!"
    else
      echo "File found and Runtime variable parsed successfully"
      ###########################
      # Need to set the runtime #
      ###########################
      RUNTIME=$(echo "$GET_RUNTIME_CMD" | cut -f2 -d':')
    fi
  fi

  ##################################################
  # Need to set the Runtime for the app deployment #
  ##################################################
  #SetRuntime "$RUNTIME"
}
################################################################################
#### Function SetRuntime #######################################################
SetRuntime()
{
  ################
  # Pull in vars #
  ################
  RUNTIME=$1

  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Setting NodeJS runtime..."

  ###########################################
  # Remove the 'NodeJS' and get the version #
  ###########################################
  # shellcheck disable=SC2116
  VERSION=$(echo "${RUNTIME:6}")

  # echo "Version:[$VERSION]"

  ################
  # Set the vars #
  ################
  VERSION_MAJOR=$(echo "$VERSION" | cut -f1 -d'.')
  VERSION_MINOR=$(echo "$VERSION" | cut -f2 -d'.')

  ################################
  # Check if minor is x or undef #
  ################################
  if [ "$VERSION_MINOR" == "x" ] || [ -z "$VERSION_MINOR" ]; then
    #########################
    # Need to set to latest #
    #########################
    # shellcheck disable=SC1090
    NVM_INSTALL_CMD=$(. "$NVM_SRC"; nvm install "$VERSION_MAJOR" ; nvm use "$VERSION_MAJOR")

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to install and set Node:[$VERSION_MAJOR]!"
      echo "ERROR:[$NVM_INSTALL_CMD]"
      #########################################
      # Need to update the ACTION_CONCLUSTION #
      #########################################
      ERROR_FOUND=1
      ERROR_CAUSE="Failed to install and set Node:[$VERSION_MAJOR]!"
    fi
  else
    #########################
    # Running exact version #
    #########################
    # shellcheck disable=SC1090
    NVM_INSTALL_CMD=$(. "$NVM_SRC"; nvm install "$VERSION" ; nvm use "$VERSION")

    #######################
    # Load the error code #
    #######################
    ERROR_CODE=$?

    ##############################
    # Check the shell for errors #
    ##############################
    if [ $ERROR_CODE -ne 0 ]; then
      echo "ERROR! Failed to install and set Node:[$VERSION]!"
      echo "ERROR:[$NVM_INSTALL_CMD]"
      #########################################
      # Need to update the ACTION_CONCLUSTION #
      #########################################
      ERROR_FOUND=1
      ERROR_CAUSE="Failed to install and set Node:[$VERSION]!"
    fi
  fi
}
################################################################################
#### Function UpdateCheck ######################################################
UpdateCheck()
{
  ##########
  # Prints #
  ##########
  echo "--------------------------------------------"
  echo "Updating GitHub Check..."

  ###########################
  # Build the finished time #
  ###########################
  FINISHED_DATE=$(date +"%Y-%m-%dT%H:%M:%SZ")

  ######################################################
  # Set the conclusion to failure if errors were found #
  ######################################################
  if [ $ERROR_FOUND -ne 0 ]; then
    # Set conclusion
    ACTION_CONCLUSTION='failure'
    # Set the output
    ACTION_OUTPUT="$ERROR_CAUSE"
  fi

  ##########################################
  # Call to Github to update the Check API #
  ##########################################
  UPDATE_CHECK_CMD=$( curl -k --fail -X PATCH \
    --url "$GITHUB_URL/repos/$GITHUB_ORG/$GITHUB_REPO/check-runs/$CHECK_ID" \
    -H 'accept: application/vnd.github.antiope-preview+json' \
    -H "authorization: Bearer $GITHUB_TOKEN" \
    -H 'content-type: application/json' \
    --data "{ \"name\": \"$CHECK_NAME\", \"head_sha\": \"$GITHUB_SHA\", \"status\": \"completed\", \"completed_at\": \"$FINISHED_DATE\" , \"conclusion\": \"$ACTION_CONCLUSTION\" , \"output\": { \"title\": \"AWS SAM Deploy Summary\" , \"text\": \"$ACTION_OUTPUT\"} }")

  #######################
  # Load the error code #
  #######################
  ERROR_CODE=$?

  ##############################
  # Check the shell for errors #
  ##############################
  if [ $ERROR_CODE -ne 0 ]; then
    echo "ERROR! Failed to update GitHub Check!"
    echo "ERROR:[$UPDATE_CHECK_CMD]"
    exit 1
  else
    echo "Success! Updated Github Checks API"
  fi
}
################################################################################
################################# MAIN #########################################
################################################################################

#######################
# Debug print all env #
#######################
if [ $DEBUG -ne 0 ]; then
  echo "--------------------------------------------"
  echo "PRINTENV"
  printenv
  echo "--------------------------------------------"
fi

# Go into loop if no errors detected
if [ $ERROR_FOUND -eq 0 ]; then
  #######################
  # Get Github Env Vars #
  #######################
  # Need to pull in all the Github variables
  # needed to connect back and update checks
  GetGitHubVars
fi

# Go into loop if no errors detected
if [ $ERROR_FOUND -eq 0 ]; then
  #######################################
  # Validate We have configuration file #
  #######################################
  # Look for the users configuration file to
  # connect to AWS and start the Serverless app
  ValidateConfigurationFile
fi

# Go into loop if no errors detected
if [ $ERROR_FOUND -eq 0 ]; then
  ###################################
  # Create local configuration file #
  ###################################
  # Create the local configuration file used
  # to connect to AWS and deploy the Serverless app
  CreateLocalConfiguration
fi

# Go into loop if no errors detected
if [ $ERROR_FOUND -eq 0 ]; then
  ####################
  # Validate AWS CLI #
  ####################
  # Need to validate we have the aws cli installed
  # And avilable for usage
  ValidateAWSCLI
fi

########################################
# Validate the user source and runtime #
########################################
ValidateSourceAndRuntime

################
# Create Check #
################
# Create the check in GitHub to let the
# user know we are running the deploy action
# We always want to inform user of the process
# Note: No need to create check as were calling from inside a gitHub Action
#CreateCheck

# Go into loop if no errors detected
if [ $ERROR_FOUND -eq 0 ]; then
  ##############
  # Run Deploy #
  ##############
  # Run the actual deployment of the NodeJS
  # to AWS Serverless
  RunDeploy
fi

################
# Update Check #
################
# Update the check with the status
# of the deployment
# We always want to inform user of the process
# Note: No need to create check as were calling from inside a gitHub Action
#UpdateCheck

###############################
# Exit with proper error code #
###############################
if [ $ERROR_FOUND -eq 0 ]; then
  # Exit with SUCCESS
  exit 0
else
  # Exit with ERROR
  exit 1
fi
