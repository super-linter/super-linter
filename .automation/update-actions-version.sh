#!/bin/bash

################################################################################
############# Update the actions.yml with version @admiralawkbar ###############
################################################################################

############
# Defaults #
############\
GITHUB_API='https://api.github.com' # API url
VERSION=''                          # Version of release pulled from api
ACTION_FILE='action.yml'            # Action file to update
PR_ID=''                            # PUll Request ID when created
UPDATED_BODY_STRING=''              # Issue body string converted
COMMIT_SHA=''                       # COmmit sha when PR is created

##############
# Built Vars #
##############
ORG=$(echo "${ORG_REPO}" | cut -d'/' -f1)  # Name of the Org
REPO=$(echo "${ORG_REPO}" | cut -d'/' -f2) # Name of the repository

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
#### Function GetReleaseFromIssueTitle #########################################
GetReleaseFromIssueTitle() {
  echo "-------------------------------------------------------"
  echo "Getting the latest Release version from GitHub Issue..."

  # Get the latest release on the Repository
  GET_VERSION_CMD=$(echo "${ISSUE_TITLE}" | grep -E -o "v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+" 2>&1)

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
#### Function UpdateBaseIssue ##################################################
UpdateBaseIssue() {
  echo "-------------------------------------------------------"
  echo "Updating Original Issue:[$ISSUE_NUMBER] with Release information..."

  # Update the issue to point to new created Pull Request
  UPDATE_ISSUE_CMD=$(curl -s --fail -X POST \
    --url "${GITHUB_API}/repos/${ORG}/${REPO}/issues/${ISSUE_NUMBER}/comments" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H 'Content-Type: application/json' \
    --data "{ \"body\": \"This Issue is being resolved on in the Pull Request #${PR_ID}\"}" 2>&1)

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to update base issue!"
    echo "ERROR:[$UPDATE_ISSUE_CMD]"
    exit 1
  else
    echo "Successfully updated base Issue"
  fi
}
################################################################################
#### Function UpdatePRBody #####################################################
UpdatePRBody() {
  echo "-------------------------------------------------------"
  echo "Updating PR body with Release information and Issue linkage..."

  # Need to update the body of the PR with the information
  UPDATE_PR_CMD=$(
    curl -s --fail -X PATCH \
      --url "${GITHUB_API}/repos/${ORG}/${REPO}/pulls/${PR_ID}" \
      -H 'Accept: application/vnd.github.shadow-cat-preview+json,application/vnd.github.sailor-v-preview+json' \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H 'Content-Type: application/json' \
      --data "{\"body\": \"Automation Creation of Super-Linter\n\nThis closes #${ISSUE_NUMBER}\n\n${UPDATED_BODY_STRING}\"}" 2>&1
  )

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to update PR body!"
    echo "ERROR:[$UPDATE_PR_CMD]"
    exit 1
  else
    echo "Successfully updated PR body"
  fi

  # Add the label for the release
  UPDATE_LABEL_CMD=$(
    curl -s --fail -X POST \
      --url "${GITHUB_API}/repos/${ORG}/${REPO}/issues/${PR_ID}/labels" \
      -H 'Accept: application/vnd.github.v3+json' \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H 'Content-Type: application/json' \
      --data '{"labels":["Release"]}' 2>&1
  )

  # Load the error code
  ERROR_CODE=$?

  # Check the shell for errors
  if [ "${ERROR_CODE}" -ne 0 ]; then
    # ERROR
    echo "ERROR! Failed to update PR label!"
    echo "ERROR:[$UPDATE_LABEL_CMD]"
    exit 1
  else
    echo "Successfully updated PR label"
  fi
}
################################################################################
#### Function UpdateReleaseBodyString ##########################################
UpdateReleaseBodyString() {
  # Need to convert the string newlines to literal newlines
  UPDATED_BODY_STRING=$(echo "${ISSUE_BODY}" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g')

  echo "-------------------------------------------------------"
  echo "The updated body string is:[${UPDATED_BODY_STRING}]"
  echo "-------------------------------------------------------"
}
################################################################################
#### Function SetActionsVariables ##############################################
SetActionsVariables() {
  # Set the variables back to Actions
  echo "-------------------------------------------------------"
  echo "Setting the variables back to GitHub Actions..."

  echo "Setting PR_ID:[${PR_ID}]"
  echo "PR_ID=${PR_ID}" >>"${GITHUB_ENV}"

  echo "Setting RELEASE_VERSION:[${VERSION}]"
  echo "RELEASE_VERSION=${VERSION}" >>"${GITHUB_ENV}"

  echo "Setting PR_REF:[Automation-Release-${VERSION}]"
  echo "PR_REF=Automation-Release-${VERSION}" >>"${GITHUB_ENV}"

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
GetReleaseFromIssueTitle

##########################
# Get the latest version #
##########################
UpdateReleaseBodyString

##########################
# Update the action file #
##########################
UpdateActionFile

########################
# Commit and push file #
########################
CommitAndPush

####################
# Update the Issue #
####################
UpdateBaseIssue

####################
# Update the Issue #
####################
UpdatePRBody

#####################################
# Set the variables back to Actions #
#####################################
SetActionsVariables

##########
# Footer #
##########
Footer
