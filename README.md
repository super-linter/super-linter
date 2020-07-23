# Super-Linter

This repository is for the **GitHub Action** to run a **Super-Linter**.
It is a simple combination of various linters, written in `bash`, to help validate your source code.

The end goal of this tool:

- Prevent broken code from being uploaded to the default branch (Usually `master`)
- Help establish coding best practices across multiple languages
- Build guidelines for code layout and format
- Automate the process to help streamline code reviews

## Table of Contents

- [Super-Linter](#super-linter)
  - [Table of Contents](#table-of-contents)
  - [How it Works](#how-it-works)
  - [Supported Linters](#supported-linters)
  - [How to use](#how-to-use)
    - [Example connecting GitHub Action Workflow](#example-connecting-github-action-workflow)
  - [Environment variables](#environment-variables)
    - [Template rules files](#template-rules-files)
  - [Disabling rules](#disabling-rules)
  - [Docker Hub](#docker-hub)
  - [Run Super-Linter outside GitHub Actions](#run-super-linter-outside-github-actions)
    - [Local (troubleshooting/debugging/enhancements)](#local-troubleshootingdebuggingenhancements)
    - [Azure](#azure)
    - [GitLab](#gitlab)
    - [Visual Studio Code](#visual-studio-code)
  - [Limitations](#limitations)
  - [How to contribute](#how-to-contribute)
    - [License](#license)

## How it Works

The super-linter finds issues and reports them to the console output. Fixes are suggested in the console output but not automatically fixed, and a status check will show up as failed on the pull request.

The design of the **Super-Linter** is currently to allow linting to occur in **GitHub Actions** as a part of continuous integration occurring on pull requests as the commits get pushed. It works best when commits are being pushed early and often to a branch with an open or draft pull request. There is some desire to move this closer to local development for faster feedback on linting errors but this is not yet supported.

## Supported Linters

Developers on **GitHub** can call the **GitHub Action** to lint their code base with the following list of linters:

| _Language_                       | _Linter_                                                                             |
| -------------------------------- | ------------------------------------------------------------------------------------ |
| **Ansible**                      | [ansible-lint](https://github.com/ansible/ansible-lint)                              |
| **Azure Resource Manager (ARM)** | [arm-ttk](https://github.com/azure/arm-ttk)                                          |
| **AWS CloudFormation templates** | [cfn-lint](https://github.com/aws-cloudformation/cfn-python-lint/)                   |
| **CSS**                          | [stylelint](https://stylelint.io/)                                                   |
| **Clojure**                      | [clj-kondo](https://github.com/borkdude/clj-kondo)                                   |
| **CoffeeScript**                 | [coffeelint](https://coffeelint.github.io/)                                          |
| **Dart**                         | [dartanalyzer](https://dart.dev/guides/language/analysis-options)                    |
| **Dockerfile**                   | [dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git)                 |
| **EDITORCONFIG**                 | [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker) |
| **ENV**                          | [dotenv-linter](https://github.com/dotenv-linter/dotenv-linter)                      |
| **Golang**                       | [golangci-lint](https://github.com/golangci/golangci-lint)                           |
| **Groovy**                       | [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)                       |
| **HTMLHint**                     | [HTMLHint](https://github.com/htmlhint/HTMLHint)                                     |
| **JavaScript**                   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)                 |
| **JSON**                         | [jsonlint](https://github.com/zaach/jsonlint)                                        |
| **Kotlin**                       | [ktlint](https://github.com/pinterest/ktlint)                                        |
| **Lua**                          | [luacheck](https://github.com/luarocks/luacheck)                                     |
| **Markdown**                     | [markdownlint](https://github.com/igorshubovych/markdownlint-cli#readme)             |
| **OpenAPI**                      | [spectral](https://github.com/stoplightio/spectral)                                  |
| **Perl**                         | [perl](https://pkgs.alpinelinux.org/package/edge/main/x86/perl)                      |
| **PHP**                          | [PHP](https://www.php.net/)                                                          |
| **PowerShell**                   | [PSScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer)                   |
| **Protocol Buffers**             | [protolint](https://github.com/yoheimuta/protolint)                                  |
| **Python3**                      | [pylint](https://www.pylint.org/)   [flake8](https://flake8.pycqa.org/en/latest/)    |
| **Raku**                         | [raku](https://raku.org)                                                             |
| **Ruby**                         | [RuboCop](https://github.com/rubocop-hq/rubocop)                                     |
| **Shell**                        | [Shellcheck](https://github.com/koalaman/shellcheck)                                 |
| **Terraform**                    | [tflint](https://github.com/terraform-linters/tflint)    [terrascan](https://github.com/accurics/terrascan)                                |
| **TypeScript**                   | [eslint](https://eslint.org/) [standard js](https://standardjs.com/)                 |
| **XML**                          | [LibXML](http://xmlsoft.org/)                                                        |
| **YAML**                         | [YamlLint](https://github.com/adrienverge/yamllint)                                  |

## How to use

More in-depth [tutorial](https://www.youtube.com/watch?v=EDAmFKO4Zt0&t=118s) available

To use this **GitHub** Action you will need to complete the following:

1. Create a new file in your repository called `.github/workflows/linter.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Enjoy your more _stable_, and _cleaner_ code base
6. Check out the [Wiki](https://github.com/github/super-linter/wiki) for customization options

**NOTE:** You will need the _Environment_ variable `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` set in your workflow file to be able to use the multiple status API returns. There is no need to set the **GitHub** Secret, it only needs to be passed.

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
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**NOTE:**
Using the line:`uses: docker://github/super-linter:v3` will pull the image down from **DockerHub** and run the **GitHub Super-Linter**. Using the line: `uses: github/super-linter@v3` will build and compile the **GitHub Super-Linter** at build time. _This can be far more costly in time..._

## Environment variables

The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality.

_Note:_ All the `VALIDATE_[LANGUAGE]` variables behave in a specific way.
If none of them are passed, then they all default to true.
However if any one of the variables are set, we default to leaving any unset variable to false.
This means that if you run the linter "out of the box", all languages will be checked.
But if you wish to select specific linters, we give you full control to choose which linters are run,
and won't run anything unexpected.

| **ENV VAR**                      | **Default Value**     | **Notes**                                                                                                                                                                        |
| -------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ACTIONS_RUNNER_DEBUG**         | `false`               | Flag to enable additional information about the linter, versions, and additional output.                                                                                         |
| **ANSIBLE_DIRECTORY**            | `/ansible`            | Flag to set the root directory for Ansible file location(s).                                                                                                                     |
| **DEFAULT_BRANCH**               | `master`              | The name of the repository default branch.                                                                                                                                       |
| **DEFAULT_WORKSPACE**            | `/tmp/lint`           | The location containing files to lint if you are running locally.                                                                                                                |
| **DISABLE_ERRORS**               | `false`               | Flag to have the linter complete with exit code 0 even if errors were detected.                                                                                                  |
| **JAVASCRIPT_ES_CONFIG_FILE**    | `.eslintrc.yml`       | Filename for [eslint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)                           |
| **LINTER_RULES_PATH**            | `.github/linters`     | Directory for all linter configuration rules.                                                                                                                                    |
| **MULTI_STATUS**                 | `true`                | A status API is made for each language that is linted to make visual parsing easier.                                                                                             |
| **OUTPUT_FORMAT**                | `none`                | The report format to be generated, besides the stdout one. Output format of tap is currently using v13 of the specification. Supported formats: tap                              |
| **OUTPUT_FOLDER**                | `super-linter.report` | The location where the output reporting will be generated to. Output folder must not previously exist.                                                                           |
| **OUTPUT_DETAILS**               | `simpler`             | What level of details to be reported. Supported formats: simpler or detailed.                                                                                                    |
| **PYTHON_PYLINT_CONFIG_FILE**    | `.python-lint`        | Filename for [pylint configuration](http://pylint.pycqa.org/en/latest/user_guide/run.html?highlight=rcfile#command-line-options) (ex: `.python-lint`, `.pylintrc`)               |
| **PYTHON_FLAKE8_CONFIG_FILE**    | `.flake8`             | Filename for [flake8 configuration](https://flake8.pycqa.org/en/latest/user/configuration.html) (ex: `.flake8`, `tox.ini`)                                                       |
| **RUBY_CONFIG_FILE**             | `.ruby-lint.yml`      | Filename for [rubocop configuration](https://docs.rubocop.org/rubocop/configuration.html) (ex: `.ruby-lint.yml`, `.rubocop.yml`)                                                 |
| **TYPESCRIPT_ES_CONFIG_FILE**    | `.eslintrc.yml`       | Filename for [eslint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)                           |
| **VALIDATE_ALL_CODEBASE**        | `true`                | Will parse the entire repository and find all files to validate across all types. **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation. |
| **VALIDATE_ANSIBLE**             | `true`                | Flag to enable or disable the linting process of the Ansible language.                                                                                                           |
| **VALIDATE_ARM**                 | `true`                | Flag to enable or disable the linting process of the ARM language.                                                                                                               |
| **VALIDATE_BASH**                | `true`                | Flag to enable or disable the linting process of the Bash language.                                                                                                              |
| **VALIDATE_CLOJURE**             | `true`                | Flag to enable or disable the linting process of the Clojure language.                                                                                                           |
| **VALIDATE_CLOUDFORMATION**      | `true`                | Flag to enable or disable the linting process of the AWS Cloud Formation language.                                                                                               |
| **VALIDATE_COFFEE**              | `true`                | Flag to enable or disable the linting process of the Coffeescript language .                                                                                                     |
| **VALIDATE_CSS**                 | `true`                | Flag to enable or disable the linting process of the CSS language.                                                                                                               |
| **VALIDATE_DART**                | `true`                | Flag to enable or disable the linting process of the Dart language.                                                                                                              |
| **VALIDATE_DOCKER**              | `true`                | Flag to enable or disable the linting process of the Docker language.                                                                                                            |
| **VALIDATE_EDITORCONFIG**        | `true`                | Flag to enable or disable the linting process with the editorconfig.                                                                                                             |
| **VALIDATE_ENV**                 | `true`                | Flag to enable or disable the linting process of the ENV language.                                                                                                               |
| **VALIDATE_GO**                  | `true`                | Flag to enable or disable the linting process of the Golang language.                                                                                                            |
| **VALIDATE_GROOVY**              | `true`                | Flag to enable or disable the linting process of the language.                                                                                                                   |
| **VALIDATE_HTML**                | `true`                | Flag to enable or disable the linting process of the HTML language.                                                                                                              |
| **VALIDATE_JAVASCRIPT_ES**       | `true`                | Flag to enable or disable the linting process of the Javascript language. (Utilizing: eslint)                                                                                    |
| **VALIDATE_JAVASCRIPT_STANDARD** | `true`                | Flag to enable or disable the linting process of the Javascript language. (Utilizing: standard)                                                                                  |
| **VALIDATE_JSON**                | `true`                | Flag to enable or disable the linting process of the JSON language.                                                                                                              |
| **VALIDATE_JSX**                 | `true`                | Flag to enable or disable the linting process for jsx files (Utilizing: eslint)                                                                                                  |
| **VALIDATE_KOTLIN**              | `true`                | Flag to enable or disable the linting process of the Kotlin language.                                                                                                            |
| **VALIDATE_LUA**                 | `true`                | Flag to enable or disable the linting process of the language.                                                                                                                   |
| **VALIDATE_MD**                  | `true`                | Flag to enable or disable the linting process of the Markdown language.                                                                                                          |
| **VALIDATE_OPENAPI**             | `true`                | Flag to enable or disable the linting process of the OpenAPI language.                                                                                                           |
| **VALIDATE_PERL**                | `true`                | Flag to enable or disable the linting process of the Perl language.                                                                                                              |
| **VALIDATE_PHP**                 | `true`                | Flag to enable or disable the linting process of the PHP language.                                                                                                               |
| **VALIDATE_PROTOBUF**            | `true`                | Flag to enable or disable the linting process of the Protobuf language.                                                                                                          |
| **VALIDATE_PYTHON**              | `true`                | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint) (keep for backward compatibility)                                                      |
| **VALIDATE_PYTHON_PYLINT**       | `true`                | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint)                                                                                        |
| **VALIDATE_PYTHON_FLAKE8**       | `true`                | Flag to enable or disable the linting process of the Python language. (Utilizing: flake8)                                                                                        |
| **VALIDATE_POWERSHELL**          | `true`                | Flag to enable or disable the linting process of the Powershell language.                                                                                                        |
| **VALIDATE_RAKU**                | `true`                | Flag to enable or disable the linting process of the Raku language.                                                                                                              |
| **VALIDATE_RUBY**                | `true`                | Flag to enable or disable the linting process of the Ruby language.                                                                                                              |
| **VALIDATE_STATES**              | `true`                | Flag to enable or disable the linting process for AWS States Language.                                                                                                           |
| **VALIDATE_TERRAFORM**           | `true`                | Flag to enable or disable the linting process of the Terraform language.                                                                                                         |
| **VALIDATE_TERRAFORM_TERRASCAN** | `false`               | Flag to enable or disable the linting process of the Terraform language for security related issues.                                                                                                         |
| **VALIDATE_TSX**                 | `true`                | Flag to enable or disable the linting process for tsx files (Utilizing: eslint)                                                                                                  |
| **VALIDATE_TYPESCRIPT_ES**       | `true`                | Flag to enable or disable the linting process of the Typescript language. (Utilizing: eslint)                                                                                    |
| **VALIDATE_TYPESCRIPT_STANDARD** | `true`                | Flag to enable or disable the linting process of the Typescript language. (Utilizing: standard)                                                                                  |
| **VALIDATE_XML**                 | `true`                | Flag to enable or disable the linting process of the XML language.                                                                                                               |
| **VALIDATE_YAML**                | `true`                | Flag to enable or disable the linting process of the YAML language.                                                                                                              |
| **YAML_CONFIG_FILE**             | `.yaml-lint.yml`      | Filename for [Yamllint configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) (ex: `.yaml-lint.yml`, `.yamllint.yml`)                                      |


### Template rules files

You can use the **GitHub** **Super-Linter** _with_ or _without_ your own personal rules sets. This allows for greater flexibility for each individual code base. The Template rules all try to follow the standards we believe should be enabled at the basic level.

- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/` of your repository
  - If your repository does not have rules files, they will fall back to defaults in [this repository's `TEMPLATE` folder](https://github.com/github/super-linter/tree/master/TEMPLATES)

## Disabling rules

If you need to disable certain _rules_ and _functionality_, you can view [Disable Rules](https://github.com/github/super-linter/blob/master/docs/disabling-linters.md)

## Docker Hub

The **Docker** container that is built from this repository is located at [github/super-linter](https://hub.docker.com/r/github/super-linter)

## Run Super-Linter outside GitHub Actions

### Local (troubleshooting/debugging/enhancements)

If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)

Check out the [note](#how-it-works) in **How it Works** to understand more about the **Super-Linter** linting locally versus via continuous integration.

### Azure

Check out this [article](http://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/)

### GitLab

Check out this [snippet](https://gitlab.com/snippets/1988376)

### Visual Studio Code

You can checkout this repository using [Container Remote Development](https://code.visualstudio.com/docs/remote/containers), and debug the linter using the `Test Linter` task.
![Example](https://user-images.githubusercontent.com/15258962/85165778-2d2ce700-b21b-11ea-803e-3f6709d8e609.gif)

We will also support [Github Codespaces](https://github.com/features/codespaces/) once it becomes available

## Limitations

Below are a list of the known limitations for the **GitHub Super-Linter**:

- Due to being completely packaged at run time, you will not be able to update dependencies or change versions of the enclosed linters and binaries
- Additional details from `package.json` are not read by the **GitHub Super-Linter**
- Downloading additional codebases as dependencies from private repositories will fail due to lack of permissions

## How to contribute

If you would like to help contribute to this **GitHub** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/master/.github/CONTRIBUTING.md)

---

### License

- [MIT License](https://github.com/github/super-linter/blob/master/LICENSE)
