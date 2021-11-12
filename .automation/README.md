# .automation

This folder holds automation scripts to help `deploy` and `cleanup` **DockerHub** images of the **Super-Linter**

## cleanup-docker.sh

This script uses **GitHub Actions** so that when a PR is merged and closed, the **GitHub Action** is triggered.
It will then search **DockerHub** for the image that was deployed during the development, and remove it.

## upload-docker.sh

This script uses **GitHub Actions** so that when a push to the repository is committed, it will complete the following:

- Checkout the source code
- Build the **Docker** container for **Super-Linter** using that source code
- Upload the container to **DockerHub**

When the script is triggered on the main branch, it will push with the tag:**latest** which is used by all scripting for general availability.
When the script is triggered in a branch, it will push with the tag:**NameOfBranch** which can be used for:

- _testing_
- _troubleshooting_
- _debugging_
- **Note:** The branch name will be reduced to alphanumeric for consistency and uploading

## test

This folder holds all **Test Cases** to help run the _CI/CT/CD_ process for the **Super-Linter**.
