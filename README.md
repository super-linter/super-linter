# Super-Linter

This repository is for the **GitHub** Action to run a **Super-Linter**.  
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

## How to use

To use this **GitHub** Action you will need to complete the following:
- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/`
  - If your repository does not have rules files, they will fall back to defaults in this repositories `TEMPLATE` folder
- Add the **Github** Action: **Super-Linter** to your current **Github** Actions workflow
- Enjoy your more stable, and cleaner code base

### Example connecting GitHub Action Workflow

In your repository you should have a `workflows` folder with **GitHub** Action similar to below:

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
on: ['push']

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
- **VALIDATE_JAVASCRIPT**
  - Default: `true`
  - Flag to enable or disable the linting process of the language
  
## Docker Hub

The **Docker** container that is built from this repository is located at `https://cloud.docker.com/u/admiralawkbar/repository/docker/admiralawkbar/super-linter`

## How to contribute

If you would like to help contribute to this **Github** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/master/.github/CONTRIBUTING.md)

--------------------------------------------------------------------------------

### License

- [License](https://github.com/github/super-linter/blob/master/LICENSE)
