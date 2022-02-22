#!/usr/bin/env bash
################################################################################
########################### Install Python Dependancies ########################
################################################################################

#####################
# Set fail on error #
#####################
set -euo pipefail

############################
# Create staging directory #
############################
# shellcheck disable=SC2154
mkdir -p "${working_directory}/venvs"

########################################
# Install basic libs to run installers #
########################################
pip install virtualenv

#########################################################
# Itterate through requirments.txt to install bainaries #
#########################################################
cd dependencies/python
for DEP_FILE in *.txt; do
  # split the package name from its version
  PACKAGE_NAME=${DEP_FILE%.txt}
  echo "-------------------------------------------"
  mkdir -p "${working_directory}/venvs/${PACKAGE_NAME}"
  echo "Generating virtualenv for: [${PACKAGE_NAME}]"
  pushd "${working_directory}/venvs/${PACKAGE_NAME}"
  # Enable virtualenv
  virtualenv .
  # Activate virtualenv
  source bin/activate
  # Handle the ansibl-lint corner case
  if [[ "$PACKAGE_NAME" == "ansible-lint" ]]; then
    pip install "ansible-lint[core]"
  else
    pip install "${PACKAGE_NAME}"
  fi
  # Generate an update requirements.txt
  pip freeze > requirements.txt
  # deactivate the python virtualenv
  deactivate
  # pop the stack
  popd
  # Remove old lockfile
  rm -rf "$DEP_FILE"
  # Create new lockfile
  mv "${working_directory}/venvs/${PACKAGE_NAME}/requirements.txt" "${DEP_FILE}"
done

git status

# Setup Git Config
echo "Configuring Git..."
git config --global user.email "noreply@github.com"
git config --global user.name "Super-Linter Automation"

if [[ $(git status --porcelain) ]]; then
  # Push changes to remote
  echo "Pushing changes to remote..."
  git add .
  git commit -a -m "Update Python dependencies"
  # shellcheck disable=SC2154
  git checkout -b "python_deps_${id}"
  # shellcheck disable=SC2154
  git push origin "python_deps_${id}"

  # Open pull request
  echo "Opening pull request..."
  echo "${token}" | gh auth login --with-token
  gh pr create --title "Weekly Python Updates" --body "Updates Python dependencies" --base master --head "python_deps_${id}"
else
  echo "No changes to commit"
fi
