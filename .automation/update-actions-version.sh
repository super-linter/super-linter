#!/bin/bash

################################################################################
############# Update the actions.yml with version @admiralawkbar ###############
################################################################################

############
# Defaults #
############\
ACTION_FILE='action.yml' # Action file to update
COMMIT_SHA=''            # Commit sha when PR is created
PR_ID=''                 # Pull Request NUmber when generated
VERSION=''               # Version of release pulled from api

################################################################################
############################ FUNCTIONS BELOW ###################################
################################################################################
################################################################################
#### Function Header ###########################################################
Header() {
  echo "-------------------------------------------------------"
  echo "----------- GitHub Update Release Version -------------"
  echo "-------------------------------------------------------"
}
################################################################################
#### Function GetReleaseVersion #########################################
GetReleaseVersion() {
  echo "-------------------------------------------------------"
  echo "Getting the latest Release version from GitHub ..."

  # Get the latest release on the Repository
  GET_VERSION_CMD="$(echo "${RELEASE_NAME}" | grep -E -o "v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+" 2>&1)"

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ] || [ ${#GET_VERSION_CMD} -lt 1 ]; then
    # Error
    echo "ERROR! Failed to get the version!"
    echo "ERROR:[${GET_VERSION_CMD}]"
    exit 1
  else
    # Success
    echo "Latest Version:[${GET_VERSION_CMD}]"
  fi

  # Set the version
  VERSION=${GET_VERSION_CMD}
}
################################################################################
#### Function UpdateActionFile #################################################
UpdateActionFile() {
  echo "-------------------------------------------------------"
  echo "Updating the File:[$ACTION_FILE] with Version:[$VERSION]..."

  # Validate we can see the file
  if [ ! -f "${ACTION_FILE}" ]; then
    # ERROR
    echo "ERROR! Failed to find the file:[${ACTION_FILE}]"
    exit 1
  fi

  # Update the file
  UPDATE_CMD=$(sed -i "s|image:.*|image: 'docker://ghcr.io/github/super-linter:${VERSION}'|" "${ACTION_FILE}" 2>&1)

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # Failed to update file
    echo "ERROR! Failed to update ${ACTION_FILE}!"
    echo "ERROR:[${UPDATE_CMD}]"
    exit 1
  else
    echo "Successfully updated file to:"
    cat "${ACTION_FILE}"
  fi
}
################################################################################
#### Function CommitAndPush ####################################################
CommitAndPush() {
  echo "-------------------------------------------------------"
  echo "Creating commit, and pushing to PR..."

  # Commit the code to GitHub
  COMMIT_CMD=$(
    git checkout -b "Automation-Release-${VERSION}"
    git add "${ACTION_FILE}"
    git config --global user.name "SuperLinter Automation"
    git config --global user.email "super_linter_automation@github.com"
    git commit -m "Updating action.yml with new release version" 2>&1
  )

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to make commit!"
    echo "ERROR:[$COMMIT_CMD]"
    exit 1
  else
    echo "Successfully staged commmit"
  fi

  echo "-------------------------------------------------------"
  # Push the code to the branch and create PR
  PUSH_CMD=$(
    git push --set-upstream origin "Automation-Release-${VERSION}"
    gh pr create --title "Release-update-to-${VERSION}" --body "Automation Upgrade version ${VERSION} to action.yml" 2>&1
  )

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to create PR!"
    echo "ERROR:[$PUSH_CMD]"
    exit 1
  else
    echo "Successfully Created PR"
  fi

  # Get the pr number
  for LINE in $PUSH_CMD; do
    # echo "Line:[${LINE}]"
    if [[ "${LINE}" == *"github.com"* ]]; then
      # Getting the PR id
      PR_ID=$(echo "${LINE}" | rev | cut -d'/' -f1 | rev)
    fi
  done

  # get the current commit sha
  COMMIT_SHA=$(git rev-parse HEAD 2>&1)

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to get comit sha!"
    echo "ERROR:[$COMMIT_SHA]"
    exit 1
  else
    echo "Successfully grabbed commit sha"
  fi

}

################################################################################
#### Function SetActionsVariables ##############################################
SetActionsVariables() {
  # Set the variables back to Actions
  echo "-------------------------------------------------------"
  echo "Setting the variables back to GitHub Actions..."

  echo "Setting RELEASE_VERSION:[${VERSION}]"
  echo "RELEASE_VERSION=${VERSION}" >>"${GITHUB_ENV}"

  echo "Setting PR_ID:[${PR_ID}]"
  echo "PR_ID=${PR_ID}" >>"${GITHUB_ENV}"

  echo "Setting COMMIT_SHA:[${COMMIT_SHA}]"
  echo "COMMIT_SHA=${COMMIT_SHA}" >>"${GITHUB_ENV}"
}
################################################################################
#### Function Footer ###########################################################
Footer() {
  echo "-------------------------------------------------------"
  echo "The step has completed"
  echo "-------------------------------------------------------"
}
################################################################################
################################## MAIN ########################################
################################################################################

##########
# Header #
##########
Header

##########################
# Get the latest version #
##########################
GetReleaseVersion

##########################
# Update the action file #
##########################
UpdateActionFile

########################
# Commit and push file #
########################
CommitAndPush

#####################################
# Set the variables back to Actions #
#####################################
SetActionsVariables

##########
# Footer #
##########
Footer
