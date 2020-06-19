# Super-Linter
This repository is for the **GitHub Action** to run a **Super-Linter**.  
It is a simple combination of various linters, written in `bash`, to help validate your source code.

The end goal of this tool:
- Prevent broken code from being uploaded to *master* branches
- Help establish coding best practices across multiple languages
- Build guidelines for code layout and format
- Automate the process to help streamline code reviews

## How it Works

The super-linter finds issues and reports them to the console output. Fixes are suggested in the console output but not automatically fixed, and a status check will show up as failed on the pull request.

## Supported Linters

Developers on **GitHub** can call the **GitHub Action** to lint their code base with the following list of linters:

| *Language*       | *Linter*                                                                 |
| ---              | ---                                                                      |
| **Ansible**      | [ansible-lint](https://github.com/ansible/ansible-lint)                  |
| **CoffeeScript** | [coffeelint](http://www.coffeelint.org/)                                 |
| **Dockerfile**   | [dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git)     |
| **Golang**       | [golangci-lint](https://github.com/golangci/golangci-lint)               |
| **JavaScript**   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)     |
| **JSON**         | [jsonlint](https://github.com/zaach/jsonlint)                            |
| **Markdown**     | [markdownlint](https://github.com/igorshubovych/markdownlint-cli#readme) |
| **Perl**         | [perl](https://pkgs.alpinelinux.org/package/edge/main/x86/perl)          |
| **Python3**      | [pylint](https://www.pylint.org/)                                        |
| **Ruby**         | [Rubocop](https://github.com/rubocop-hq/rubocop)                         |
| **Shell**        | [Shellcheck](https://github.com/koalaman/shellcheck)                     |
| **Terraform**    | [tflint](https://github.com/terraform-linters/tflint)                    |
| **TypeScript**   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)     |
| **XML**          | [LibXML](http://xmlsoft.org/)                                            |
| **YAML**         | [YamlLint](https://github.com/adrienverge/yamllint)                      |

## How to use
To use this **GitHub** Action you will need to complete the following:
- Add the **GitHub** Action: **Super-Linter** to your current **GitHub** Actions workflow
- Enjoy your more *stable*, and *cleaner* code base
- Check out the [Wiki](https://github.com/github/super-linter/wiki) for customization options

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
        uses: actions/checkout@v2

      ################################
      # Run Linter against code base #
      ################################
      - name: Lint Code Base
        uses: github/super-linter@v2.0.0
        env:
          VALIDATE_ALL_CODEBASE: false
          VALIDATE_ANSIBLE: false
...
```

## Environment variables
The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality.

*Note:* All the `VALIDATE_[LANGAUGE]` variables behave in a specific way.  
If none of them are passed, then they all default to true.  
However if any one of the variables are set, we default to leaving any unset variable to false.  
This means that if you run the linter "out of the box", all langauges will be checked.
But if you wish to select specific linters, we give you full control to choose which linters are run,
and won't run anything unexpected.

| **ENV VAR** | **Default Value** | **Notes** |
| --- | --- | --- |
| **VALIDATE_ALL_CODEBASE** | `true` | Will parse the entire repository and find all files to validate across all types. **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation. |
| **VALIDATE_YAML** | `true` |Flag to enable or disable the linting process of the language. |
| **VALIDATE_JSON** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_XML** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_MD** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_BASH** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PERL** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PYTHON** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_RUBY** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_COFFEE** | `true` | Flag to enable or disable the linting process of the language . |
| **VALIDATE_ANSIBLE** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_JAVASCRIPT_ES** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: eslint) |
| **VALIDATE_JAVASCRIPT_STANDARD** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: standard) |
| **VALIDATE_TYPESCRIPT_ES** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: eslint) |
| **VALIDATE_TYPESCRIPT_STANDARD** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: standard) |
| **VALIDATE_DOCKER** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_GO** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_TERRAFORM** | `true` | Flag to enable or disable the linting process of the language. |
| **ANSIBLE_DIRECTORY** | `/ansible` | Flag to set the root directory for Ansible file location(s). |
| **ACTIONS_RUNNER_DEBUG** | `false` | Flag to enable additional information about the linter, versions, and additional output. |
| **DISABLE_ERRORS** | `false` | Flag to have the linter complete with exit code 0 even if errors were detected. |

### Template rules files
You can use the **GitHub** **Super-Linter** *with* or *without* your own personal rules sets. This allows for greater flexibility for each individual code base. The Template rules all try to follow the standards we believe should be enabled at the basic level.
- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/` of your repository
  - If your repository does not have rules files, they will fall back to defaults in this repositories `TEMPLATE` folder

## Disabling rules
If you need to disable certain *rules* and *functionality*, you can view [Disable Rules](https://github.com/github/super-linter/blob/master/docs/disabling-linters.md)

## Docker Hub
The **Docker** container that is built from this repository is located at `https://hub.docker.com/r/admiralawkbar/super-linter`

## Running Super-Linter locally (troubleshooting/debugging/enhancements)
If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)

### CI/CT/CD
The **Super-Linter** has *CI/CT/CD* configured utilizing **GitHub** Actions.
- When a branch is created and code is pushed, a **GitHub** Action is triggered for building the new **Docker** container with the new codebase
- The **Docker** container is then ran against the *test cases* to validate all code sanity
  - `.automation/test` contains all test cases for each language that should be validated
- These **GitHub** Actions utilize the Checks API and Protected Branches to help follow the SDLC
- When the Pull Request is merged to master, the **Super-Linter** **Docker** container is then updated and deployed with the new codebase
  - **Note:** The branches **Docker** container is also removed from **DockerHub** to cleanup after itself

## Limitations
Below are a list of the known limitations for the **GitHub Super-Linter**:
- Due to being completely packaged at run time, you will not be able to update dependencies or change versions of the enclosed linters and binaries
- Reading additional details from `package.json` are not read by the **GitHub Super-Linter**
- Downloading additional codebases as dependencies from private repositories will fail due to lack of permissions

## How to contribute
If you would like to help contribute to this **GitHub** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/master/.github/CONTRIBUTING.md)

--------------------------------------------------------------------------------

### License
- [MIT License](https://github.com/github/super-linter/blob/master/LICENSE)
