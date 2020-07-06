# Super-Linter
This repository is for the **GitHub Action** to run a **Super-Linter**.
It is a simple combination of various linters, written in `bash`, to help validate your source code.

The end goal of this tool:
- Prevent broken code from being uploaded to the default branch (Usually `master`)
- Help establish coding best practices across multiple languages
- Build guidelines for code layout and format
- Automate the process to help streamline code reviews

## Table of Contents

- [How it works](#how-it-works)
- [Supported linters](#supported-linters)
- [Usage](#how-to-use)
- [Environment variables](#environment-variables)
- [Disable rules](#disabling-rules)
- [Docker Hub](#docker-hub)
- [Run Super-Linter locally](#running-super-linter-locally-troubleshootingdebuggingenhancements)
  - [CI / CT/ CD](#cictcd)
- [Limitations](#limitations)
- [Contributing](#how-to-contribute)

## How it Works

The super-linter finds issues and reports them to the console output. Fixes are suggested in the console output but not automatically fixed, and a status check will show up as failed on the pull request.

The design of the **Super-Linter** is currently to allow linting to occur in **GitHub Actions** as a part of continuous integration occurring on pull requests as the commits get pushed. It works best when commits are being pushed early and often to a branch with an open or draft pull request. There is some desire to move this closer to local development for faster feedback on linting errors but this is not yet supported.

## Supported Linters

Developers on **GitHub** can call the **GitHub Action** to lint their code base with the following list of linters:

| *Language*       | *Linter*                                                                 |
| ---              | ---                                                                      |
| **Ansible**      | [ansible-lint](https://github.com/ansible/ansible-lint)                  |
| **Azure Resource Manager (ARM)** | [arm-ttk](https://github.com/azure/arm-ttk)                  |
| **AWS CloudFormation templates** | [cfn-lint](https://github.com/aws-cloudformation/cfn-python-lint/) |
| **CSS**          | [stylelint](https://stylelint.io/)                                       |
| **Clojure**      | [clj-kondo](https://github.com/borkdude/clj-kondo)                       |
| **CoffeeScript** | [coffeelint](https://coffeelint.github.io/)                              |
| **Dart**         | [dartanalyzer](https://dart.dev/tools/dartanalyzer)                      |
| **Dockerfile**   | [dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git)     |
| **EDITORCONFIG**          | [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker) |
| **ENV**          | [dotenv-linter](https://github.com/dotenv-linter/dotenv-linter)          |
| **Golang**       | [golangci-lint](https://github.com/golangci/golangci-lint)               |
| **HTMLHint**     | [HTMLHint](https://github.com/htmlhint/HTMLHint)                      |
| **JavaScript**   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)     |
| **JSON**         | [jsonlint](https://github.com/zaach/jsonlint)                            |
| **Kotlin**       | [ktlint](https://github.com/pinterest/ktlint)                            |
| **Markdown**     | [markdownlint](https://github.com/igorshubovych/markdownlint-cli#readme) |
| **OpenAPI**      | [spectral](https://github.com/stoplightio/spectral)                      |
| **Perl**         | [perl](https://pkgs.alpinelinux.org/package/edge/main/x86/perl)          |
| **PHP**          | [PHP](https://www.php.net/)                                              |
| **PowerShell**   | [PSScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer)       |
| **Protocol Buffers** | [protolint](https://github.com/yoheimuta/protolint)                  |
| **Python3**      | [pylint](https://www.pylint.org/)                                        |
| **Ruby**         | [RuboCop](https://github.com/rubocop-hq/rubocop)                         |
| **Shell**        | [Shellcheck](https://github.com/koalaman/shellcheck)                     |
| **Terraform**    | [tflint](https://github.com/terraform-linters/tflint)                    |
| **TypeScript**   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)     |
| **XML**          | [LibXML](http://xmlsoft.org/)                                            |
| **YAML**         | [YamlLint](https://github.com/adrienverge/yamllint)                      |

## How to use
More in-depth [tutorial](https://www.youtube.com/watch?v=EDAmFKO4Zt0&t=118s) available

To use this **GitHub** Action you will need to complete the following:
1. Create a new file in your repository called `.github/workflows/linter.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Enjoy your more *stable*, and *cleaner* code base
6. Check out the [Wiki](https://github.com/github/super-linter/wiki) for customization options

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
    branches-ignore: [master]
    # Remove the line above to run when pushing to master
  pull_request:
    branches: [master]

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
        uses: docker://github/super-linter:v3
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: master

...
```

**NOTE:**  
Using the line:`uses: docker://github/super-linter:v3` will pull the image down from **DockerHub** and run the **GitHub Super-Linter**.   Using the line: `uses: github/super-linter@v3` will build and compile the **GitHub Super-Linter** at build time. *This can be far more costly in time...*

## Environment variables
The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality.

*Note:* All the `VALIDATE_[LANGUAGE]` variables behave in a specific way.
If none of them are passed, then they all default to true.
However if any one of the variables are set, we default to leaving any unset variable to false.
This means that if you run the linter "out of the box", all languages will be checked.
But if you wish to select specific linters, we give you full control to choose which linters are run,
and won't run anything unexpected.

| **ENV VAR** | **Default Value** | **Notes** |
| --- | --- | --- |
| **VALIDATE_ALL_CODEBASE** | `true` | Will parse the entire repository and find all files to validate across all types. **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation. |
| **DEFAULT_BRANCH** | `master` | The name of the repository default branch. |
| **LINTER_RULES_PATH** | `.github/linters` | Directory for all linter configuration rules. |
| **VALIDATE_YAML** | `true` |Flag to enable or disable the linting process of the language. |
| **VALIDATE_JSON** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_XML** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_MD** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_BASH** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PERL** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PHP** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PYTHON** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_RUBY** | `true` | Flag to enable or disable the linting process of the language. |
| **RUBY_CONFIG_FILE** | `.ruby-lint.yml` | Filename for [rubocop configuration](https://docs.rubocop.org/rubocop/configuration.html) (ex: `.ruby-lint.yml`, `.rubocop.yml`)|
| **VALIDATE_COFFEE** | `true` | Flag to enable or disable the linting process of the language . |
| **VALIDATE_ANSIBLE** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_JAVASCRIPT_ES** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: eslint) |
| **JAVASCRIPT_ES_CONFIG_FILE** | `.eslintrc.yml` | Filename for [eslint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)|
| **VALIDATE_JAVASCRIPT_STANDARD** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: standard) |
| **VALIDATE_TYPESCRIPT_ES** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: eslint) |
| **TYPESCRIPT_ES_CONFIG_FILE** | `.eslintrc.yml` | Filename for [eslint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)|
| **VALIDATE_TYPESCRIPT_STANDARD** | `true` | Flag to enable or disable the linting process of the language. (Utilizing: standard) |
| **VALIDATE_DOCKER** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_GO** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_POWERSHELL** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_ARM** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_TERRAFORM** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_CSS** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_ENV** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_CLOJURE** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_HTML** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_KOTLIN** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_DART** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_OPENAPI** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_CLOUDFORMATION** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_PROTOBUF** | `true` | Flag to enable or disable the linting process of the language. |
| **VALIDATE_EDITORCONFIG** | `true` | Flag to enable or disable the linting process with the editorconfig. |
| **ANSIBLE_DIRECTORY** | `/ansible` | Flag to set the root directory for Ansible file location(s). |
| **ACTIONS_RUNNER_DEBUG** | `false` | Flag to enable additional information about the linter, versions, and additional output. |
| **DISABLE_ERRORS** | `false` | Flag to have the linter complete with exit code 0 even if errors were detected. |
| **DEFAULT_WORKSPACE** | `/tmp/lint` | The location containing files to lint if you are running locally. |

### Template rules files
You can use the **GitHub** **Super-Linter** *with* or *without* your own personal rules sets. This allows for greater flexibility for each individual code base. The Template rules all try to follow the standards we believe should be enabled at the basic level.
- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/` of your repository
  - If your repository does not have rules files, they will fall back to defaults in [this repository's `TEMPLATE` folder](https://github.com/github/super-linter/tree/master/TEMPLATES)

## Disabling rules
If you need to disable certain *rules* and *functionality*, you can view [Disable Rules](https://github.com/github/super-linter/blob/master/docs/disabling-linters.md)

## Docker Hub
The **Docker** container that is built from this repository is located at `https://hub.docker.com/r/github/super-linter`

## Running Super-Linter locally (troubleshooting/debugging/enhancements)
If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)

Check out the [note](#how-it-works) in **How it Works** to understand more about the **Super-Linter** linting locally versus via continuous integration.

### CI/CT/CD
The **Super-Linter** has *CI/CT/CD* configured utilizing **GitHub** Actions.
- When a branch is created and code is pushed, a **GitHub** Action is triggered for building the new **Docker** container with the new codebase
- The **Docker** container is then ran against the *test cases* to validate all code sanity
  - `.automation/test` contains all test cases for each language that should be validated
- These **GitHub** Actions utilize the Checks API and Protected Branches to help follow the SDLC
- When the Pull Request is merged to master, the **Super-Linter** **Docker** container is then updated and deployed with the new codebase
  - **Note:** The branch's **Docker** container is also removed from **DockerHub** to cleanup after itself

## Limitations
Below are a list of the known limitations for the **GitHub Super-Linter**:
- Due to being completely packaged at run time, you will not be able to update dependencies or change versions of the enclosed linters and binaries
- Additional details from `package.json` are not read by the **GitHub Super-Linter**
- Downloading additional codebases as dependencies from private repositories will fail due to lack of permissions

## How to contribute
If you would like to help contribute to this **GitHub** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/master/.github/CONTRIBUTING.md)

### Visual Studio Code
You can checkout this repository using [Container Remote Development](https://code.visualstudio.com/docs/remote/containers), and debug the linter using the `Test Linter` task.
![Example](https://user-images.githubusercontent.com/15258962/85165778-2d2ce700-b21b-11ea-803e-3f6709d8e609.gif)

We will also support [Github Codespaces](https://github.com/features/codespaces/) once it becomes available

--------------------------------------------------------------------------------

### License
- [MIT License](https://github.com/github/super-linter/blob/master/LICENSE)
