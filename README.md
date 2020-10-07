# Super-Linter

This repository is for the **GitHub Action** to run a **Super-Linter**.
It is a simple combination of various linters, written in `bash`, to help validate your source code.

**The end goal of this tool:**

- Prevent broken code from being uploaded to the default branch (_Usually_ `master`)
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
    - [Add Super-Linter badge in your repository README](#add-super-linter-badge-in-your-repository-readme)
  - [Environment variables](#environment-variables)
    - [Template rules files](#template-rules-files)
  - [Disabling rules](#disabling-rules)
  - [Filter linted files](#filter-linted-files)
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

<!-- linters-table-start -->
### Languages

| Language / Format | Linter | Configuration key |
| ----------------- | -------------- | ------------ |
| **BASH** | [bash-exec](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_bash_exec.md)| [BASH_EXEC](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_bash_exec.md) |
|  | [shellcheck](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_shellcheck.md)| [BASH_SHELLCHECK](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_shellcheck.md) |
|  | [shfmt](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_shfmt.md)| [BASH_SHFMT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/bash_shfmt.md) |
| **CLOJURE** | [clj-kondo](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/clojure_clj_kondo.md)| [CLOJURE](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/clojure_clj_kondo.md) |
| **COFFEE** | [coffeelint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/coffee_coffeelint.md)| [COFFEE](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/coffee_coffeelint.md) |
| **DART** | [dartanalyzer](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dart_dartanalyzer.md)| [DART](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dart_dartanalyzer.md) |
| **GO** | [golangci-lint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/go_golangci_lint.md)| [GO](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/go_golangci_lint.md) |
| **GROOVY** | [npm-groovy-lint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/groovy_npm_groovy_lint.md)| [GROOVY](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/groovy_npm_groovy_lint.md) |
| **JAVA** | [checkstyle](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/java_checkstyle.md)| [JAVA](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/java_checkstyle.md) |
| **JAVASCRIPT** | [eslint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/javascript_eslint.md)| [JAVASCRIPT_ES](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/javascript_eslint.md) |
|  | [standard](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/javascript_standard.md)| [JAVASCRIPT_STANDARD](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/javascript_standard.md) |
| **JSX** | [eslint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/jsx_eslint.md)| [JSX](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/jsx_eslint.md) |
| **KOTLIN** | [ktlint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/kotlin_ktlint.md)| [KOTLIN](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/kotlin_ktlint.md) |
| **LUA** | [luacheck](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/lua_luacheck.md)| [LUA](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/lua_luacheck.md) |
| **PERL** | [perlcritic](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/perl_perlcritic.md)| [PERL](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/perl_perlcritic.md) |
| **PHP** | [php](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_php.md)| [PHP_BUILTIN](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_php.md) |
|  | [phpcs](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_phpcs.md)| [PHP_PHPCS](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_phpcs.md) |
|  | [phpstan](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_phpstan.md)| [PHP_PHPSTAN](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_phpstan.md) |
|  | [psalm](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_psalm.md)| [PHP_PSALM](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/php_psalm.md) |
| **POWERSHELL** | [powershell](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/powershell_powershell.md)| [POWERSHELL](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/powershell_powershell.md) |
| **PYTHON** | [pylint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_pylint.md)| [PYTHON_PYLINT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_pylint.md) |
|  | [black](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_black.md)| [PYTHON_BLACK](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_black.md) |
|  | [flake8](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_flake8.md)| [PYTHON_FLAKE8](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/python_flake8.md) |
| **R** | [lintr](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/r_lintr.md)| [R](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/r_lintr.md) |
| **RAKU** | [raku](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/raku_raku.md)| [RAKU](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/raku_raku.md) |
| **RUBY** | [rubocop](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/ruby_rubocop.md)| [RUBY](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/ruby_rubocop.md) |
| **SCALA** | [scalafix](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/scala_scalafix.md)| [SCALA](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/scala_scalafix.md) |
| **SQL** | [sql-lint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/sql_sql_lint.md)| [SQL](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/sql_sql_lint.md) |
| **TSX** | [eslint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/tsx_eslint.md)| [TSX](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/tsx_eslint.md) |
| **TYPESCRIPT** | [eslint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/typescript_eslint.md)| [TYPESCRIPT_ES](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/typescript_eslint.md) |
|  | [standard](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/typescript_standard.md)| [TYPESCRIPT_STANDARD](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/typescript_standard.md) |

### Formats

| Language / Format | Linter | Configuration key |
| ----------------- | -------------- | ------------ |
| **CSS** | [stylelint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/css_stylelint.md)| [CSS](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/css_stylelint.md) |
| **ENV** | [dotenv-linter](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/env_dotenv_linter.md)| [ENV](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/env_dotenv_linter.md) |
| **HTML** | [htmlhint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/html_htmlhint.md)| [HTML](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/html_htmlhint.md) |
| **JSON** | [jsonlint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/json_jsonlint.md)| [JSON](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/json_jsonlint.md) |
| **LATEX** | [chktex](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/latex_chktex.md)| [LATEX](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/latex_chktex.md) |
| **MARKDOWN** | [markdownlint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/markdown_markdownlint.md)| [MARKDOWN](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/markdown_markdownlint.md) |
| **PROTOBUF** | [protolint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/protobuf_protolint.md)| [PROTOBUF](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/protobuf_protolint.md) |
| **XML** | [xmllint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/xml_xmllint.md)| [XML](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/xml_xmllint.md) |
| **YAML** | [yamllint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/yaml_yamllint.md)| [YAML](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/yaml_yamllint.md) |

### Tooling formats

| Language / Format | Linter | Configuration key |
| ----------------- | -------------- | ------------ |
| **ANSIBLE** | [ansible-lint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/ansible_ansible_lint.md)| [ANSIBLE](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/ansible_ansible_lint.md) |
| **CLOUDFORMATION** | [cfn-lint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/cloudformation_cfn_lint.md)| [CLOUDFORMATION](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/cloudformation_cfn_lint.md) |
| **DOCKERFILE** | [dockerfilelint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dockerfile_dockerfilelint.md)| [DOCKERFILE_DOCKERFILELINT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dockerfile_dockerfilelint.md) |
|  | [hadolint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dockerfile_hadolint.md)| [DOCKERFILE_HADOLINT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/dockerfile_hadolint.md) |
| **EDITORCONFIG** | [editorconfig-checker](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/editorconfig_editorconfig_checker.md)| [EDITORCONFIG](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/editorconfig_editorconfig_checker.md) |
| **KUBERNETES** | [kubeval](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/kubernetes_kubeval.md)| [KUBERNETES_KUBEVAL](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/kubernetes_kubeval.md) |
| **OPENAPI** | [spectral](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/openapi_spectral.md)| [OPENAPI](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/openapi_spectral.md) |
| **SNAKEMAKE** | [snakemake](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/snakemake_snakemake.md)| [SNAKEMAKE_LINT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/snakemake_snakemake.md) |
|  | [snakefmt](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/snakemake_snakefmt.md)| [SNAKEMAKE_SNAKEFMT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/snakemake_snakefmt.md) |
| **TERRAFORM** | [tflint](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/terraform_tflint.md)| [TERRAFORM_TFLINT](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/terraform_tflint.md) |
|  | [terrascan](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/terraform_terrascan.md)| [TERRAFORM_TERRASCAN](https://github.com/nvuillam/super-linter/tree/POC_RefactorInPython/docs/descriptors/terraform_terrascan.md) |


<!-- linters-table-end -->

## How to use

More in-depth [tutorial](https://www.youtube.com/watch?v=EDAmFKO4Zt0&t=118s) available

To use this **GitHub** Action you will need to complete the following:

1. Create a new file in your repository called `.github/workflows/linter.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Enjoy your more _stable_, and _cleaner_ code base
6. Check out the [Wiki](https://github.com/github/super-linter/wiki) for customization options

**NOTE:** If you pass the _Environment_ variable `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` in your workflow, then the **GitHub Super-Linter** will mark the status of each individual linter run in the Checks section of a pull request. Without this you will only see the overall status of the full run. There is no need to set the **GitHub** Secret as it is automatically set by GitHub, it only needs to be passed to the action.

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
        uses: github/super-linter@v3
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: master
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Add Super-Linter badge in your repository README

You can show Super-Linter status with a badge in your repository README

[![GitHub Super-Linter](https://github.com/nvuillam/npm-groovy-lint/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

Format:

```markdown
[![GitHub Super-Linter](https://github.com/<OWNER>/<REPOSITORY>/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
```

Example:

```markdown
[![GitHub Super-Linter](https://github.com/nvuillam/npm-groovy-lint/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)
```

_Note:_ IF you did not use `Lint Code Base` as GitHub Action name, please read [GitHub Actions Badges documentation](https://docs.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow#adding-a-workflow-status-badge-to-your-repository)

## Environment variables

The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality.

_Note:_ All the `VALIDATE_[LANGUAGE]` variables behave in a very specific way:

- If none of them are passed, then they all default to true.
- If any one of the variables are set to true, we default to leaving any unset variable to false (only validate those languages).
- If any one of the variables are set to false, we default to leaving any unset variable to true (only exclude those languages).
- If there are `VALIDATE_[LANGUAGE]` variables set to both true and false. It will fail.

This means that if you run the linter "out of the box", all languages will be checked.
But if you wish to select or exclude specific linters, we give you full control to choose which linters are run, and won't run anything unexpected.

| **ENV VAR**                       | **Default Value**     | **Notes**                                                                                                                                                                        |
| --------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ACTIONS_RUNNER_DEBUG**          | `false`               | Flag to enable additional information about the linter, versions, and additional output.                                                                                         |
| **DEFAULT_BRANCH**                | `master`              | The name of the repository default branch.                                                                                                                                       |
| **DEFAULT_WORKSPACE**             | `/tmp/lint`           | The location containing files to lint if you are running locally.                                                                                                                |
| **DISABLE_ERRORS**                | `false`               | Flag to have the linter complete with exit code 0 even if errors were detected.                                                                                                  |
| **ERROR_ON_MISSING_EXEC_BIT**     | `false`               | If set to `false`, the `bash-exec` linter will report a warning if a shell script is not executable. If set to `true`, the `bash-exec` linter will report an arror instead.      |
| **FILTER_REGEX_EXCLUDE**          | `none`                | Regular expression defining which files will be excluded from linting  (ex: `.*src/test.*`)                                                                                      |
| **FILTER_REGEX_INCLUDE**          | `all`                 | Regular expression defining which files will be processed by linters (ex: `.*src/.*`)                                                                                            |
| **LINTER_RULES_PATH**             | `.github/linters`     | Directory for all linter configuration rules.                                                                                                                                    |
| **LOG_FILE**                      | `super-linter.log`    | The file name for outputting logs. All output is sent to the log file regardless of `LOG_LEVEL`.                                                                                 |
| **LOG_LEVEL**                     | `VERBOSE`             | How much output the script will generate to the console. One of `VERBOSE`, `DEBUG` or `TRACE`.                                                                                   |
| **MULTI_STATUS**                  | `true`                | A status API is made for each language that is linted to make visual parsing easier.                                                                                             |
| **OUTPUT_FORMAT**                 | `none`                | The report format to be generated, besides the stdout one. Output format of tap is currently using v13 of the specification. Supported formats: tap                              |
| **OUTPUT_FOLDER**                 | `super-linter.report` | The location where the output reporting will be generated to. Output folder must not previously exist.                                                                           |
| **OUTPUT_DETAILS**                | `simpler`             | What level of details to be reported. Supported formats: simpler or detailed.                                                                                                    |
| **VALIDATE_ALL_CODEBASE**         | `true`                | Will parse the entire repository and find all files to validate across all types. **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation. |

### Template rules files

You can use the **GitHub** **Super-Linter** _with_ or _without_ your own personal rules sets. This allows for greater flexibility for each individual code base. The Template rules all try to follow the standards we believe should be enabled at the basic level.

- Copy **any** or **all** template rules files from `TEMPLATES/` into your repository in the location: `.github/linters/` of your repository
  - If your repository does not have rules files, they will fall back to defaults in [this repository's `TEMPLATE` folder](https://github.com/github/super-linter/tree/master/TEMPLATES)

## Disabling rules

If you need to disable certain _rules_ and _functionality_, you can view [Disable Rules](https://github.com/github/super-linter/blob/master/docs/disabling-linters.md)

## Filter linted files

If you need to lint only a folder or exclude some files from linting, you can use optional environment parameters `FILTER_REGEX_INCLUDE` and `FILTER_REGEX_EXCLUDE`

Examples:

- Lint only src folder: `FILTER_REGEX_INCLUDE: .*src/.*`
- Do not lint files inside test folder: `FILTER_REGEX_EXCLUDE: .*test/.*`
- Do not lint javascript files inside test folder: `FILTER_REGEX_EXCLUDE: .*test/.*.js`

## Docker Hub

The **Docker** container that is built from this repository is located at [github/super-linter](https://hub.docker.com/r/github/super-linter)

## Run Super-Linter outside GitHub Actions

### Local (troubleshooting/debugging/enhancements)

If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/master/docs/run-linter-locally.md)

Check out the [note](#how-it-works) in **How it Works** to understand more about the **Super-Linter** linting locally versus via continuous integration.

### Azure

Check out this [article](https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/)

### GitLab

Check out this [snippet](https://gitlab.com/snippets/1988376)

### Visual Studio Code

You can checkout this repository using [Container Remote Development](https://code.visualstudio.com/docs/remote/containers), and debug the linter using the `Test Linter` task.
![Example](https://user-images.githubusercontent.com/15258962/85165778-2d2ce700-b21b-11ea-803e-3f6709d8e609.gif)

We will also support [GitHub Codespaces](https://github.com/features/codespaces/) once it becomes available

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
