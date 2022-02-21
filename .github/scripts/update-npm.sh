#!/usr/bin/env bash
# Enable strict error checking
set -euo pipefail

# Install ncu
npm i -g npm-check-updates
pushd dependencies

# Update all dependencies
ncu -u
npm install

# Push changes to remote
git add .
git commit -a -Ss -m "Update NPM dependencies"
git checkout -b "npm_deps_${id}"
git push origin "npm_deps_${id}"

# Open pull request
gh pr create --title "Weekly NPM Updates" --body "Updates NPM dependencies" --base master --head "npm_deps_${id}"
