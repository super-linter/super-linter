# Super-Linter

This repository is for the **GitHub Action** to run a **Super-Linter**.
It is a simple combination of various linters, written in `bash`, to help validate your source code.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/51071879604e4f319859d4daf91c68f5)](https://app.codacy.com/gh/github/super-linter/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=github/super-linter&amp;utm_campaign=Badge_Grade)

**The end goal of this tool:**

- Prevent broken code from being uploaded to the default branch (_Usually_ `master` or `main`)
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
    - [Images](#images)
      - [Standard Image](#standard-image)
      - [Slim Image](#slim-image)
  - [Environment variables](#environment-variables)
    - [Template rules files](#template-rules-files)
    - [Using your own rules files](#using-your-own-rules-files)
    - [Disabling rules](#disabling-rules)
  - [Filter linted files](#filter-linted-files)
  - [Docker Hub](#docker-hub)
  - [Run Super-Linter outside GitHub Actions](#run-super-linter-outside-github-actions)
    - [Local (troubleshooting/debugging/enhancements)](#local-troubleshootingdebuggingenhancements)
    - [Azure](#azure)
    - [GitLab](#gitlab)
    - [Visual Studio Code](#visual-studio-code)
    - [SSL Certs](#ssl-certs)
  - [Community Activity](#community-activity)
  - [Limitations](#limitations)
  - [How to contribute](#how-to-contribute)
    - [License](#license)

## How it Works

The super-linter finds issues and reports them to the console output. Fixes are suggested in the console output but not automatically fixed, and a status check will show up as failed on the pull request.

The design of the **Super-Linter** is currently to allow linting to occur in **GitHub Actions** as a part of continuous integration occurring on pull requests as the commits get pushed. It works best when commits are being pushed early and often to a branch with an open or draft pull request. There is some desire to move this closer to local development for faster feedback on linting errors but this is not yet supported.

## Supported Linters

Developers on **GitHub** can call the **GitHub Action** to lint their codebase with the following list of linters:

| _Language_                       | _Linter_                                                                                                                                                                      |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ansible**                      | [ansible-lint](https://github.com/ansible/ansible-lint)                                                                                                                       |
| **Azure Resource Manager (ARM)** | [arm-ttk](https://github.com/azure/arm-ttk)                                                                                                                                   |
| **AWS CloudFormation templates** | [cfn-lint](https://github.com/aws-cloudformation/cfn-python-lint/)                                                                                                            |
| **C++**                          | [cpp-lint](https://github.com/cpplint/cpplint) / [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)                                                     |
| **C#**                           | [dotnet-format](https://github.com/dotnet/format) / [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)                                                  |
| **CSS**                          | [stylelint](https://stylelint.io/)                                                                                                                                            |
| **Clojure**                      | [clj-kondo](https://github.com/borkdude/clj-kondo)                                                                                                                            |
| **CoffeeScript**                 | [coffeelint](https://coffeelint.github.io/)                                                                                                                                   |
| **Copy/paste detection**         | [jscpd](https://github.com/kucherenko/jscpd)                                                                                                                                  |
| **Dart**                         | [dartanalyzer](https://dart.dev/guides/language/analysis-options)                                                                                                             |
| **Dockerfile**                   | [dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git) / [hadolint](https://github.com/hadolint/hadolint)                                                       |
| **EditorConfig**                 | [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker)                                                                                          |
| **ENV**                          | [dotenv-linter](https://github.com/dotenv-linter/dotenv-linter)                                                                                                               |
| **GitHub Actions**               | [actionlint](https://github.com/rhysd/actionlint)                                                                                                                             |
| **Gherkin**                      | [gherkin-lint](https://github.com/vsiakka/gherkin-lint)                                                                                                                       |
| **Golang**                       | [golangci-lint](https://github.com/golangci/golangci-lint)                                                                                                                    |
| **Groovy**                       | [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)                                                                                                                |
| **HTML**                         | [HTMLHint](https://github.com/htmlhint/HTMLHint)                                                                                                                              |
| **Java**                         | [checkstyle](https://checkstyle.org) / [google-java-format](https://github.com/google/google-java-format)                                                                     |
| **JavaScript**                   | [ESLint](https://eslint.org/) / [standard js](https://standardjs.com/)                                                                                                        |
| **JSON**                         | [eslint-plugin-json](https://www.npmjs.com/package/eslint-plugin-json)                                                                                                        |
| **JSONC**                        | [eslint-plugin-jsonc](https://www.npmjs.com/package/eslint-plugin-jsonc)                                                                                                      |
| **Kubeval**                      | [kubeval](https://github.com/instrumenta/kubeval)                                                                                                                             |
| **Kotlin**                       | [ktlint](https://github.com/pinterest/ktlint)                                                                                                                                 |
| **LaTeX**                        | [ChkTex](https://www.nongnu.org/chktex/)                                                                                                                                      |
| **Lua**                          | [luacheck](https://github.com/luarocks/luacheck)                                                                                                                              |
| **Markdown**                     | [markdownlint](https://github.com/igorshubovych/markdownlint-cli#readme)                                                                                                      |
| **Natural language**             | [textlint](https://textlint.github.io/)                                                                                                                                       |
| **OpenAPI**                      | [spectral](https://github.com/stoplightio/spectral)                                                                                                                           |
| **Perl**                         | [perlcritic](https://metacpan.org/pod/Perl::Critic)                                                                                                                           |
| **PHP**                          | [PHP built-in linter](https://www.php.net/) / [PHP CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) / [PHPStan](https://phpstan.org/) / [Psalm](https://psalm.dev/) |
| **PowerShell**                   | [PSScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer)                                                                                                            |
| **Protocol Buffers**             | [protolint](https://github.com/yoheimuta/protolint)                                                                                                                           |
| **Python3**                      | [pylint](https://www.pylint.org/) / [flake8](https://flake8.pycqa.org/en/latest/) / [black](https://github.com/psf/black) / [isort](https://pypi.org/project/isort/)          |
| **R**                            | [lintr](https://github.com/jimhester/lintr)                                                                                                                                   |
| **Raku**                         | [Raku](https://raku.org)                                                                                                                                                      |
| **Ruby**                         | [RuboCop](https://github.com/rubocop-hq/rubocop)                                                                                                                              |
| **Rust**                         | [Rustfmt](https://github.com/rust-lang/rustfmt) / [Clippy](https://github.com/rust-lang/rust-clippy)                                                                          |
| **Scala**                        | [scalafmt](https://github.com/scalameta/scalafmt)                                                                                                                             |
| **Secrets**                      | [GitLeaks](https://github.com/zricethezav/gitleaks)                                                                                                                           |
| **Shell**                        | [Shellcheck](https://github.com/koalaman/shellcheck) / [executable bit check] / [shfmt](https://github.com/mvdan/sh)                                                          |
| **Snakemake**                    | [snakefmt](https://github.com/snakemake/snakefmt/) / [snakemake --lint](https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html#best-practices)         |
| **SQL**                          | [sql-lint](https://github.com/joereynolds/sql-lint) / [sqlfluff](https://github.com/sqlfluff/sqlfluff)                                                                        |
| **Tekton**                       | [tekton-lint](https://github.com/IBM/tekton-lint)                                                                                                                             |
| **Terraform**                    | [tflint](https://github.com/terraform-linters/tflint) / [terrascan](https://github.com/accurics/terrascan)                                                                    |
| **Terragrunt**                   | [terragrunt](https://github.com/gruntwork-io/terragrunt)                                                                                                                      |
| **TypeScript**                   | [ESLint](https://eslint.org/) / [standard js](https://standardjs.com/)                                                                                                        |
| **XML**                          | [LibXML](http://xmlsoft.org/)                                                                                                                                                 |
| **YAML**                         | [YamlLint](https://github.com/adrienverge/yamllint)                                                                                                                           |

## How to use

More in-depth [tutorial](https://www.youtube.com/watch?v=EDAmFKO4Zt0&t=118s) available

To use this **GitHub** Action you will need to complete the following:

1. Create a new file in your repository called `.github/workflows/linter.yml`
2. Copy the example workflow from below into that new file, no extra configuration required
3. Commit that file to a new branch
4. Open up a pull request and observe the action working
5. Enjoy your more _stable_, and _cleaner_ codebase
6. Check out the [Wiki](https://github.com/github/super-linter/wiki) for customization options

**NOTE:** If you pass the _Environment_ variable `GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}` in your workflow, then the **GitHub Super-Linter** will mark the status of each individual linter run in the Checks section of a pull request. Without this you will only see the overall status of the full run. There is no need to set the **GitHub** Secret as it is automatically set by GitHub, it only needs to be passed to the action.

### Example connecting GitHub Action Workflow

In your repository you should have a `.github/workflows` folder with **GitHub** Action similar to below:

- `.github/workflows/linter.yml`
  - Example file can be found at [`TEMPLATES/linter.yml`](/TEMPLATES/linter.yml)

This file should have the following code:

```yml
---
#################################
#################################
## Super Linter GitHub Actions ##
#################################
#################################
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
    branches-ignore: [master, main]
    # Remove the line above to run when pushing to master
  pull_request:
    branches: [master, main]

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
        with:
          # Full git history is needed to get a proper list of changed files within `super-linter`
          fetch-depth: 0

      ################################
      # Run Linter against code base #
      ################################
      - name: Lint Code Base
        uses: github/super-linter@v4
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

### Images

The **GitHub Super-Linter** now builds and supports `multiple` images. We have found as we added more linters, the image size expanded drastically.
After further investigation, we were able to see that a few linters were very disk heavy. We removed those linters and created the `slim` image.
This allows users to choose which **Super-Linter** they want to run and potentially speed up their build time.
The available images:
- `github/super-linter:v4`
- `github/super-linter:slim-v4`

#### Standard Image

The standard `github/super-linter:v4` comes with all supported linters.
Example usage:

```yml
################################
# Run Linter against code base #
################################
- name: Lint Code Base
  uses: github/super-linter@v4
  env:
    VALIDATE_ALL_CODEBASE: false
    DEFAULT_BRANCH: master
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Slim Image

The slim `github/super-linter:slim-v4` comes with all supported linters but removes the following:

- `rust` linters
- `dotenv` linters
- `armttk` linters
- `pwsh` linters
- `c#` linters

By removing these linters, we were able to bring the image size down by `2gb` and drastically speed up the build and download time.
The behavior will be the same for non-supported languages, and will skip languages at run time.
Example usage:

```yml
################################
# Run Linter against code base #
################################
- name: Lint Code Base
  uses: github/super-linter/slim@v4
  env:
    VALIDATE_ALL_CODEBASE: false
    DEFAULT_BRANCH: master
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Environment variables

The super-linter allows you to pass the following `ENV` variables to be able to trigger different functionality.

_Note:_ All the `VALIDATE_[LANGUAGE]` variables behave in a very specific way:

- If none of them are passed, then they all default to true.
- If any one of the variables are set to true, we default to leaving any unset variable to false (only validate those languages).
- If any one of the variables are set to false, we default to leaving any unset variable to true (only exclude those languages).
- If there are `VALIDATE_[LANGUAGE]` variables set to both true and false. It will fail.

This means that if you run the linter "out of the box", all languages will be checked.
But if you wish to select or exclude specific linters, we give you full control to choose which linters are run, and won't run anything unexpected.

| **ENV VAR**                        | **Default Value**               | **Notes**                                                                                                                                                                                                            |
| ---------------------------------- | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ACTIONS_RUNNER_DEBUG**           | `false`                         | Flag to enable additional information about the linter, versions, and additional output.                                                                                                                             |
| **ANSIBLE_CONFIG_FILE**            | `.ansible-lint.yml`             | Filename for [Ansible-lint configuration](https://ansible-lint.readthedocs.io/en/latest/configuring.html#configuration-file) (ex: `.ansible-lint`, `.ansible-lint.yml`)                                              |
| **ANSIBLE_DIRECTORY**              | `/ansible`                      | Flag to set the root directory for Ansible file location(s), relative to `DEFAULT_WORKSPACE`. Set to `.` to use the top-level of the `DEFAULT_WORKSPACE`.                                                            |
| **CSS_FILE_NAME**                  | `.stylelintrc.json`             | Filename for [Stylelint configuration](https://github.com/stylelint/stylelint) (ex: `.stylelintrc.yml`, `.stylelintrc.yaml`)                                                                                         |
| **DEFAULT_BRANCH**                 | `master`                        | The name of the repository default branch.                                                                                                                                                                           |
| **DEFAULT_WORKSPACE**              | `/tmp/lint`                     | The location containing files to lint if you are running locally.                                                                                                                                                    |
| **DISABLE_ERRORS**                 | `false`                         | Flag to have the linter complete with exit code 0 even if errors were detected.                                                                                                                                      |
| **DOCKERFILE_HADOLINT_FILE_NAME**  | `.hadolint.yaml`                | Filename for [hadolint configuration](https://github.com/hadolint/hadolint) (ex: `.hadolintlintrc.yaml`)                                                                                                             |
| **EDITORCONFIG_FILE_NAME**         | `.ecrc`                         | Filename for [editorconfig-checker configuration](https://github.com/editorconfig-checker/editorconfig-checker)                                                                                                      |
| **ERROR_ON_MISSING_EXEC_BIT**      | `false`                         | If set to `false`, the `bash-exec` linter will report a warning if a shell script is not executable. If set to `true`, the `bash-exec` linter will report an error instead.                                          |
| **FILTER_REGEX_EXCLUDE**           | `none`                          | Regular expression defining which files will be excluded from linting  (ex: `.*src/test.*`)                                                                                                                          |
| **FILTER_REGEX_INCLUDE**           | `all`                           | Regular expression defining which files will be processed by linters (ex: `.*src/.*`)                                                                                                                                |
| **GITHUB_ACTIONS_CONFIG_FILE**     | `actionlint.yml`                | Filename for [Actionlint configuration](https://github.com/rhysd/actionlint/blob/main/docs/config.md) (ex: `actionlint.yml`)                                                                                         |
| **GITHUB_DOMAIN**                  | `github.com`                    | Specify a custom GitHub domain in case GitHub Enterprise is used: e.g. `github.myenterprise.com`                                                                                                                     |
| **GITHUB_CUSTOM_API_URL**          | `https://api.github.com`        | Specify a custom GitHub API URL in case GitHub Enterprise is used: e.g. `https://github.myenterprise.com/api/v3`                                                                                                     |                                                                                         |
| **GITLEAKS_CONFIG_FILE**           | `.gitleaks.toml`                | Filename for [GitLeaks configuration](https://github.com/zricethezav/gitleaks#configuration) (ex: `.geatleaks.toml`)                                                                                                 |
| **IGNORE_GENERATED_FILES**         | `false`                         | If set to `true`, super-linter will ignore all the files with `@generated` marker but without `@not-generated` marker.                                                                                               |
| **IGNORE_GITIGNORED_FILES**        | `false`                         | If set to `true`, super-linter will ignore all the files that are ignored by Git.                                                                                                                                    |
| **JAVA_FILE_NAME**                 | `sun-checks.xml`                | Filename for [Checkstyle configuration](https://checkstyle.sourceforge.io/config.html) (ex: `checkstyle.xml`)                                                                                                        |
| **JAVASCRIPT_ES_CONFIG_FILE**      | `.eslintrc.yml`                 | Filename for [ESLint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)                                                               |
| **JAVASCRIPT_DEFAULT_STYLE**       | `standard`                      | Flag to set the default style of JavaScript. Available options: **standard**/**prettier**                                                                                                                            |
| **JSCPD_CONFIG_FILE**              | `.jscpd.json`                   | Filename for JSCPD configuration                                                                                                                                                                                     |
| **KUBERNETES_KUBEVAL_OPTIONS**     | `null`                          | Additional arguments to pass to the command-line when running **Kubernetes Kubeval** (Example: --ignore-missing-schemas)                                                                                             |
| **LINTER_RULES_PATH**              | `.github/linters`               | Directory for all linter configuration rules.                                                                                                                                                                        |
| **LOG_FILE**                       | `super-linter.log`              | The filename for outputting logs. All output is sent to the log file regardless of `LOG_LEVEL`.                                                                                                                     |
| **LOG_LEVEL**                      | `VERBOSE`                       | How much output the script will generate to the console. One of `ERROR`, `WARN`, `NOTICE`, `VERBOSE`, `DEBUG` or `TRACE`.                                                                                            |
| **MULTI_STATUS**                   | `true`                          | A status API is made for each language that is linted to make visual parsing easier.                                                                                                                                 |
| **MARKDOWN_CONFIG_FILE**           | `.markdown-lint.yml`            | Filename for [Markdownlint configuration](https://github.com/DavidAnson/markdownlint#optionsconfig) (ex: `.markdown-lint.yml`, `.markdownlint.json`, `.markdownlint.yaml`)                                           |
| **MARKDOWN_CUSTOM_RULE_GLOBS**     | `.markdown-lint/rules,rules/**` | Comma-separated list of [file globs](https://github.com/igorshubovych/markdownlint-cli#globbing) matching [custom Markdownlint rule files](https://github.com/DavidAnson/markdownlint/blob/main/doc/CustomRules.md). |
| **PHP_CONFIG_FILE**                | `php.ini`                       | Filename for [PHP Configuration](https://www.php.net/manual/en/configuration.file.php) (ex: `php.ini`)                                                                                                               |
| **PYTHON_BLACK_CONFIG_FILE**       | `.python-black`                 | Filename for [black configuration](https://github.com/psf/black/blob/main/docs/guides/using_black_with_other_tools.md#black-compatible-configurations) (ex: `.isort.cfg`, `pyproject.toml`)                                                                         |
| **PYTHON_FLAKE8_CONFIG_FILE**      | `.flake8`                       | Filename for [flake8 configuration](https://flake8.pycqa.org/en/latest/user/configuration.html) (ex: `.flake8`, `tox.ini`)                                                                                           |
| **PYTHON_ISORT_CONFIG_FILE**       | `.isort.cfg`                    | Filename for [isort configuration](https://pycqa.github.io/isort/docs/configuration/config_files.html) (ex: `.isort.cfg`, `pyproject.toml`)                                                                              |
| **PYTHON_MYPY_CONFIG_FILE**        | `.mypy.ini`                     | Filename for [mypy configuration](https://mypy.readthedocs.io/en/stable/config_file.html) (ex: `.mypi.ini`, `setup.config`)                                                                                          |
| **PYTHON_PYLINT_CONFIG_FILE**      | `.python-lint`                  | Filename for [pylint configuration](https://pylint.pycqa.org/en/latest/user_guide/run.html?highlight=rcfile#command-line-options) (ex: `.python-lint`, `.pylintrc`)                                                  |
| **RUBY_CONFIG_FILE**               | `.ruby-lint.yml`                | Filename for [rubocop configuration](https://docs.rubocop.org/rubocop/configuration.html) (ex: `.ruby-lint.yml`, `.rubocop.yml`)                                                                                     |
| **SUPPRESS_FILE_TYPE_WARN**        | `false`                         | If set to `true`, will hide warning messages about files without their proper extensions. Default is `false`                                                                                                         |
| **SUPPRESS_POSSUM**                | `false`                         | If set to `true`, will hide the ASCII possum at top of log output. Default is `false`                                                                                                                                |
| **SCALAFMT_CONFIG_FILE**           | `.scalafmt.conf`                | Filename for [scalafmt configuration](https://scalameta.org/scalafmt/docs/configuration.html) (ex: `.scalafmt.conf`)                                                                                                 |
| **SNAKEMAKE_SNAKEFMT_CONFIG_FILE** | `.snakefmt.toml`                | Filename for [Snakemake configuration](https://github.com/snakemake/snakefmt#configuration) (ex: `pyproject.toml`, `.snakefmt.toml`)                                                                                 |
| **SSL_CERT_SECRET**                | `none`                          | SSL cert to add to the **Super-Linter** trust store. This is needed for users on `self-hosted` runners or need to inject the cert for security standards (ex. ${{ secrets.SSL_CERT }})                               |
| **SQL_CONFIG_FILE**                | `.sql-config.json`              | Filename for [SQL-Lint configuration](https://sql-lint.readthedocs.io/en/latest/files/configuration.html) (ex: `sql-config.json` , `.config.json`)                                                                   |
| **TERRAFORM_TFLINT_CONFIG_FILE**   | `.tflint.hcl`                   | Filename for [tfLint configuration](https://github.com/terraform-linters/tflint) (ex: `.tflint.hcl`)                                                                                                                 |
| **TERRAFORM_TERRASCAN_CONFIG_FILE**| `terrascan.toml`                | Filename for [terrascan configuration](https://github.com/accurics/terrascan) (ex: `terrascan.toml`)                                                                                                                 |
| **NATURAL_LANGUAGE_CONFIG_FILE**   | `.textlintrc`                   | Filename for [textlint configuration](https://textlint.github.io/docs/getting-started.html#configuration) (ex: `.textlintrc`)                                                                                        |
| **TYPESCRIPT_ES_CONFIG_FILE**      | `.eslintrc.yml`                 | Filename for [ESLint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats) (ex: `.eslintrc.yml`, `.eslintrc.json`)                                                               |
| **USE_FIND_ALGORITHM**             | `false`                         | By default, we use `git diff` to find all files in the workspace and what has been updated, this would enable the Linux `find` method instead to find all files to lint                                              |
| **VALIDATE_ALL_CODEBASE**          | `true`                          | Will parse the entire repository and find all files to validate across all types. **NOTE:** When set to `false`, only **new** or **edited** files will be parsed for validation.                                     |
| **VALIDATE_ANSIBLE**               | `true`                          | Flag to enable or disable the linting process of the Ansible language.                                                                                                                                               |
| **VALIDATE_ARM**                   | `true`                          | Flag to enable or disable the linting process of the ARM language.                                                                                                                                                   |
| **VALIDATE_BASH**                  | `true`                          | Flag to enable or disable the linting process of the Bash language.                                                                                                                                                  |
| **VALIDATE_BASH_EXEC**             | `true`                          | Flag to enable or disable the linting process of the Bash language to validate if file is stored as executable.                                                                                                      |
| **VALIDATE_CPP**                   | `true`                          | Flag to enable or disable the linting process of the C++ language.                                                                                                                                                   |
| **VALIDATE_CLANG_FORMAT**          | `true`                          | Flag to enable or disable the linting process of the C++/C language with clang-format.                                                                                                                               |
| **VALIDATE_CLOJURE**               | `true`                          | Flag to enable or disable the linting process of the Clojure language.                                                                                                                                               |
| **VALIDATE_CLOUDFORMATION**        | `true`                          | Flag to enable or disable the linting process of the AWS Cloud Formation language.                                                                                                                                   |
| **VALIDATE_COFFEESCRIPT**          | `true`                          | Flag to enable or disable the linting process of the Coffeescript language.                                                                                                                                          |
| **VALIDATE_CSHARP**                | `true`                          | Flag to enable or disable the linting process of the C# language.                                                                                                                                                    |
| **VALIDATE_CSS**                   | `true`                          | Flag to enable or disable the linting process of the CSS language.                                                                                                                                                   |
| **VALIDATE_DART**                  | `true`                          | Flag to enable or disable the linting process of the Dart language.                                                                                                                                                  |
| **VALIDATE_DOCKERFILE**            | `true`                          | Flag to enable or disable the linting process of the Docker language.                                                                                                                                                |
| **VALIDATE_DOCKERFILE_HADOLINT**   | `true`                          | Flag to enable or disable the linting process of the Docker language.                                                                                                                                                |
| **VALIDATE_EDITORCONFIG**          | `true`                          | Flag to enable or disable the linting process with the EditorConfig.                                                                                                                                                 |
| **VALIDATE_ENV**                   | `true`                          | Flag to enable or disable the linting process of the ENV language.                                                                                                                                                   |
| **VALIDATE_GITHUB_ACTIONS**        | `true`                          | Flag to enable or disable the linting process of the GitHub Actions.                                                                                                                                                 |
| **VALIDATE_GITLEAKS**              | `true`                          | Flag to enable or disable the linting process of the secrets.                                                                                                                                                        |
| **VALIDATE_GHERKIN**               | `true`                          | Flag to enable or disable the linting process of the Gherkin language.                                                                                                                                               |
| **VALIDATE_GO**                    | `true`                          | Flag to enable or disable the linting process of the Golang language.                                                                                                                                                |
| **VALIDATE_GOOGLE_JAVA_FORMAT**    | `true`                          | Flag to enable or disable the linting process of the Java language. (Utilizing: google-java-format)                                                                                                                  |
| **VALIDATE_GROOVY**                | `true`                          | Flag to enable or disable the linting process of the language.                                                                                                                                                       |
| **VALIDATE_HTML**                  | `true`                          | Flag to enable or disable the linting process of the HTML language.                                                                                                                                                  |
| **VALIDATE_JAVA**                  | `true`                          | Flag to enable or disable the linting process of the Java language. (Utilizing: checkstyle)                                                                                                                          |
| **VALIDATE_JAVASCRIPT_ES**         | `true`                          | Flag to enable or disable the linting process of the JavaScript language. (Utilizing: eslint)                                                                                                                        |
| **VALIDATE_JAVASCRIPT_STANDARD**   | `true`                          | Flag to enable or disable the linting process of the JavaScript language. (Utilizing: standard)                                                                                                                      |
| **VALIDATE_JSCPD**                 | `true`                          | Flag to enable or disable the JSCPD.                                                                                                                                                                                 |
| **VALIDATE_JSON**                  | `true`                          | Flag to enable or disable the linting process of the JSON language.                                                                                                                                                  |
| **VALIDATE_JSX**                   | `true`                          | Flag to enable or disable the linting process for jsx files (Utilizing: eslint)                                                                                                                                      |
| **VALIDATE_KOTLIN**                | `true`                          | Flag to enable or disable the linting process of the Kotlin language.                                                                                                                                                |
| **VALIDATE_KUBERNETES_KUBEVAL**    | `true`                          | Flag to enable or disable the linting process of Kubernetes descriptors with Kubeval                                                                                                                                 |
| **VALIDATE_LATEX**                 | `true`                          | Flag to enable or disable the linting process of the LaTeX language.                                                                                                                                                 |
| **VALIDATE_LUA**                   | `true`                          | Flag to enable or disable the linting process of the language.                                                                                                                                                       |
| **VALIDATE_MARKDOWN**              | `true`                          | Flag to enable or disable the linting process of the Markdown language.                                                                                                                                              |
| **VALIDATE_NATURAL_LANGUAGE**      | `true`                          | Flag to enable or disable the linting process of the natural language.                                                                                                                                               |
| **VALIDATE_OPENAPI**               | `true`                          | Flag to enable or disable the linting process of the OpenAPI language.                                                                                                                                               |
| **VALIDATE_PERL**                  | `true`                          | Flag to enable or disable the linting process of the Perl language.                                                                                                                                                  |
| **VALIDATE_PHP**                   | `true`                          | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP built-in linter) (keep for backward compatibility)                                                                                |
| **VALIDATE_PHP_BUILTIN**           | `true`                          | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP built-in linter)                                                                                                                  |
| **VALIDATE_PHP_PHPCS**             | `true`                          | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP CodeSniffer)                                                                                                                      |
| **VALIDATE_PHP_PHPSTAN**           | `true`                          | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHPStan)                                                                                                                              |
| **VALIDATE_PHP_PSALM**             | `true`                          | Flag to enable or disable the linting process of the PHP language. (Utilizing: PSalm)                                                                                                                                |
| **VALIDATE_PROTOBUF**              | `true`                          | Flag to enable or disable the linting process of the Protobuf language.                                                                                                                                              |
| **VALIDATE_PYTHON**                | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint) (keep for backward compatibility)                                                                                          |
| **VALIDATE_PYTHON_BLACK**          | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: black)                                                                                                                             |
| **VALIDATE_PYTHON_FLAKE8**         | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: flake8)                                                                                                                            |
| **VALIDATE_PYTHON_ISORT**          | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: isort)                                                                                                                             |
| **VALIDATE_PYTHON_MYPY**           | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: mypy)                                                                                                                              |
| **VALIDATE_PYTHON_PYLINT**         | `true`                          | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint)                                                                                                                            |
| **VALIDATE_POWERSHELL**            | `true`                          | Flag to enable or disable the linting process of the Powershell language.                                                                                                                                            |
| **VALIDATE_R**                     | `true`                          | Flag to enable or disable the linting process of the R language.                                                                                                                                                     |
| **VALIDATE_RAKU**                  | `true`                          | Flag to enable or disable the linting process of the Raku language.                                                                                                                                                  |
| **VALIDATE_RUBY**                  | `true`                          | Flag to enable or disable the linting process of the Ruby language.                                                                                                                                                  |
| **VALIDATE_RUST_2015**             | `true`                          | Flag to enable or disable the linting process of the Rust language. (edition: 2015)                                                                                                                                  |
| **VALIDATE_RUST_2018**             | `true`                          | Flag to enable or disable the linting process of Rust language. (edition: 2018)                                                                                                                                      |
| **VALIDATE_RUST_CLIPPY**           | `true`                          | Flag to enable or disable the clippy linting process of Rust language.                                                                                                                                               |
| **VALIDATE_SCALAFMT_LINT**         | `true`                          | Flag to enable or disable the linting process of Scala language. (Utilizing: scalafmt --test)                                                                                                                        |
| **VALIDATE_SHELL_SHFMT**           | `true`                          | Flag to enable or disable the linting process of Shell scripts. (Utilizing: shfmt)                                                                                                                                   |
| **VALIDATE_SNAKEMAKE_LINT**        | `true`                          | Flag to enable or disable the linting process of Snakefiles. (Utilizing: snakemake --lint)                                                                                                                           |
| **VALIDATE_SNAKEMAKE_SNAKEFMT**    | `true`                          | Flag to enable or disable the linting process of Snakefiles. (Utilizing: snakefmt)                                                                                                                                   |
| **VALIDATE_STATES**                | `true`                          | Flag to enable or disable the linting process for AWS States Language.                                                                                                                                               |
| **VALIDATE_SQL**                   | `true`                          | Flag to enable or disable the linting process of the SQL language.                                                                                                                                                   |
| **VALIDATE_SQLFLUFF**              | `true`                          | Flag to enable or disable the linting process of the SQL language. (Utilizing: sqlfuff)                                                                                                                              |
| **VALIDATE_TEKTON**                | `true`                          | Flag to enable or disable the linting process of the Tekton language.                                                                                                                                                |
| **VALIDATE_TERRAFORM_TFLINT**      | `true`                          | Flag to enable or disable the linting process of the Terraform language. (Utilizing tflint)                                                                                                                          |
| **VALIDATE_TERRAFORM_TERRASCAN**   | `true`                          | Flag to enable or disable the linting process of the Terraform language for security related issues.                                                                                                                 |
| **VALIDATE_TERRAGRUNT**            | `true`                          | Flag to enable or disable the linting process for Terragrunt files.                                                                                                                                                  |
| **VALIDATE_TSX**                   | `true`                          | Flag to enable or disable the linting process for tsx files (Utilizing: eslint)                                                                                                                                      |
| **VALIDATE_TYPESCRIPT_ES**         | `true`                          | Flag to enable or disable the linting process of the TypeScript language. (Utilizing: eslint)                                                                                                                        |
| **VALIDATE_TYPESCRIPT_STANDARD**   | `true`                          | Flag to enable or disable the linting process of the TypeScript language. (Utilizing: standard)                                                                                                                      |
| **VALIDATE_XML**                   | `true`                          | Flag to enable or disable the linting process of the XML language.                                                                                                                                                   |
| **VALIDATE_YAML**                  | `true`                          | Flag to enable or disable the linting process of the YAML language.                                                                                                                                                  |
| **YAML_CONFIG_FILE**               | `.yaml-lint.yml`                | Filename for [Yamllint configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) (ex: `.yaml-lint.yml`, `.yamllint.yml`)                                                                          |

### Template rules files

You can use the **GitHub** **Super-Linter** _with_ or _without_ your own personal rules sets. This allows for greater flexibility for each individual codebase. The Template rules all try to follow the standards we believe should be enabled at the basic level.

- Copy **any** or **all** template rules files from `TEMPLATES/` into the `.github/linters/` directory of your repository, and modify them to suit your needs.
  - The rules files in [this repository's `TEMPLATE` folder](https://github.com/github/super-linter/tree/main/TEMPLATES) will be used as defaults should any be omitted.

### Using your own rules files

If your repository contains your own rules files that live outside of a `.github/linters/` directory, you will have to tell Super-Linter where your rules files are located in your repository, and what their filenames are. To learn more, see [Using your own rules files](docs/using-rules-files.md).

### Disabling rules

If you need to disable certain _rules_ and _functionality_, you can view [Disable Rules](https://github.com/github/super-linter/blob/main/docs/disabling-linters.md)

## Filter linted files

If you need to lint only a folder or exclude some files from linting, you can use optional environment parameters `FILTER_REGEX_INCLUDE` and `FILTER_REGEX_EXCLUDE`

Examples:

- Lint only src folder: `FILTER_REGEX_INCLUDE: .*src/.*`
- Do not lint files inside test folder: `FILTER_REGEX_EXCLUDE: .*test/.*`
- Do not lint JavaScript files inside test folder: `FILTER_REGEX_EXCLUDE: .*test/.*.js`

<!-- This `README.md` has both markers in the text, so it is considered not generated. -->
Additionally when `IGNORE_GENERATED_FILES=true`, super-linter
ignores any file with `@generated` marker in it unless the file
also has `@not-generated` marker. `@generated` marker is
[used by Facebook](https://engineering.fb.com/2015/08/20/open-source/writing-code-that-writes-code-with-hack-codegen/)
and some other projects to mark generated files. For example, this
file is considered generated:

```bash
#!/bin/sh
echo "@generated"
```

And this file is considered not generated:

```bash
#!/bin/sh
echo "@generated" # @not-generated
```

## Docker Hub

The **Docker** container that is built from this repository is located at [github/super-linter](https://hub.docker.com/r/github/super-linter)

## Run Super-Linter outside GitHub Actions

### Local (troubleshooting/debugging/enhancements)

If you find that you need to run super-linter locally, you can follow the documentation at [Running super-linter locally](https://github.com/github/super-linter/blob/main/docs/run-linter-locally.md)

Check out the [note](#how-it-works) in **How it Works** to understand more about the **Super-Linter** linting locally versus via continuous integration.

### Azure

Check out this [article](https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/)

### GitLab

Check out this [snippet](https://gitlab.com/snippets/1988376) and this Guided Exploration: [GitLab CI CD Extension for Super-Linter](https://gitlab.com/guided-explorations/ci-cd-plugin-extensions/ci-cd-plugin-extension-github-action-super-linter)

### Visual Studio Code

You can checkout this repository using [Container Remote Development](https://code.visualstudio.com/docs/remote/containers), and debug the linter using the `Test Linter` task.
![Example](https://user-images.githubusercontent.com/15258962/85165778-2d2ce700-b21b-11ea-803e-3f6709d8e609.gif)

We will also support [GitHub Codespaces](https://github.com/features/codespaces/) once it becomes available

### SSL Certs

If you need to inject a SSL cert into the trust store, you will need to first copy the cert to **GitHub Secrets**
Once you have copied the plain text certificate into **GitHub Secrets**, you can use the variable `SSL_CERT_SECRET` to point the **Super-Linter** to the files contents.
Once found, it will load the certificate contents to a file, and to the trust store.

- Example workflow:

```yml
- name: Lint Code Base
  uses: github/super-linter@v4
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    SSL_CERT_SECRET: ${{ secrets.ROOT_CA }}
```

## Community Activity

![super-linter stats](https://cauldron.io/project/2083/stats.svg)

## Limitations

Below are a list of the known limitations for the **GitHub Super-Linter**:

- Due to being completely packaged at run time, you will not be able to update dependencies or change versions of the enclosed linters and binaries
- Additional details from `package.json` are not read by the **GitHub Super-Linter**
- Downloading additional codebases as dependencies from private repositories will fail due to lack of permissions

## How to contribute

If you would like to help contribute to this **GitHub** Action, please see [CONTRIBUTING](https://github.com/github/super-linter/blob/main/.github/CONTRIBUTING.md)

---

### License

- [MIT License](https://github.com/github/super-linter/blob/main/LICENSE)
