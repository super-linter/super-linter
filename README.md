# Super-Linter
This repository is for the **GitHub Action** to run a **Super-Linter**.  
Developers on **GitHub** can call this Action to lint their code base with the following list of linters:

- **Ruby** (Rubocop)
- **Shell** (Shellcheck)
- **Ansible** (Ansible-lint)
- **YAML** (Yamllint)
- **Python3** (Pylint)
- **JSON** (JsonLint)
- **MarkDown** (Markdownlint)
- **Perl** (Perl)
- **XML** (LibXML)
- **Coffeescript** (coffeelint)
- **Javascript** (eslint)(standard)
- **Typescript** (eslint)(standard)
- **Golang** (golangci-lint)
- **Dockerfile** (dockerfilelint)
- **Terraform** (tflint)

## How to use
To use this **GitHub** Action you will need to complete the following:
- Add the **GitHub** Action: **Super-Linter** to your current **GitHub** Actions workflow
- Enjoy your more *stable*, and *cleaner* code base

### Example connecting GitHub Action Workflow
In your repository you should have a `.github/workflows` folder with **GitHub** Action similar to below:

- `.github/workflows/linter.yml`

This file should have the following code:

```yml
---
###########################
###########################
## Linter GitHub Actions ##
###########################
###########################
name: Lint Code Base

#
# Documentation:
# https://help.github.com/en/articles/workflow-syntax-for-github-actions
#

#############################
# Start the job on all push #
#############################
on:
  push:
    branches-ignore:
      - 'master'

###############
# Set the Job #
###############
jobs:
  build:
    # Name the Job
    name: Lint Code Base
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
        uses: actions/checkout@master

      ################################
      # Run Linter against code base #
      ################################
      - name: Lint Code Base
        uses: docker://admiralawkbar/super-linter:latest
        env:
          VALIDATE_ALL_CODEBASE: false
          VALIDATE_ANSIBLE: false
...
```

## Env Vars
The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality:
- **VALIDATE_ALL_CODEBASE**
  - Default: `true`
  - Will parse the entire repository and find all files to validate across all types
  - **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation
- **VALIDATE_YAML**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_JSON**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_XML**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_MD**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_BASH**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_PERL**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_PYTHON**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_RUBY**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_COFFEE**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_ANSIBLE**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_JAVASCRIPT_ES**
  - Default: `true`
  - Flag to enable or disable the linting process of the language (Utilizing: eslint)
- **VALIDATE_JAVASCRIPT_STANDARD**
  - Default: `true`
  - Flag to enable or disable the linting process of the language (Utilizing: standard)
- **VALIDATE_TYPESCRIPT_ES**
  - Default: `true`
  - Flag to enable or disable the linting process of the language (Utilizing: eslint)
- **VALIDATE_TYPESCRIPT_STANDARD**
  - Default: `true`
  - Flag to enable or disable the linting process of the language (Utilizing: standard)
- **ANSIBLE_DIRECTORY**
  - Default: `/ansible`
  - Flag to set the root directory for Ansible file location(s)
- **VALIDATE_DOCKER**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_GO**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VALIDATE_TERRAFORM**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
- **VERBOSE_OUTPUT**
  - Default: `false`
  - Flag to enable additional information about the linter, versions, and additional output

### Template rules files
You can use the **GitHub** **Super-Linter** *with* or *without* your own personal rules sets. This allows for greater flexibility for each individual code base. The Template rules all try to follow the standards we believe should be enabled at the basic level.
- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/` of your repository
  - If your repository does not have rules files, they will fall back to defaults in this repositories `TEMPLATE` folder

## Docker Hub
The **Docker** container that is built from this repository is located at `https://cloud.docker.com/u/admiralawkbar/repository/docker/admiralawkbar/super-linter`

## Running Super-Linter locally (troubleshooting/debugging/enhancements)
If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/master/.github/run-linter-locally.md)

### CI/CT/CD
The **Super-Linter** has *CI/CT/CD* configured utilizing **GitHub** Actions.
- When a branch is created and code is pushed, a **GitHub** Action is triggered for building the new **Docker** container with the new codebase
- The **Docker** container is then ran against the *test cases* to validate all code sanity
  - `.automation/test` contains all test cases for each language that should be validated
- These **GitHub** Actions utilize the Checks API and Protected Branches to help follow the SDLC
- When the Pull Request is merged to master, the **Super-Linter** **Docker** container is then updated and deployed with the new codebase
  - **Note:** The branches **Docker** container is also removed from **DockerHub** to cleanup after itself

## How to contribute
If you would like to help contribute to this **GitHub** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/master/.github/CONTRIBUTING.md)

--------------------------------------------------------------------------------

### License
- [License](https://github.com/github/super-linter/blob/master/LICENSE)
