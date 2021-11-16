# Contributing
Skip to content
Your account has been flagged.
Because of that, your profile is hidden from the public. If you believe this is a mistake, contact support to have your account status reviewed.
github
/
super-linter
Public
Code
Issues
41
Pull requests
1
Discussions
Actions
Projects
1
Wiki
Security
Insights
Upgrade SQLFluff to 0.8.1 and add new SQLFluff DBT Templator dependency
.github/workflows/stack-linter.yml #5435
Workflow file
.github/workflows/stack-linter.yml at 3cb88d5
---
############################
############################
## Preflight Stack Linter ##
############################
############################

#
# Documentation:
# https://help.github.com/en/articles/workflow-syntax-for-github-actions
#

#############################
# Start the job on all push #
#############################
on:
  push:
    branches: [main]
  pull_request:
    branches-ignore: []

###############
# Set the Job #
###############
jobs:
  build:
    # Name the Job
    name: Stack linter
    # Set the agent to run on
    runs-on: ubuntu-latest
    ##################
    # Load all steps #
    ##################
    steps:
      ##########################
      # Checkout the code base #
      ##########################
      - name: Checkout Code
        uses: actions/checkout@v2.4.0
        with:
          # Full git history is needed to get a proper list of changed files within `super-linter`
          fetch-depth: 0

      ################################
      # Run Linter against code base #
      ################################
      - name: Lint Code Base
        uses: docker://ghcr.io/github/super-linter:latest
        env:
          ACTIONS_RUNNER_DEBUG: true
          ERROR_ON_MISSING_EXEC_BIT: true
          VALIDATE_ALL_CODEBASE: false
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          DEFAULT_BRANCH: main

:wave: Hi there!
We're thrilled that you'd like to contribute to this project. Your help is essential for keeping it great.

## Submitting a pull request

[Pull Requests][pulls] are used for adding new playbooks, roles, and documents to the repository, or editing the existing ones.

**With write access**

1. Clone the repository (only if you have write access)
1. Create a new branch: `git checkout -b my-branch-name`
1. Make your change
1. Push and [submit a pull request][pr]
1. Pat yourself on the back and wait for your pull request to be reviewed and merged.

**Without write access**

1. [Fork][fork] and clone the repository
1. Create a new branch: `git checkout -b my-branch-name`
1. Make your change
1. Push to your fork and [submit a pull request][pr]
1. Pat your self on the back and wait for your pull request to be reviewed and merged.

Here are a few things you can do that will increase the likelihood of your pull request being accepted:

- Keep your change as focused as possible. If there are multiple changes you would like to make that are not dependent upon each other, consider submitting them as separate pull requests.
- Write [good commit messages](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Draft pull requests are also welcome to get feedback early on, or if there is something blocking you.

- Create a branch with a name that identifies the user and nature of the changes (similar to `user/branch-purpose`)
- Open a pull request

### CI/CT/CD

The **Super-Linter** has _CI/CT/CD_ configured utilizing **GitHub** Actions.

- When a branch is created and code is pushed, a **GitHub** Action is triggered for building the new **Docker** container with the new codebase
- The **Docker** container is then ran against the _test cases_ to validate all code sanity
  - `.automation/test` contains all test cases for each language that should be validated
- These **GitHub** Actions utilize the Checks API and Protected Branches to help follow the SDLC
- When the Pull Request is merged to main, the **Super-Linter** **Docker** container is then updated and deployed with the new codebase
  - **Note:** The branch's **Docker** container is also removed from **DockerHub** to cleanup after itself

## Releasing

If you are the current maintainer of this action you can create releases from the `Release` page  of the repository.

- It will notify the issue it has seen the information and starts the Actions job
- It will create a branch and update the `actions.yml` with the new version supplied to the issue
- It will then create a PR with the updated code
- It will then create the build the artifacts needed
- it will then publish the release and merge the PR
- A GitHub Action will Publish the Docker image to GitHub Package Registry once a Release is created
- A GitHub Action will Publish the Docker image to Docker Hub once a Release is created

## Resources

- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Using Pull Requests](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
- [GitHub Help](https://docs.github.com/en)

[pulls]: https://github.com/github/super-linter/pulls
[pr]: https://github.com/github/super-linter/compare
[fork]: https://github.com/github/super-linter/fork
