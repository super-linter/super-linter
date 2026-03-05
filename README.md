# Super-Linter

Super-linter is a ready-to-run collection of linters and code analyzers, to help
validate and fix your source code.

The goal of super-linter is to help you establish best practices and consistent
formatting across multiple programming languages, and ensure developers are
adhering to those conventions.

Super-linter analyzes source code files using several tools, and reports the
issues that those tools find as console output, and as
[GitHub Actions status checks](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks).
You can also
[run super-linter outside GitHub Actions](#run-super-linter-outside-github-actions).

Super-linter can also help you
[fix linting and formatting issues](#fix-linting-and-formatting-issues).

Super-linter is licensed under an
[MIT License](https://github.com/super-linter/super-linter/blob/main/LICENSE).

[![Super-Linter](https://github.com/super-linter/super-linter/actions/workflows/cd.yml/badge.svg)](https://github.com/marketplace/actions/super-linter)

Here are some notable Super-linter features:

- **MIT License**: Super-linter is licensed under a [MIT License](LICENSE).
- **Independent project**: Super-linter is maintained by a team of independent
  developers and is not commercially backed by any entity that might influence
  the course of the project.
- **Widely used**: Super-linter is the
  [most widely used](https://github.com/super-linter/super-linter/network/dependents)
  and [forked](https://github.com/super-linter/super-linter/forks) project of
  this kind.
- **Runs linters in parallel**: Since `v6`, Super-linter parallelizes running
  all the included linters, leading to scanning massive code repositories in
  seconds.
- **Highly curated set of linters**: Avoid including linters that implement
  overlapping checks, reducing bloat, scanning times, and container image size.
- **Run on GitHub Actions or other environments**: Super-linter runs
  [on GitHub Actions](#get-started) and
  [other runtime environments](#run-using-a-container-runtime-engine), with the
  only dependency of an OCI-compatible container runtime engine, such as Docker.
- **Lean codebase**: Super-linter doesn't reinvent the wheel, and builds on top
  of established tools and standards, such as
  [GNU Parallel](https://www.gnu.org/software/parallel/).
- **Extensive test suite**: Super-linter includes an extensive test suite that
  covers every single linter and analyzer that Super-linter ships.
- **Original design**: to the best of our knowledge, Super-linter is the first
  open-source, fully-containerized linting suite. Other projects borrow ideas
  and design choices from Super-linter (and we're cool with that :).

## How to contribute

If you would like to help contribute to Super-linter, see
[CONTRIBUTING](https://github.com/super-linter/super-linter/blob/main/.github/CONTRIBUTING.md).

For a guide on how to set up your development environment and contribute to
Super-linter, see the [development guide](docs/DEVELOPMENT.md).

## Supported linters and formatters

Super-linter supports the following tools:

| Language                              | Linters                                                                                                                                                                                                                   | Formatters                                                                                                         |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Ansible**                           | [ansible-lint](https://github.com/ansible/ansible-lint)                                                                                                                                                                   | See YAML and Python formatters                                                                                     |
| **Amazon States Language**            | [ASL Validator](https://github.com/ChristopheBougere/asl-validator)                                                                                                                                                       | See JSON formatters                                                                                                |
| **Astro**                             | [Biome](https://biomejs.dev/)                                                                                                                                                                                             | [Biome](https://biomejs.dev/)                                                                                      |
| **AWS CloudFormation templates**      | [AWS CloudFormation Linter (cfn-lint)](https://github.com/aws-cloudformation/cfn-lint), [Checkov](https://www.checkov.io/), [Trivy](https://trivy.dev/)                                                                   | See YAML formatters                                                                                                |
| **Azure Resource Manager (ARM)**      | [Azure Resource Manager Template Toolkit (arm-ttk)](https://github.com/azure/arm-ttk), [Checkov](https://www.checkov.io/), [Trivy](https://trivy.dev/)                                                                    | See JSON formatters                                                                                                |
| **C**, **C++**                        | [cpp-lint](https://github.com/cpplint/cpplint)                                                                                                                                                                            | [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html)                                           |
| **C#**                                | See Dotnet solutions                                                                                                                                                                                                      | [dotnet format whitespace command](https://github.com/dotnet/format)                                               |
| **CSS**, **SCSS**, **Sass**           | [stylelint](https://stylelint.io/), [Biome](https://biomejs.dev/)                                                                                                                                                         | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **Clojure**                           | [clj-kondo](https://github.com/borkdude/clj-kondo)                                                                                                                                                                        |                                                                                                                    |
| **CoffeeScript**                      | [coffeelint](https://coffeelint.github.io/)                                                                                                                                                                               |                                                                                                                    |
| **Commit messages**                   | [commitlint](https://commitlint.js.org/)                                                                                                                                                                                  |                                                                                                                    |
| **Copy/paste detection**              | [jscpd](https://github.com/kucherenko/jscpd)                                                                                                                                                                              | N/A                                                                                                                |
| **Dart**                              | [dart analyze command](https://dart.dev/guides/language/analysis-options)                                                                                                                                                 |                                                                                                                    |
| **Dockerfile**                        | [Haskell Dockerfile Linter (Hadolint)](https://github.com/hadolint/hadolint), [Checkov](https://www.checkov.io/), [Trivy](https://trivy.dev/)                                                                             |                                                                                                                    |
| **Dotnet (.NET) solutions (sln)**     | [dotnet format command](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format): analyzers, style subcommands.                                                                                                 | [dotnet format command](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-format): whitespace subcommand. |
| **EditorConfig**                      | [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker)                                                                                                                                      |                                                                                                                    |
| **.env**                              | [dotenv-linter](https://github.com/dotenv-linter/dotenv-linter)                                                                                                                                                           |                                                                                                                    |
| **Git merge conflict markers**        | [Git conflict markers presence in files](https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeconflictStyle)                                                                                             | N/A                                                                                                                |
| **GitHub Actions**                    | [actionlint](https://github.com/rhysd/actionlint), [zizmor](https://docs.zizmor.sh/)                                                                                                                                      | See YAML formatters                                                                                                |
| **Go**                                | [golangci-lint](https://github.com/golangci/golangci-lint)                                                                                                                                                                |                                                                                                                    |
| **GoReleaser**                        | [GoReleaser](https://github.com/goreleaser/goreleaser)                                                                                                                                                                    | See YAML formatters                                                                                                |
| **GraphQL**                           | [Biome](https://biomejs.dev/)                                                                                                                                                                                             | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **GritQL**                            |                                                                                                                                                                                                                           | [Biome](https://biomejs.dev/)                                                                                      |
| **Groovy**                            | [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)                                                                                                                                                            |                                                                                                                    |
| **Helm charts**                       | [Checkov](https://www.checkov.io/)                                                                                                                                                                                        | See YAML formatters                                                                                                |
| **HTML**                              | [HTMLHint](https://github.com/htmlhint/HTMLHint)                                                                                                                                                                          | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **Java**                              | [checkstyle](https://checkstyle.org)                                                                                                                                                                                      | [google-java-format](https://github.com/google/google-java-format)                                                 |
| **JavaScript**                        | [ESLint](https://eslint.org/), [Biome](https://biomejs.dev/)                                                                                                                                                              | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **JSON**                              | [eslint-plugin-jsonc (configured for JSON)](https://www.npmjs.com/package/eslint-plugin-jsonc) (ESLint default), [eslint-plugin-json](https://www.npmjs.com/package/eslint-plugin-json), [Biome](https://biomejs.dev/)    | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **JSONC**, **JSON5**                  | [eslint-plugin-jsonc](https://www.npmjs.com/package/eslint-plugin-jsonc), [Biome](https://biomejs.dev/)                                                                                                                   | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **JSX**, **TSX**                      | [eslint-plugin-jsx-a11y](https://github.com/jsx-eslint/eslint-plugin-jsx-a11y), [eslint-plugin-react](https://github.com/jsx-eslint/eslint-plugin-react), [Biome](https://biomejs.dev/)                                   | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **Jupyter Notebook**                  | [nbqa](https://nbqa.readthedocs.io/en/latest/index.html)                                                                                                                                                                  | [nbqa](https://nbqa.readthedocs.io/en/latest/index.html)                                                           |
| **Kubernetes**                        | [Checkov](https://www.checkov.io/), [Trivy](https://trivy.dev/), [kubeconform](https://github.com/yannh/kubeconform)                                                                                                      | See YAML formatters                                                                                                |
| **Kotlin**                            | [ktlint](https://github.com/pinterest/ktlint)                                                                                                                                                                             |                                                                                                                    |
| **LaTeX**                             | [ChkTex](https://www.nongnu.org/chktex/)                                                                                                                                                                                  |                                                                                                                    |
| **Licenses**                          | [Trivy](https://trivy.dev/)                                                                                                                                                                                               | N/A                                                                                                                |
| **Lua**                               | [luacheck](https://github.com/luarocks/luacheck)                                                                                                                                                                          |                                                                                                                    |
| **Markdown**                          | [markdownlint](https://github.com/igorshubovych/markdownlint-cli)                                                                                                                                                         | [Prettier](https://prettier.io/)                                                                                   |
| **Natural language**                  | [textlint](https://textlint.github.io/)                                                                                                                                                                                   | N/A                                                                                                                |
| **OpenAPI**                           | [spectral](https://github.com/stoplightio/spectral)                                                                                                                                                                       | See YAML formatters                                                                                                |
| **Perl**                              | [perlcritic](https://metacpan.org/pod/Perl::Critic)                                                                                                                                                                       |                                                                                                                    |
| **PHP**                               | [PHP built-in linter](https://www.php.net/manual/en/features.commandline.options.php), [PHP CodeSniffer](https://github.com/PHPCSStandards/PHP_CodeSniffer), [PHPStan](https://phpstan.org/), [Psalm](https://psalm.dev/) |                                                                                                                    |
| **PowerShell**                        | [PSScriptAnalyzer](https://github.com/PowerShell/Psscriptanalyzer)                                                                                                                                                        |                                                                                                                    |
| **Pre-commit**                        | [pre-commit](https://pre-commit.com/)                                                                                                                                                                                     |                                                                                                                    |
| **Protocol Buffers (Protobuf)**       | [protolint](https://github.com/yoheimuta/protolint)                                                                                                                                                                       |                                                                                                                    |
| **Python3**                           | [pylint](https://pylint.pycqa.org/), [flake8](https://flake8.pycqa.org/en/latest/), [isort](https://pypi.org/project/isort/), [ruff](https://github.com/astral-sh/ruff)                                                   | [black](https://github.com/psf/black)                                                                              |
| **R**                                 | [lintr](https://github.com/jimhester/lintr)                                                                                                                                                                               |                                                                                                                    |
| **Renovate**                          | [renovate-config-validator](https://docs.renovatebot.com/config-validation/)                                                                                                                                              | See JSON formatters                                                                                                |
| **Ruby**                              | [RuboCop](https://github.com/rubocop-hq/rubocop)                                                                                                                                                                          |                                                                                                                    |
| **Rust**                              | [Clippy](https://github.com/rust-lang/rust-clippy)                                                                                                                                                                        | [Rustfmt](https://github.com/rust-lang/rustfmt)                                                                    |
| **Scala**                             |                                                                                                                                                                                                                           | [scalafmt](https://github.com/scalameta/scalafmt)                                                                  |
| **Software bill of materials (SBOM)** | [Trivy](https://trivy.dev/)                                                                                                                                                                                               | N/A                                                                                                                |
| **Secrets**                           | [GitLeaks](https://github.com/zricethezav/gitleaks), [Trivy](https://trivy.dev/)                                                                                                                                          | N/A                                                                                                                |
| **Shell**                             | [ShellCheck](https://github.com/koalaman/shellcheck), `executable bit check`                                                                                                                                              | [shfmt](https://github.com/mvdan/sh)                                                                               |
| **Snakemake**                         | [snakemake --lint](https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html#best-practices)                                                                                                          | [snakefmt](https://github.com/snakemake/snakefmt/)                                                                 |
| **Spelling**                          | [codespell](https://github.com/codespell-project/codespell)                                                                                                                                                               | N/A                                                                                                                |
| **SQL**                               | [sqlfluff](https://github.com/sqlfluff/sqlfluff)                                                                                                                                                                          |                                                                                                                    |
| **Svelte**                            | [Biome](https://biomejs.dev/)                                                                                                                                                                                             | [Biome](https://biomejs.dev/)                                                                                      |
| **Terraform**                         | [tflint](https://github.com/terraform-linters/tflint), [Checkov](https://www.checkov.io/), [Trivy](https://trivy.dev/)                                                                                                    | [terraform fmt](https://developer.hashicorp.com/terraform/cli/commands/fmt)                                        |
| **Terragrunt**                        | [terragrunt](https://github.com/gruntwork-io/terragrunt)                                                                                                                                                                  | N/A                                                                                                                |
| **TypeScript**                        | [ESLint](https://eslint.org/), [Biome](https://biomejs.dev/)                                                                                                                                                              | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **Vue**                               | [eslint-plugin-vue](https://eslint.vuejs.org/), [Biome](https://biomejs.dev/)                                                                                                                                             | [Prettier](https://prettier.io/), [Biome](https://biomejs.dev/)                                                    |
| **Vulnerabilities**                   | [Trivy](https://trivy.dev/)                                                                                                                                                                                               | N/A                                                                                                                |
| **XML**                               | [LibXML](http://xmlsoft.org/)                                                                                                                                                                                             |                                                                                                                    |
| **YAML**                              | [YamlLint](https://github.com/adrienverge/yamllint)                                                                                                                                                                       | [Prettier](https://prettier.io/)                                                                                   |

## Get started

More in-depth [tutorial](https://www.youtube.com/watch?v=EDAmFKO4Zt0&t=118s)
available

To run super-linter as a GitHub Action, you do the following:

1. Create a new
   [GitHub Actions workflow](https://docs.github.com/en/actions/using-workflows/about-workflows#about-workflows)
   in your repository with the following content:

   ```yaml
   ---
   name: Lint

   on: # yamllint disable-line rule:truthy
     push: null
     pull_request: null

   permissions: {}

   jobs:
     build:
       name: Lint
       runs-on: ubuntu-latest

       permissions:
         # contents permission to clone the repository
         contents: read
         packages: read
         # issues and pull-requests permissions to write results as pull
         # request comments. Omit them if you don't need summary comments
         issues: write
         pull-requests: write
         # To report GitHub Actions status checks. Omit if you don't need
         # to update commit status
         statuses: write

       steps:
         - name: Checkout code
           uses: actions/checkout@v5
           with:
             # super-linter needs the full git history to get the
             # list of files that changed across commits
             fetch-depth: 0
             persist-credentials: false

         - name: Super-linter
           uses: super-linter/super-linter@v8.5.1 # x-release-please-version
           env:
             # To report GitHub Actions status checks
             GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```

1. Commit that file to a new branch.
1. Push the new commit to the remote repository.
1. Create a new pull request to observe the results.

## Upgrade to newer super-linter versions

For more information about upgrading super-linter to a new major version, see
the [upgrade guide](docs/upgrade-guide.md).

## Add Super-Linter badge in your repository readme

You can show Super-Linter status with a badge in your repository readme:

Example:

```markdown
[![Super-Linter](https://github.com/<OWNER>/<REPOSITORY>/actions/workflows/<WORKFLOW_FILE_NAME>/badge.svg)](https://github.com/marketplace/actions/super-linter)
```

For more information, see
[Adding a workflow status badge](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/adding-a-workflow-status-badge).

## Super-linter variants

Super-Linter provides several variants:

- `standard`: `super-linter/super-linter@[VERSION]`: includes all supported
  linters.
- `slim`: `super-linter/super-linter/slim@[VERSION]`: includes all supported
  linters except:
  - Rustfmt
  - Rust Clippy
  - Azure Resource Manager Template Toolkit (arm-ttk)
  - PSScriptAnalyzer
  - `dotnet` (.NET) commands and subcommands

## Configure Super-linter

You can configure Super-linter using the following environment variables:

| **Environment variable**                               | **Default Value**                                                            | **Description**                                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------------------------ | ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **ANSIBLE_CONFIG_FILE**                                | `.ansible-lint.yml`                                                          | Filename for [Ansible-lint configuration](https://ansible.readthedocs.io/projects/lint/configuring/) (ex: `.ansible-lint`, `.ansible-lint.yml`)                                                                                                                                                                                                                             |
| **ANSIBLE_DIRECTORY**                                  | `/ansible`                                                                   | Flag to set the root directory for Ansible file location(s), relative to `DEFAULT_WORKSPACE`. Set to `.` to use the top-level of the `DEFAULT_WORKSPACE`.                                                                                                                                                                                                                   |
| **BASH_EXEC_IGNORE_LIBRARIES**                         | `false`                                                                      | If set to `true`, shell files with a file extension and no shebang line are ignored when checking if the executable bit is set.                                                                                                                                                                                                                                             |
| **BASH_FILE_NAME**                                     | `.shellcheckrc`                                                              | Filename for [Shellcheck](https://github.com/koalaman/shellcheck/blob/master/shellcheck.1.md#rc-files)                                                                                                                                                                                                                                                                      |
| **BASH_SEVERITY**                                      | Shellcheck default severity                                                  | Specify the minimum severity of errors to consider in shellcheck. Valid values in order of severity are error, warning, info and style.                                                                                                                                                                                                                                     |
| **CHECKOV_FILE_NAME**                                  | `.checkov.yaml`                                                              | Configuration filename for Checkov.                                                                                                                                                                                                                                                                                                                                         |
| **CLANG_FORMAT_FILE_NAME**                             | `.clang-format`                                                              | Configuration filename for [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html).                                                                                                                                                                                                                                                                        |
| **CREATE_LOG_FILE**                                    | `false`                                                                      | If set to `true`, it creates the log file. You can set the log filename using the `LOG_FILE` environment variable. This overrides any existing log files.                                                                                                                                                                                                                   |
| **CSS_FILE_NAME**                                      | `.stylelintrc.json`                                                          | Filename for [Stylelint configuration](https://github.com/stylelint/stylelint) (ex: `.stylelintrc.yml`, `.stylelintrc.yaml`)                                                                                                                                                                                                                                                |
| **DEFAULT_BRANCH**                                     | Default repository branch when running on GitHub Actions, `master` otherwise | The name of the repository default branch. Don't set this variable when running on GitHub Actions, unless you want to compare changes against a branch that's not the GitHub repository default branch.                                                                                                                                                                     |
| **DEFAULT_WORKSPACE**                                  | `/tmp/lint`                                                                  | The location containing files to lint if you are running locally. Defaults to `GITHUB_WORKSPACE` when running in GitHub Actions. There's no need to configure this variable when running on GitHub Actions.                                                                                                                                                                 |
| **DISABLE_ERRORS**                                     | `false`                                                                      | Flag to have the linter complete with exit code 0 even if errors were detected.                                                                                                                                                                                                                                                                                             |
| **DOCKERFILE_HADOLINT_FILE_NAME**                      | `.hadolint.yaml`                                                             | Filename for [hadolint configuration](https://github.com/hadolint/hadolint) (ex: `.hadolintlintrc.yaml`)                                                                                                                                                                                                                                                                    |
| **EDITORCONFIG_FILE_NAME**                             | `.editorconfig-checker.json`                                                 | Filename for [editorconfig-checker configuration](https://github.com/editorconfig-checker/editorconfig-checker)                                                                                                                                                                                                                                                             |
| **ENABLE_COMMITLINT_EDIT_MODE**                        | `false`                                                                      | If set to `true` checks the commit message that is currently being edited with Commitlint. This is useful to run Super-linter in a `commit-msg` hook.                                                                                                                                                                                                                       |
| **ENABLE_COMMITLINT_STRICT_MODE**                      | `false`                                                                      | If set to `true`, enables [commitlint strict mode](https://commitlint.js.org/reference/cli.html).                                                                                                                                                                                                                                                                           |
| **ENABLE_GITHUB_ACTIONS_GROUP_TITLE**                  | `false` if `RUN_LOCAL=true`, `true` otherwise                                | Flag to enable [GitHub Actions log grouping](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#grouping-log-lines).                                                                                                                                                                                                                   |
| **ENABLE_GITHUB_PULL_REQUEST_SUMMARY_COMMENT**         | `false` if `RUN_LOCAL=true`, `true` otherwise                                | If set to `true`, Super-linter will post a comment to the pull request that triggered the Super-linter workflow.                                                                                                                                                                                                                                                            |
| **ENABLE_GITHUB_ACTIONS_STEP_SUMMARY**                 | `false` if `RUN_LOCAL=true`, `true` otherwise                                | Flag to enable [GitHub Actions job summary](https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions#adding-a-job-summary) for the Super-linter action. For more information, see [Summary outputs](#summary-outputs).                                                                                                                       |
| **ENFORCE_COMMITLINT_CONFIGURATION_CHECK**             | `false`                                                                      | If set to `true` and `VALIDATE_GIT_COMMITLINT` is set to `true`, Super-linter exits with an error if there's no commitlint configuration file. Otherwise, Super-linter emits a warning and forcefully sets `VALIDATE_GIT_COMMITLINT` to `false`.                                                                                                                            |
| **EXPORT_GITHUB_TOKEN**                                | `false`                                                                      | If set to `true`, exports the `GITHUB_TOKEN` variable so that subprocesses can access it. It's useful when linters and formatters need to authenticate, and support loading credentials from `GITHUB_TOKEN`.                                                                                                                                                                |
| **FAIL_ON_CONFLICTING_TOOLS_ENABLED**                  | `false`                                                                      | If set to `true`, Super-linter will exit with an error if potentially conflicting linters or formatters are enabled.                                                                                                                                                                                                                                                        |
| **FAIL_ON_INVALID_GITHUB_ACTIONS_EVENT_CONFIGURATION** | `false`                                                                      | If set to `true`, Super-linter will exit with an error if the Super-linter configuration is not valid for specific GitHub Actions events.                                                                                                                                                                                                                                   |
| **FILTER_REGEX_EXCLUDE**                               | not set                                                                      | Regular expression defining which files will be excluded from linting (ex: `.*src/test.*`). Not setting this variable means to process all files.                                                                                                                                                                                                                           |
| **FILTER_REGEX_INCLUDE**                               | not set                                                                      | Regular expression defining which files will be processed by linters (ex: `.*src/.*`). Not setting this variable means to process all files. `FILTER_REGEX_INCLUDE` is evaluated before `FILTER_REGEX_EXCLUDE`.                                                                                                                                                             |
| **FIX_ANSIBLE**                                        | `false`                                                                      | Option to enable fix mode for `ANSIBLE`.                                                                                                                                                                                                                                                                                                                                    |
| **FIX_BIOME_FORMAT**                                   | `false`                                                                      | Option to enable fix mode for `BIOME_FORMAT`                                                                                                                                                                                                                                                                                                                                |
| **FIX_BIOME_LINT**                                     | `false`                                                                      | Option to enable fix mode for `BIOME_LINT`                                                                                                                                                                                                                                                                                                                                  |
| **FIX_CLANG_FORMAT**                                   | `false`                                                                      | Option to enable fix mode for `CLANG_FORMAT`.                                                                                                                                                                                                                                                                                                                               |
| **FIX_CSHARP**                                         | `false`                                                                      | Option to enable fix mode for `CSHARP`.                                                                                                                                                                                                                                                                                                                                     |
| **FIX_CSS_PRETTIER**                                   | `false`                                                                      | Flag to enable or disable the formatting of CSS, Sass, and SCSS files with Prettier.                                                                                                                                                                                                                                                                                        |
| **FIX_CSS**                                            | `false`                                                                      | Option to enable fix mode for `CSS`.                                                                                                                                                                                                                                                                                                                                        |
| **FIX_DOTNET_SLN_FORMAT_ANALYZERS**                    | `false`                                                                      | Option to enable or disable fix mode for Dotnet solutions.                                                                                                                                                                                                                                                                                                                  |
| **FIX_DOTNET_SLN_FORMAT_STYLE**                        | `false`                                                                      | Option to enable or disable fix mode for Dotnet solutions.                                                                                                                                                                                                                                                                                                                  |
| **FIX_DOTNET_SLN_FORMAT_WHITESPACE**                   | `false`                                                                      | Option to enable or disable fix mode for Dotnet solutions.                                                                                                                                                                                                                                                                                                                  |
| **FIX_ENV**                                            | `false`                                                                      | Option to enable fix mode for `ENV`.                                                                                                                                                                                                                                                                                                                                        |
| **FIX_GITHUB_ACTIONS_ZIZMOR**                          | `false`                                                                      | Option to enable fix mode for `GITHUB_ACTIONS_ZIZMOR`.                                                                                                                                                                                                                                                                                                                      |
| **FIX_GO_MODULES**                                     | `false`                                                                      | Option to enable fix mode for `GO_MODULES`.                                                                                                                                                                                                                                                                                                                                 |
| **FIX_GO**                                             | `false`                                                                      | Option to enable fix mode for `GO`.                                                                                                                                                                                                                                                                                                                                         |
| **FIX_GOOGLE_JAVA_FORMAT**                             | `false`                                                                      | Option to enable fix mode for `GOOGLE_JAVA_FORMAT`.                                                                                                                                                                                                                                                                                                                         |
| **FIX_GRAPHQL_PRETTIER**                               | `false`                                                                      | Flag to enable or disable the formatting of GraphQL files with Prettier.                                                                                                                                                                                                                                                                                                    |
| **FIX_GROOVY**                                         | `false`                                                                      | Option to enable fix mode for `GROOVY`.                                                                                                                                                                                                                                                                                                                                     |
| **FIX_HTML_PRETTIER**                                  | `false`                                                                      | Flag to enable or disable the formatting of HTML files with Prettier.                                                                                                                                                                                                                                                                                                       |
| **FIX_JAVASCRIPT_ES**                                  | `false`                                                                      | Option to enable fix mode for `JAVASCRIPT_ES`.                                                                                                                                                                                                                                                                                                                              |
| **FIX_JAVASCRIPT_PRETTIER**                            | `false`                                                                      | Flag to enable or disable the formatting of JavaScript files with Prettier.                                                                                                                                                                                                                                                                                                 |
| **FIX_JSON_PRETTIER**                                  | `false`                                                                      | Flag to enable or disable the formatting of JSON files with Prettier.                                                                                                                                                                                                                                                                                                       |
| **FIX_JSON**                                           | `false`                                                                      | Option to enable fix mode for `JSON`.                                                                                                                                                                                                                                                                                                                                       |
| **FIX_JSONC**                                          | `false`                                                                      | Option to enable fix mode for `JSONC`.                                                                                                                                                                                                                                                                                                                                      |
| **FIX_JSONC_PRETTIER**                                 | `false`                                                                      | Option to enable fix mode for JSONC and JSON5 files with Prettier.                                                                                                                                                                                                                                                                                                          |
| **FIX_JSX_PRETTIER**                                   | `false`                                                                      | Option to enable fix mode for JSX files with Prettier.                                                                                                                                                                                                                                                                                                                      |
| **FIX_JSX**                                            | `false`                                                                      | Option to enable fix mode for `JSX`.                                                                                                                                                                                                                                                                                                                                        |
| **FIX_JUPYTER_NBQA_BLACK**                             | `false`                                                                      | Option to enable fix mode for `NBQA_BLACK`.                                                                                                                                                                                                                                                                                                                                 |
| **FIX_JUPYTER_NBQA_ISORT**                             | `false`                                                                      | Option to enable fix mode for `NBQA_ISORT`.                                                                                                                                                                                                                                                                                                                                 |
| **FIX_JUPYTER_NBQA_RUFF**                              | `false`                                                                      | Option to enable fix mode for `NBQA_RUFF`.                                                                                                                                                                                                                                                                                                                                  |
| **FIX_KOTLIN**                                         | `false`                                                                      | Option to enable fix mode for `KOTLIN`.                                                                                                                                                                                                                                                                                                                                     |
| **FIX_MARKDOWN_PRETTIER**                              | `false`                                                                      | Option to enable fix mode for Markdown files with Prettier.                                                                                                                                                                                                                                                                                                                 |
| **FIX_MARKDOWN**                                       | `false`                                                                      | Option to enable fix mode for `MARKDOWN`.                                                                                                                                                                                                                                                                                                                                   |
| **FIX_NATURAL_LANGUAGE**                               | `false`                                                                      | Option to enable fix mode for `NATURAL_LANGUAGE`.                                                                                                                                                                                                                                                                                                                           |
| **FIX_POWERSHELL**                                     | `false`                                                                      | Option to enable fix mode for `POWERSHELL`.                                                                                                                                                                                                                                                                                                                                 |
| **FIX_PROTOBUF**                                       | `false`                                                                      | Option to enable fix mode for `PROTOBUF`.                                                                                                                                                                                                                                                                                                                                   |
| **FIX_PYTHON_BLACK**                                   | `false`                                                                      | Option to enable fix mode for `PYTHON_BLACK`.                                                                                                                                                                                                                                                                                                                               |
| **FIX_PYTHON_ISORT**                                   | `false`                                                                      | Option to enable fix mode for `PYTHON_ISORT`.                                                                                                                                                                                                                                                                                                                               |
| **FIX_PYTHON_RUFF**                                    | `false`                                                                      | Option to enable fix mode for `PYTHON_RUFF`.                                                                                                                                                                                                                                                                                                                                |
| **FIX_PYTHON_RUFF_FORMAT**                             | `false`                                                                      | Option to enable fix mode for `PYTHON_RUFF_FORMAT`.                                                                                                                                                                                                                                                                                                                         |
| **FIX_RUBY**                                           | `false`                                                                      | Option to enable fix mode for `RUBY`.                                                                                                                                                                                                                                                                                                                                       |
| **FIX_RUST_2015**                                      | `false`                                                                      | Option to enable fix mode for `RUST_2015`.                                                                                                                                                                                                                                                                                                                                  |
| **FIX_RUST_2018**                                      | `false`                                                                      | Option to enable fix mode for `RUST_2018`.                                                                                                                                                                                                                                                                                                                                  |
| **FIX_RUST_2021**                                      | `false`                                                                      | Option to enable fix mode for `RUST_2021`.                                                                                                                                                                                                                                                                                                                                  |
| **FIX_RUST_2024**                                      | `false`                                                                      | Option to enable fix mode for `RUST_2024`.                                                                                                                                                                                                                                                                                                                                  |
| **FIX_RUST_CLIPPY**                                    | `false`                                                                      | Option to enable fix mode for `RUST_CLIPPY`. When `FIX_RUST_CLIPPY` is `true`, Clippy is allowed to fix issues in the workspace even if there are unstaged and staged changes in the workspace.                                                                                                                                                                             |
| **FIX_SCALAFMT**                                       | `false`                                                                      | Option to enable fix mode for `SCALAFMT`.                                                                                                                                                                                                                                                                                                                                   |
| **FIX_SHELL_SHFMT**                                    | `false`                                                                      | Option to enable fix mode for `SHELL_SHFMT`.                                                                                                                                                                                                                                                                                                                                |
| **FIX_SNAKEMAKE_SNAKEFMT**                             | `false`                                                                      | Option to enable fix mode for `SNAKEMAKE_SNAKEFMT`.                                                                                                                                                                                                                                                                                                                         |
| **FIX_SPELL_CODESPELL**                                | `false`                                                                      | Option to enable fix mode for `SPELL_CODESPELL`.                                                                                                                                                                                                                                                                                                                            |
| **FIX_SQLFLUFF**                                       | `false`                                                                      | Option to enable fix mode for `SQLFLUFF`.                                                                                                                                                                                                                                                                                                                                   |
| **FIX_TERRAFORM_FMT**                                  | `false`                                                                      | Option to enable fix mode for `TERRAFORM_FMT`.                                                                                                                                                                                                                                                                                                                              |
| **FIX_TSX**                                            | `false`                                                                      | Option to enable fix mode for `TSX`.                                                                                                                                                                                                                                                                                                                                        |
| **FIX_TYPESCRIPT_ES**                                  | `false`                                                                      | Option to enable fix mode for `TYPESCRIPT_ES`.                                                                                                                                                                                                                                                                                                                              |
| **FIX_TYPESCRIPT_PRETTIER**                            | `false`                                                                      | Flag to enable or disable the formatting of TypeScript files with Prettier.                                                                                                                                                                                                                                                                                                 |
| **FIX_VUE**                                            | `false`                                                                      | Option to enable fix mode for VUE.                                                                                                                                                                                                                                                                                                                                          |
| **FIX_VUE_PRETTIER**                                   | `false`                                                                      | Flag to enable or disable the formatting of Vue files with Prettier.                                                                                                                                                                                                                                                                                                        |
| **FIX_YAML_PRETTIER**                                  | `false`                                                                      | Flag to enable or disable the formatting of YAML files with Prettier.                                                                                                                                                                                                                                                                                                       |
| **GITHUB_ACTIONS_CONFIG_FILE**                         | `actionlint.yml`                                                             | Filename for [Actionlint configuration](https://github.com/rhysd/actionlint/blob/main/docs/config.md) (ex: `actionlint.yml`)                                                                                                                                                                                                                                                |
| **GITHUB_ACTIONS_COMMAND_ARGS**                        | `null`                                                                       | Additional arguments passed to `actionlint` command. Useful to [ignore some errors](https://github.com/rhysd/actionlint/blob/main/docs/usage.md#ignore-some-errors)                                                                                                                                                                                                         |
| **GITHUB_ACTIONS_ZIZMOR_CONFIG_FILE**                  | `zizmor.yaml`                                                                | Filename for [zizmor configuration file](https://docs.zizmor.sh/configuration/)                                                                                                                                                                                                                                                                                             |
| **GITHUB_CUSTOM_API_URL**                              | `https://api.${GITHUB_DOMAIN}`                                               | Specify a custom GitHub API URL in case GitHub Enterprise is used: e.g. `https://github.myenterprise.com/api/v3`                                                                                                                                                                                                                                                            |
| **GITHUB_CUSTOM_SERVER_URL**                           | `https://${GITHUB_DOMAIN}"`                                                  | Specify a custom GitHub server URL. Useful for GitHub Enterprise instances.                                                                                                                                                                                                                                                                                                 |
| **GITHUB_DOMAIN**                                      | `github.com`                                                                 | Specify a custom GitHub domain in case GitHub Enterprise is used: e.g. `github.myenterprise.com`. `GITHUB_DOMAIN` is a convenience configuration variable to automatically build `GITHUB_CUSTOM_API_URL` and `GITHUB_CUSTOM_SERVER_URL`.                                                                                                                                    |
| **GITLEAKS_COMMAND_OPTIONS**                           | not set                                                                      | Additional options and arguments to pass to the command when running Gitleaks                                                                                                                                                                                                                                                                                               |
| **GITLEAKS_CONFIG_FILE**                               | `.gitleaks.toml`                                                             | Filename for [GitLeaks configuration](https://github.com/zricethezav/gitleaks#configuration) (ex: `.gitleaks.toml`)                                                                                                                                                                                                                                                         |
| **GITLEAKS_LOG_LEVEL**                                 | Gitleaks default log level                                                   | Gitleaks log level. Defaults to the Gitleaks default log level.                                                                                                                                                                                                                                                                                                             |
| **GO_CONFIG_FILE**                                     | `.golangci.yml`                                                              | Filename for [golangci-lint configuration](https://golangci-lint.run/usage/configuration/) (ex: `.golangci.toml`)                                                                                                                                                                                                                                                           |
| **GROOVY_FAILON_LEVEL**                                | `warning`                                                                    | npm-groovy-lint failon level.                                                                                                                                                                                                                                                                                                                                               |
| **GROOVY_LOG_LEVEL**                                   | `info`                                                                       | npm-groovy-lint log level.                                                                                                                                                                                                                                                                                                                                                  |
| **IGNORE_GENERATED_FILES**                             | `false`                                                                      | If set to `true`, super-linter will ignore all the files with `@generated` marker but without `@not-generated` marker.                                                                                                                                                                                                                                                      |
| **IGNORE_GITIGNORED_FILES**                            | `false`                                                                      | If set to `true`, super-linter will ignore all the files that are ignored by Git.                                                                                                                                                                                                                                                                                           |
| **JAVA_COMMAND_ARGS**                                  | not set                                                                      | Additional command options to pass to Checkstyle. For more information about the available options, see [checkstyle command line usage](https://checkstyle.org/cmdline.html#Command_line_usage).                                                                                                                                                                            |
| **JAVA_JVM_COMMAND_ARGS**                              | not set                                                                      | Additional command options to pass to the Java Virtual Machine (JVM) when running Checkstyle. For example, can be used to specify additional configuration parameters via Java properties, such as [Suppression Filter files](https://checkstyle.org/filters/suppressionfilter.html), for example: `-Dorg.checkstyle.sun.suppressionfilter.config=path/to/suppressions.xml` |
| **JAVA_FILE_NAME**                                     | `sun_checks.xml`                                                             | Filename for [Checkstyle configuration](https://checkstyle.sourceforge.io/config.html). Checkstyle embeds several configuration files, such as `sun_checks.xml`, `google_checks.xml` that you can use without providing your own configuration file.                                                                                                                        |
| **JAVASCRIPT_ES_CONFIG_FILE**                          | `eslint.config.mjs`                                                          | Filename for [ESLint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats)                                                                                                                                                                                                                                                              |
| **JSCPD_CONFIG_FILE**                                  | `.jscpd.json`                                                                | Filename for JSCPD configuration                                                                                                                                                                                                                                                                                                                                            |
| **JUPYTER_NBQA_BLACK_CONFIG_FILE**                     | Value of **PYTHON_BLACK_CONFIG_FILE** or `.python-black`                     | Filename for [black configuration](https://github.com/psf/black/blob/main/docs/guides/using_black_with_other_tools.md#black-compatible-configurations) (ex: `.isort.cfg`, `pyproject.toml`)                                                                                                                                                                                 |
| **JUPYTER_NBQA_FLAKE8_CONFIG_FILE**                    | Value of **PYTHON_FLAKE8_CONFIG_FILE** or `.flake8`                          | Filename for [flake8 configuration](https://flake8.pycqa.org/en/latest/user/configuration.html) (ex: `.flake8`, `tox.ini`)                                                                                                                                                                                                                                                  |
| **JUPYTER_NBQA_ISORT_CONFIG_FILE**                     | Value of **PYTHON_ISORT_CONFIG_FILE** or `.isort.cfg`                        | Filename for [isort configuration](https://pycqa.github.io/isort/docs/configuration/config_files.html) (ex: `.isort.cfg`, `pyproject.toml`)                                                                                                                                                                                                                                 |
| **JUPYTER_NBQA_MYPY_CONFIG_FILE**                      | Value of **PYTHON_MYPY_CONFIG_FILE** or `.mypy.ini`                          | Filename for [mypy configuration](https://mypy.readthedocs.io/en/stable/config_file.html) (ex: `.mypy.ini`, `setup.config`)                                                                                                                                                                                                                                                 |
| **JUPYTER_NBQA_PYLINT_CONFIG_FILE**                    | Value of **PYTHON_PYLINT_CONFIG_FILE** or `.python-lint`                     | Filename for [pylint configuration](https://pylint.pycqa.org/en/latest/user_guide/run.html?highlight=rcfile#command-line-options) (ex: `.python-lint`, `.pylintrc`)                                                                                                                                                                                                         |
| **JUPYTER_NBQA_RUFF_CONFIG_FILE**                      | Value of **PYTHON_RUFF_CONFIG_FILE** or `.ruff.toml`                         | Filename for [ruff configuration](https://docs.astral.sh/ruff/configuration/) when linting files.                                                                                                                                                                                                                                                                           |
| **KUBERNETES_KUBECONFORM_OPTIONS**                     | not set                                                                      | Additional arguments to pass to the command-line when running Kubeconform (Example: `--ignore-missing-schemas`)                                                                                                                                                                                                                                                             |
| **LINTER_RULES_PATH**                                  | `.github/linters`                                                            | Directory for all linter configuration rules. For more information, see [Configure Linters](#configure-linters).                                                                                                                                                                                                                                                            |
| **LOG_FILE**                                           | `super-linter.log`                                                           | The filename for outputting logs. Super-linter saves the log file to `${DEFAULT_WORKSPACE}/${LOG_FILE}`.                                                                                                                                                                                                                                                                    |
| **LOG_LEVEL**                                          | `INFO`                                                                       | How much output the script will generate to the console. One of `ERROR`, `WARN`, `NOTICE`, `INFO`, or `DEBUG`.                                                                                                                                                                                                                                                              |
| **MARKDOWN_CONFIG_FILE**                               | `.markdown-lint.yml`                                                         | Filename for [Markdownlint configuration](https://github.com/DavidAnson/markdownlint#optionsconfig) (ex: `.markdown-lint.yml`, `.markdownlint.json`, `.markdownlint.yaml`)                                                                                                                                                                                                  |
| **MARKDOWN_CUSTOM_RULE_GLOBS**                         | not set                                                                      | Comma-separated list of [file globs](https://github.com/igorshubovych/markdownlint-cli#globbing) matching [custom Markdownlint rule files](https://github.com/DavidAnson/markdownlint/blob/main/doc/CustomRules.md).                                                                                                                                                        |
| **MULTI_STATUS**                                       | `true`                                                                       | A status API is made for each language that is linted to make visual parsing easier.                                                                                                                                                                                                                                                                                        |
| **NATURAL_LANGUAGE_CONFIG_FILE**                       | `.textlintrc`                                                                | Filename for [textlint configuration](https://textlint.github.io/docs/getting-started.html#configuration) (ex: `.textlintrc`)                                                                                                                                                                                                                                               |
| **OS_PACKAGES_CONFIG_FILE_NAME**                       | `os-packages.json`                                                           | Name of the file that holds the list of operating system (OS) packages to install, in JSON format. Relative to `LINTER_RULES_PATH`. For more information, see [Install additional dependencies](#install-additional-dependencies).                                                                                                                                          |
| **PERL_PERLCRITIC_OPTIONS**                            | `null`                                                                       | Additional arguments to pass to the command-line when running **perlcritic** (Example: --theme community)                                                                                                                                                                                                                                                                   |
| **POWERSHELL_CONFIG_FILE**                             | `.powershell-psscriptanalyzer.psd1`                                          | Filename for [PSScriptAnalyzer configuration](https://learn.microsoft.com/en-gb/powershell/utility-modules/psscriptanalyzer/using-scriptanalyzer)                                                                                                                                                                                                                           |
| **PHP_CONFIG_FILE**                                    | `php.ini`                                                                    | Filename for [PHP Configuration](https://www.php.net/manual/en/configuration.file.php) (ex: `php.ini`)                                                                                                                                                                                                                                                                      |
| **PHP_PHPCS_FILE_NAME**                                | `phpcs.xml`                                                                  | Filename for [PHP CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) (ex: `.phpcs.xml`, `.phpcs.xml.dist`)                                                                                                                                                                                                                                                          |
| **PHP_PHPSTAN_CONFIG_FILE**                            | `phpstan.neon`                                                               | Filename for [PHPStan Configuration](https://phpstan.org/config-reference) (ex: `phpstan.neon`)                                                                                                                                                                                                                                                                             |
| **PRETTIER_COMMAND_OPTIONS**                           | not set                                                                      | Additional options and arguments to add to the command when running Prettier. These options will be added to all Prettier invocations, regardless of the LANGUAGE.                                                                                                                                                                                                          |
| **PRE_COMMIT_COMMAND_ARGS**                            | not set                                                                      | Additional arguments to pass to the `pre-commit` command.                                                                                                                                                                                                                                                                                                                   |
| **PRE_COMMIT_CONFIG_FILE**                             | `.pre-commit-config.yaml`                                                    | Filename for [pre-commit configuration](https://pre-commit.com/#plugins)                                                                                                                                                                                                                                                                                                    |
| **PROTOBUF_CONFIG_FILE**                               | `.protolintrc.yml`                                                           | Filename for [protolint configuration](https://github.com/yoheimuta/protolint/blob/master/_example/config/.protolint.yaml) (ex: `.protolintrc.yml`)                                                                                                                                                                                                                         |
| **PYTHON_BLACK_CONFIG_FILE**                           | `.python-black`                                                              | Filename for [black configuration](https://github.com/psf/black/blob/main/docs/guides/using_black_with_other_tools.md#black-compatible-configurations) (ex: `.isort.cfg`, `pyproject.toml`)                                                                                                                                                                                 |
| **PYTHON_FLAKE8_CONFIG_FILE**                          | `.flake8`                                                                    | Filename for [flake8 configuration](https://flake8.pycqa.org/en/latest/user/configuration.html) (ex: `.flake8`, `tox.ini`)                                                                                                                                                                                                                                                  |
| **PYTHON_ISORT_CONFIG_FILE**                           | `.isort.cfg`                                                                 | Filename for [isort configuration](https://pycqa.github.io/isort/docs/configuration/config_files.html) (ex: `.isort.cfg`, `pyproject.toml`)                                                                                                                                                                                                                                 |
| **PYTHON_MYPY_CONFIG_FILE**                            | `.mypy.ini`                                                                  | Filename for [mypy configuration](https://mypy.readthedocs.io/en/stable/config_file.html) (ex: `.mypy.ini`, `setup.config`)                                                                                                                                                                                                                                                 |
| **PYTHON_PYLINT_CONFIG_FILE**                          | `.python-lint`                                                               | Filename for [pylint configuration](https://pylint.pycqa.org/en/latest/user_guide/run.html?highlight=rcfile#command-line-options) (ex: `.python-lint`, `.pylintrc`)                                                                                                                                                                                                         |
| **PYTHON_RUFF_CONFIG_FILE**                            | `.ruff.toml`                                                                 | Filename for [ruff configuration](https://docs.astral.sh/ruff/configuration/) when linting files.                                                                                                                                                                                                                                                                           |
| **PYTHON_RUFF_FORMAT_CONFIG_FILE**                     | `.ruff.toml`                                                                 | Filename for [ruff configuration](https://docs.astral.sh/ruff/configuration/) when formatting files.                                                                                                                                                                                                                                                                        |
| **RENOVATE_SHAREABLE_CONFIG_PRESET_FILE_NAMES**        | not set                                                                      | Comma-separated filenames for [renovate shareable config preset](https://docs.renovatebot.com/config-presets/) (ex: `default.json`)                                                                                                                                                                                                                                         |
| **REMOVE_ANSI_COLOR_CODES_FROM_OUTPUT**                | `false`                                                                      | If set to `true`, Super-linter removes ANSI color codes from linters stdout and stderr files, and from the Super-linter log file.                                                                                                                                                                                                                                           |
| **RUBY_CONFIG_FILE**                                   | `.ruby-lint.yml`                                                             | Filename for [rubocop configuration](https://docs.rubocop.org/rubocop/configuration.html) (ex: `.ruby-lint.yml`, `.rubocop.yml`)                                                                                                                                                                                                                                            |
| **RUN_LOCAL**                                          | `false`                                                                      | Set this to `true` when running outside GitHub Actions or when you want to disable getting environment information from the GitHub Actions environment. For more information about running Super-linter outside GitHub Actions, see [Run Super-Linter outside GitHub Actions](#run-super-linter-outside-github-actions).                                                    |
| **RUST_CLIPPY_COMMAND_OPTIONS**                        | not set                                                                      | Additional options and arguments to add to the command when running Clippy.                                                                                                                                                                                                                                                                                                 |
| **SAVE_SUPER_LINTER_OUTPUT**                           | `false`                                                                      | If set to `true`, Super-linter will save its output in the workspace. For more information, see [Super-linter outputs](#super-linter-outputs).                                                                                                                                                                                                                              |
| **SAVE_SUPER_LINTER_SUMMARY**                          | `false`                                                                      | If set to `true`, Super-linter will save a summary. For more information, see [Summary outputs](#summary-outputs).                                                                                                                                                                                                                                                          |
| **SCALAFMT_CONFIG_FILE**                               | `.scalafmt.conf`                                                             | Filename for [scalafmt configuration](https://scalameta.org/scalafmt/docs/configuration.html) (ex: `.scalafmt.conf`)                                                                                                                                                                                                                                                        |
| **SNAKEMAKE_SNAKEFMT_CONFIG_FILE**                     | `.snakefmt.toml`                                                             | Filename for [Snakemake configuration](https://github.com/snakemake/snakefmt#configuration) (ex: `pyproject.toml`, `.snakefmt.toml`)                                                                                                                                                                                                                                        |
| **SPELL_CODESPELL_CONFIG_FILE**                        | `.codespellrc`                                                               | Filename for codespell configuration                                                                                                                                                                                                                                                                                                                                        |
| **SSL_CERT_SECRET**                                    | `none`                                                                       | Certification Authority (CA) cert to add to the **Super-Linter** trust store. This is needed for users on `self-hosted` runners or need to inject the certificate (ex. ${{ secrets.SSL_CERT }})                                                                                                                                                                             |
| **SSH_KEY**                                            | `none`                                                                       | SSH key that has access to your private repositories                                                                                                                                                                                                                                                                                                                        |
| **SSH_SETUP_GITHUB**                                   | `false`                                                                      | If set to `true`, adds the `github.com` SSH key to `known_hosts`. This is ignored if `SSH_KEY` is provided - i.e. the `github.com` SSH key is always added if `SSH_KEY` is provided                                                                                                                                                                                         |
| **SSH_INSECURE_NO_VERIFY_GITHUB_KEY**                  | `false`                                                                      | **INSECURE -** If set to `true`, does not verify the fingerprint of the github.com SSH key before adding this. This is not recommended!                                                                                                                                                                                                                                     |
| **SQLFLUFF_CONFIG_FILE**                               | `/.sqlfluff`                                                                 | Filename for [SQLFLUFF configuration](https://docs.sqlfluff.com/en/stable/configuration/index.html) (ex: `/.sqlfluff`, `pyproject.toml`)                                                                                                                                                                                                                                    |
| **STRIP_DEFAULT_WORKSPACE_FOR_REGEX**                  | `false`                                                                      | Set this to `true` to strip the value of `DEFAULT_WORKSPACE` from the list of files to check. For more information, see [Include or exclude files from checks](#include-or-exclude-files-from-checks).                                                                                                                                                                      |
| **SUPER_LINTER_OUTPUT_DIRECTORY_NAME**                 | `super-linter-output`                                                        | Name of the directory where super-linter saves its output.                                                                                                                                                                                                                                                                                                                  |
| **SUPER_LINTER_SUMMARY_FILE_NAME**                     | `super-linter-summary.md`                                                    | Name of the file where to save the summary output. For more information, see [Summary outputs](#summary-outputs).                                                                                                                                                                                                                                                           |
| **SUPPRESS_FILE_TYPE_WARN**                            | `false`                                                                      | If set to `true`, will hide warning messages about files without their proper extensions. Default is `false`                                                                                                                                                                                                                                                                |
| **SUPPRESS_OUTPUT_ON_SUCCESS**                         | `false`                                                                      | If set to `true`, Super-linter will emit logs (and GitHub Actions log groups) only for linters and formatters that returned errors.                                                                                                                                                                                                                                         |
| **SUPPRESS_POSSUM**                                    | `false`                                                                      | If set to `true`, will hide the ASCII possum at top of log output. Default is `false`                                                                                                                                                                                                                                                                                       |
| **TERRAFORM_TFLINT_CONFIG_FILE**                       | `.tflint.hcl`                                                                | Filename for [tfLint configuration](https://github.com/terraform-linters/tflint) (ex: `.tflint.hcl`)                                                                                                                                                                                                                                                                        |
| **TRIVY_CONFIG_FILE**                                  | `trivy.yaml`                                                                 | Filename for [Trivy](https://trivy.dev/latest/docs/references/configuration/config-file/)                                                                                                                                                                                                                                                                                   |
| **TYPESCRIPT_ES_CONFIG_FILE**                          | `eslint.config.mjs`                                                          | Filename for [ESLint configuration](https://eslint.org/docs/user-guide/configuring#configuration-file-formats)                                                                                                                                                                                                                                                              |
| **USE_FIND_ALGORITHM**                                 | `false`                                                                      | Set this to `true` to make Super-linter scan the filesystem to get the list of files to check instead of relying on Git.                                                                                                                                                                                                                                                    |
| **VALIDATE_ALL_CODEBASE**                              | `true`                                                                       | Set this to `true` to lint and format the entire workspace. Set this to`false` to lint and format **new** or **changed** files only. For more information, see [VALIDATE_ALL_CODEBASE](#validate_all_codebase).                                                                                                                                                             |
| **VALIDATE_ANSIBLE**                                   | `true`                                                                       | Flag to enable or disable the linting process of the Ansible language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_ARM**                                       | `true`                                                                       | Flag to enable or disable the linting process of the ARM language.                                                                                                                                                                                                                                                                                                          |
| **VALIDATE_BASH**                                      | `true`                                                                       | Flag to enable or disable the linting process of the Bash language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_BASH_EXEC**                                 | `true`                                                                       | Flag to enable or disable the linting process of the Bash language to validate if file is stored as executable.                                                                                                                                                                                                                                                             |
| **VALIDATE_BIOME_FORMAT**                              | `true`                                                                       | Option to enable or disable the linting process with `biome format`.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_BIOME_LINT**                                | `true`                                                                       | Option to enable or disable the linting process with `biome lint`                                                                                                                                                                                                                                                                                                           |
| **VALIDATE_CPP**                                       | `true`                                                                       | Flag to enable or disable the linting process of the C++ language.                                                                                                                                                                                                                                                                                                          |
| **VALIDATE_CHECKOV**                                   | `true`                                                                       | Flag to enable or disable the linting process with Checkov                                                                                                                                                                                                                                                                                                                  |
| **VALIDATE_CLANG_FORMAT**                              | `true`                                                                       | Flag to enable or disable the linting process of the C++/C language with clang-format.                                                                                                                                                                                                                                                                                      |
| **VALIDATE_CLOJURE**                                   | `true`                                                                       | Flag to enable or disable the linting process of the Clojure language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_CLOUDFORMATION**                            | `true`                                                                       | Flag to enable or disable the linting process of the AWS Cloud Formation language.                                                                                                                                                                                                                                                                                          |
| **VALIDATE_COFFEESCRIPT**                              | `true`                                                                       | Flag to enable or disable the linting process of the CoffeeScript language.                                                                                                                                                                                                                                                                                                 |
| **VALIDATE_CSHARP**                                    | `true`                                                                       | Flag to enable or disable the linting process of the C# language.                                                                                                                                                                                                                                                                                                           |
| **VALIDATE_CSS**                                       | `true`                                                                       | Flag to enable or disable the linting process of the CSS, Sass, and SCSS files.                                                                                                                                                                                                                                                                                             |
| **VALIDATE_CSS_PRETTIER**                              | `true`                                                                       | Flag to enable or disable checking the formatting of CSS, Sass, and SCSS files with Prettier.                                                                                                                                                                                                                                                                               |
| **VALIDATE_DART**                                      | `true`                                                                       | Flag to enable or disable the linting process of the Dart language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_DOCKERFILE_HADOLINT**                       | `true`                                                                       | Flag to enable or disable the linting process of the Docker language.                                                                                                                                                                                                                                                                                                       |
| **VALIDATE_DOTNET_SLN_FORMAT_ANALYZERS**               | `true`                                                                       | Option to enable or disable the linting process of Dotnet solutions.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_DOTNET_SLN_FORMAT_STYLE**                   | `true`                                                                       | Option to enable or disable the linting process of Dotnet solutions.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_DOTNET_SLN_FORMAT_WHITESPACE**              | `true`                                                                       | Option to enable or disable the linting process of Dotnet solutions.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_EDITORCONFIG**                              | `true`                                                                       | Flag to enable or disable the linting process with the EditorConfig.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_ENV**                                       | `true`                                                                       | Flag to enable or disable the linting process of the ENV language.                                                                                                                                                                                                                                                                                                          |
| **VALIDATE_GIT_COMMITLINT**                            | `true`                                                                       | Option to enable or disable the linting process of Git commits with commitlint. commitlint needs a configuration file to work. Also, see the `ENFORCE_COMMITLINT_CONFIGURATION_CHECK` and the `ENABLE_COMMITLINT_STRICT_MODE` variables.                                                                                                                                    |
| **VALIDATE_GIT_MERGE_CONFLICT_MARKERS**                | `true`                                                                       | Option to enable or disable checking if files contain Git merge conflict markers.                                                                                                                                                                                                                                                                                           |
| **VALIDATE_GITHUB_ACTIONS**                            | `true`                                                                       | Flag to enable or disable the linting process of the GitHub Actions.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_GITHUB_ACTIONS_ZIZMOR**                     | `true`                                                                       | Flag to enable or disable the linting process of GitHub Actions, Dependabot, GitHub Actions workflows configuration files using zizmor.                                                                                                                                                                                                                                     |
| **VALIDATE_GITLEAKS**                                  | `true`                                                                       | Flag to enable or disable the linting process of the secrets.                                                                                                                                                                                                                                                                                                               |
| **VALIDATE_GO**                                        | `true`                                                                       | Flag to enable or disable the linting process of the individual Go files. Set this to `false` if you want to lint Go modules. See the `VALIDATE_GO_MODULES` variable.                                                                                                                                                                                                       |
| **VALIDATE_GO_MODULES**                                | `true`                                                                       | Flag to enable or disable the linting process of Go modules. Super-linter considers a directory to be a Go module if it contains a file named`go.mod`.                                                                                                                                                                                                                      |
| **VALIDATE_GO_RELEASER**                               | `true`                                                                       | Flag to enable or disable the linting process of the GoReleaser config file.                                                                                                                                                                                                                                                                                                |
| **VALIDATE_GRAPHQL_PRETTIER**                          | `true`                                                                       | Flag to enable or disable checking the formatting of GraphQL files with Prettier.                                                                                                                                                                                                                                                                                           |
| **VALIDATE_GOOGLE_JAVA_FORMAT**                        | `true`                                                                       | Flag to enable or disable the linting process of the Java language. (Utilizing: google-java-format)                                                                                                                                                                                                                                                                         |
| **VALIDATE_GROOVY**                                    | `true`                                                                       | Flag to enable or disable the linting process of the language.                                                                                                                                                                                                                                                                                                              |
| **VALIDATE_HTML**                                      | `true`                                                                       | Flag to enable or disable the linting process of the HTML language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_HTML_PRETTIER**                             | `true`                                                                       | Flag to enable or disable checking the formatting of HTML files with Prettier.                                                                                                                                                                                                                                                                                              |
| **VALIDATE_JAVA**                                      | `true`                                                                       | Flag to enable or disable the linting process of the Java language. (Utilizing: checkstyle)                                                                                                                                                                                                                                                                                 |
| **VALIDATE_JAVASCRIPT_ES**                             | `true`                                                                       | Flag to enable or disable the linting process of the JavaScript language. (Utilizing: ESLint)                                                                                                                                                                                                                                                                               |
| **VALIDATE_JAVASCRIPT_PRETTIER**                       | `true`                                                                       | Flag to enable or disable checking the formatting of JavaScript files with Prettier.                                                                                                                                                                                                                                                                                        |
| **VALIDATE_JSCPD**                                     | `true`                                                                       | Flag to enable or disable JSCPD.                                                                                                                                                                                                                                                                                                                                            |
| **VALIDATE_JSON**                                      | `true`                                                                       | Flag to enable or disable the linting process of the JSON language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_JSON_PRETTIER**                             | `true`                                                                       | Flag to enable or disable checking the formatting of JSON files with Prettier.                                                                                                                                                                                                                                                                                              |
| **VALIDATE_JSONC**                                     | `true`                                                                       | Flag to enable or disable the linting process of the JSONC and JSON5 languages.                                                                                                                                                                                                                                                                                             |
| **VALIDATE_JSONC_PRETTIER**                            | `true`                                                                       | Flag to enable or disable checking the formatting of JSONC and JSON5 files with Prettier.                                                                                                                                                                                                                                                                                   |
| **VALIDATE_JSX**                                       | `true`                                                                       | Flag to enable or disable the linting process for jsx files (Utilizing: ESLint)                                                                                                                                                                                                                                                                                             |
| **VALIDATE_JSX_PRETTIER**                              | `true`                                                                       | Flag to enable or disable checking the formatting of JSX files with Prettier.                                                                                                                                                                                                                                                                                               |
| **VALIDATE_JUPYTER_NBQA_BLACK**                        | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa black)                                                                                                                                                                                                                                                                                 |
| **VALIDATE_JUPYTER_NBQA_FLAKE8**                       | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa flake8)                                                                                                                                                                                                                                                                                |
| **VALIDATE_JUPYTER_NBQA_ISORT**                        | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa isort)                                                                                                                                                                                                                                                                                 |
| **VALIDATE_JUPYTER_NBQA_MYPY**                         | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa mypy)                                                                                                                                                                                                                                                                                  |
| **VALIDATE_JUPYTER_NBQA_PYLINT**                       | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa pylint)                                                                                                                                                                                                                                                                                |
| **VALIDATE_JUPYTER_NBQA_RUFF**                         | `true`                                                                       | Flag to enable or disable the linting process of Jupyter Notebooks. (Utilizing: nbqa ruff)                                                                                                                                                                                                                                                                                  |
| **VALIDATE_KOTLIN**                                    | `true`                                                                       | Flag to enable or disable the linting process of the Kotlin language.                                                                                                                                                                                                                                                                                                       |
| **VALIDATE_KUBERNETES_KUBECONFORM**                    | `true`                                                                       | Flag to enable or disable linting Kubernetes files using Kubeconform.                                                                                                                                                                                                                                                                                                       |
| **VALIDATE_LATEX**                                     | `true`                                                                       | Flag to enable or disable the linting process of the LaTeX language.                                                                                                                                                                                                                                                                                                        |
| **VALIDATE_LUA**                                       | `true`                                                                       | Flag to enable or disable the linting process of the language.                                                                                                                                                                                                                                                                                                              |
| **VALIDATE_MARKDOWN**                                  | `true`                                                                       | Flag to enable or disable the linting process of the Markdown language.                                                                                                                                                                                                                                                                                                     |
| **VALIDATE_MARKDOWN_PRETTIER**                         | `true`                                                                       | Flag to enable or disable checking the formatting of Markdown files with Prettier.                                                                                                                                                                                                                                                                                          |
| **VALIDATE_NATURAL_LANGUAGE**                          | `true`                                                                       | Flag to enable or disable the linting process of the natural language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_OPENAPI**                                   | `true`                                                                       | Flag to enable or disable the linting process of the OpenAPI language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_PERL**                                      | `true`                                                                       | Flag to enable or disable the linting process of the Perl language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_PHP**                                       | `true`                                                                       | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP built-in linter) (keep for backward compatibility)                                                                                                                                                                                                                                       |
| **VALIDATE_PHP_BUILTIN**                               | `true`                                                                       | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP built-in linter)                                                                                                                                                                                                                                                                         |
| **VALIDATE_PHP_PHPCS**                                 | `true`                                                                       | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHP CodeSniffer)                                                                                                                                                                                                                                                                             |
| **VALIDATE_PHP_PHPSTAN**                               | `true`                                                                       | Flag to enable or disable the linting process of the PHP language. (Utilizing: PHPStan)                                                                                                                                                                                                                                                                                     |
| **VALIDATE_PHP_PSALM**                                 | `true`                                                                       | Flag to enable or disable the linting process of the PHP language. (Utilizing: PSalm)                                                                                                                                                                                                                                                                                       |
| **VALIDATE_POWERSHELL**                                | `true`                                                                       | Flag to enable or disable the linting process of the PowerShell language.                                                                                                                                                                                                                                                                                                   |
| **VALIDATE_PRE_COMMIT**                                | `true`                                                                       | Flag to enable or disable running pre-commit.                                                                                                                                                                                                                                                                                                                               |
| **VALIDATE_PROTOBUF**                                  | `true`                                                                       | Flag to enable or disable the linting process of the Protobuf language.                                                                                                                                                                                                                                                                                                     |
| **VALIDATE_PYTHON**                                    | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint) (keep for backward compatibility)                                                                                                                                                                                                                                                 |
| **VALIDATE_PYTHON_BLACK**                              | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: black)                                                                                                                                                                                                                                                                                    |
| **VALIDATE_PYTHON_FLAKE8**                             | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: flake8)                                                                                                                                                                                                                                                                                   |
| **VALIDATE_PYTHON_ISORT**                              | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: isort)                                                                                                                                                                                                                                                                                    |
| **VALIDATE_PYTHON_MYPY**                               | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: mypy)                                                                                                                                                                                                                                                                                     |
| **VALIDATE_PYTHON_PYLINT**                             | `true`                                                                       | Flag to enable or disable the linting process of the Python language. (Utilizing: pylint)                                                                                                                                                                                                                                                                                   |
| **VALIDATE_PYTHON_RUFF**                               | `true`                                                                       | Flag to enable or disable linting files using Ruff                                                                                                                                                                                                                                                                                                                          |
| **VALIDATE_PYTHON_RUFF_FORMAT**                        | `true`                                                                       | Flag to enable or disable formatting files using Ruff                                                                                                                                                                                                                                                                                                                       |
| **VALIDATE_R**                                         | `true`                                                                       | Flag to enable or disable the linting process of the R language.                                                                                                                                                                                                                                                                                                            |
| **VALIDATE_RENOVATE**                                  | `true`                                                                       | Flag to enable or disable the linting process of the Renovate configuration files.                                                                                                                                                                                                                                                                                          |
| **VALIDATE_RUBY**                                      | `true`                                                                       | Flag to enable or disable the linting process of the Ruby language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_RUST_2015**                                 | `true`                                                                       | Flag to enable or disable the linting process of the Rust language. (edition: 2015)                                                                                                                                                                                                                                                                                         |
| **VALIDATE_RUST_2018**                                 | `true`                                                                       | Flag to enable or disable the linting process of Rust language. (edition: 2018)                                                                                                                                                                                                                                                                                             |
| **VALIDATE_RUST_2021**                                 | `true`                                                                       | Flag to enable or disable the linting process of Rust language. (edition: 2021)                                                                                                                                                                                                                                                                                             |
| **VALIDATE_RUST_2024**                                 | `true`                                                                       | Flag to enable or disable the linting process of Rust language. (edition: 2024)                                                                                                                                                                                                                                                                                             |
| **VALIDATE_RUST_CLIPPY**                               | `true`                                                                       | Flag to enable or disable the clippy linting process of Rust language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_SCALAFMT**                                  | `true`                                                                       | Flag to enable or disable the linting process of Scala language. (Utilizing: scalafmt --test)                                                                                                                                                                                                                                                                               |
| **VALIDATE_SHELL_SHFMT**                               | `true`                                                                       | Flag to enable or disable the linting process of Shell scripts. (Utilizing: shfmt)                                                                                                                                                                                                                                                                                          |
| **VALIDATE_SNAKEMAKE_LINT**                            | `true`                                                                       | Flag to enable or disable the linting process of Snakefiles. (Utilizing: snakemake --lint)                                                                                                                                                                                                                                                                                  |
| **VALIDATE_SNAKEMAKE_SNAKEFMT**                        | `true`                                                                       | Flag to enable or disable the linting process of Snakefiles. (Utilizing: snakefmt)                                                                                                                                                                                                                                                                                          |
| **VALIDATE_SPELL_CODESPELL**                           | `true`                                                                       | Flag to enable or disable the linting process of the spelling language. (Utilizing: codespell)                                                                                                                                                                                                                                                                              |
| **VALIDATE_STATES**                                    | `true`                                                                       | Flag to enable or disable the linting process for AWS States Language.                                                                                                                                                                                                                                                                                                      |
| **VALIDATE_SQLFLUFF**                                  | `true`                                                                       | Flag to enable or disable the linting process of the SQL language. (Utilizing: sqlfuff)                                                                                                                                                                                                                                                                                     |
| **VALIDATE_TERRAFORM_FMT**                             | `true`                                                                       | Flag to enable or disable checking the formatting process of the Terraform files.                                                                                                                                                                                                                                                                                           |
| **VALIDATE_TERRAFORM_TFLINT**                          | `true`                                                                       | Flag to enable or disable the linting process of the Terraform language. (Utilizing tflint)                                                                                                                                                                                                                                                                                 |
| **VALIDATE_TERRAGRUNT**                                | `true`                                                                       | Flag to enable or disable the linting process for Terragrunt files.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_TRIVY**                                     | `true`                                                                       | Flag to enable or disable running Trivy.                                                                                                                                                                                                                                                                                                                                    |
| **VALIDATE_TSX**                                       | `true`                                                                       | Flag to enable or disable the linting process for tsx files (Utilizing: ESLint)                                                                                                                                                                                                                                                                                             |
| **VALIDATE_TYPESCRIPT_ES**                             | `true`                                                                       | Flag to enable or disable the linting process of the TypeScript language. (Utilizing: ESLint)                                                                                                                                                                                                                                                                               |
| **VALIDATE_TYPESCRIPT_PRETTIER**                       | `true`                                                                       | Flag to enable or disable checking the formatting of TypeScript files with Prettier.                                                                                                                                                                                                                                                                                        |
| **VALIDATE_VUE**                                       | `true`                                                                       | Flag to enable or disable the linting process of the vue files. (Utilizing: ESLint).                                                                                                                                                                                                                                                                                        |
| **VALIDATE_VUE_PRETTIER**                              | `true`                                                                       | Flag to enable or disable checking the formatting of Vue files with Prettier.                                                                                                                                                                                                                                                                                               |
| **VALIDATE_XML**                                       | `true`                                                                       | Flag to enable or disable the linting process of the XML language.                                                                                                                                                                                                                                                                                                          |
| **VALIDATE_YAML**                                      | `true`                                                                       | Flag to enable or disable the linting process of the YAML language.                                                                                                                                                                                                                                                                                                         |
| **VALIDATE_YAML_PRETTIER**                             | `true`                                                                       | Flag to enable or disable checking the formatting of YAML files with Prettier.                                                                                                                                                                                                                                                                                              |
| **YAML_CONFIG_FILE**                                   | `.yaml-lint.yml`                                                             | Filename for [Yamllint configuration](https://yamllint.readthedocs.io/en/stable/configuration.html) (ex:`.yaml-lint.yml`, `.yamllint.yml`)                                                                                                                                                                                                                                  |
| **YAML_ERROR_ON_WARNING**                              | `false`                                                                      | Flag to enable or disable the error on warning for Yamllint.                                                                                                                                                                                                                                                                                                                |

The `VALIDATE_[LANGUAGE]` variables work as follows:

- super-linter runs all supported linters by default.
- If you set any of the `VALIDATE_[LANGUAGE]` variables to `true`, super-linter
  defaults to leaving any unset variable to false (only validate those
  languages).
- If you set any of the `VALIDATE_[LANGUAGE]` variables to `false`, super-linter
  defaults to leaving any unset variable to true (only exclude those languages).
- If you set any of the `VALIDATE_[LANGUAGE]` variables to both `true` and
  `false`, super-linter fails reporting an error.

For more information about reusing Super-linter configuration across
environments, see
[Share Environment variables between environments](docs/run-linter-locally.md#share-environment-variables-between-environments).

### VALIDATE_ALL_CODEBASE

To lint and format only the files that you changed or created, set
`VALIDATE_ALL_CODEBASE` to `false`. To lint and format all the files in the
workspace, set `VALIDATE_ALL_CODEBASE` to `true` (the default).

The following linters and formatters ignore the `VALIDATE_ALL_CODEBASE`
variable, and always check the entire workspace:

- Biome, because it supports its own mechanism to check changed files only. For
  more information, about configuring Biome to only check changed files, see
  [Biome VCS integration doc](https://biomejs.dev/guides/integrate-in-vcs/#process-only-changed-files).
- Trivy, because while some Trivy scanners can work on changed files only,
  others expect to scan the entire workspace. For example, if you run the SBOM
  scanner against a subset of files, you'll unexpectedly get a partial SBOM.
- Jscpd, because the most likely intended Jscpd use case is to search for
  duplicates across the entire workspace, not just across the changed files.

## Fix linting and formatting issues

All the linters and formatters that Super-linter runs report errors if they
detect linting or formatting issues without modifying your source code (_check
only mode_). Check only mode is the default for all linters and formatters that
Super-linter runs.

Certain linters and formatters support automatically fixing issues in your code
(_fix mode_). You can enable fix mode for a particular linter or formatter by
setting the relevant `FIX_<language name>` variable to `true`. To know which
linters and formatters support fix mode, refer to the
[Configure Super-linter section](#configure-super-linter).

Setting a `FIX_<language name>` variable to `true` implies setting the
corresponding `VALIDATE_<language name>` to `true`. Setting a
`FIX_<language name>` variable to `true` and the corresponding
`VALIDATE_<language name>` to `false` is a configuration error. Super-linter
reports that as a fatal error.

Super-linter supports the following locations to deliver fixes:

- In the current Super-linter workspace, so you can process the changes to your
  files by yourself. For example:
  - If you're running Super-linter in your CI environment, such as GitHub
    Actions, you can commit and push changes as part of your workflow.
  - If you're running Super-linter locally, you can commit the changes as you
    would with any other change in your working directory.

### Fix mode for ansible-lint

ansible-lint requires that the `yaml` rule is enabled to for the ansible-lint
fix mode to work. The default ansible-lint configuration that Super-linter ships
disables the `yaml` rule because it might not be compatible with yamllint. If
you need to enable the ansible-lint fix mode, provide an ansible-lint
configuration that doesn't ignore the `yaml` rule.

### Fix mode for pre-commit

There is no `FIX_PRE_COMMIT` configuration variable because you can enable or
disable fix mode for a pre-commit hook (if the hook supports that) by updating
your pre-commit configuration file. To enable fix mode for a pre-commit hook,
see the documentation of that hook.

### Fix mode file and directory ownership

When fix mode is enabled, some linters and formatters don't maintain the
original file or directory ownership, and use the user that Super-linter uses to
run the linter or formatter.

### Fix mode examples and workflows

You can configure Super-linter to automatically deliver linting and formatting
fixes. For example, you can configure a workflow that automatically commits the
fixes, and pushes them to a branch.

To ensure that Super-linter analyzes your codebase as expected, we recommend
that you configure your fix mode workflows in addition to your existing
Super-linter workflows.

#### GitHub Actions workflow example: push and pull request

The following example shows a GitHub Actions workflow that uses Super-linter to
automatically fix linting and formatting issues, commit changes in the current
branch, and push commits to the remote branch tracking the current branch
whenever a you push commits on any branch, or when you create or update a pull
request:

<!-- prettier-ignore-start -->
```yaml
---
name: Lint

on: # yamllint disable-line rule:truthy
  push: null
  pull_request: null

permissions:
  contents: read

jobs:
  lint:
    # Super-linter workflow running in check only mode
    # See https://github.com/super-linter/super-linter#get-started

  fix-lint-issues:
    permissions:
      # To write linting fixes
      contents: write
      # To write Super-linter status checks
      statuses: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0
          persist-credentials: false
      - name: Super-Linter
        uses: super-linter/super-linter@v8.5.1 # x-release-please-version
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          # Set your fix mode variables to true
          FIX_SHELL_SHFMT: true
          FIX_YAML_PRETTIER: true
          # To reuse the same Super-linter configuration that you use in the
          # lint job without duplicating it, see
          # https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md#share-environment-variables-between-environments
      - name: Commit and push linting fixes
        # Run only on:
        # - Pull requests
        # - Not on the default branch
        if: >
          github.event_name == 'pull_request' &&
          github.ref_name != github.event.repository.default_branch
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          branch: ${{ github.event.pull_request.head.ref || github.head_ref || github.ref }}
          commit_message: "chore: fix linting issues"
          commit_user_name: super-linter
          commit_user_email: super-linter@super-linter.dev
```
<!-- prettier-ignore-end -->

This example uses
[GitHub Actions automatic token authentication](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication)
that automatically creates a unique `GITHUB_TOKEN` secret for the workflow.
GitHub Actions imposes the following limitations on workflows:

- To avoid accidentally creating recursive workflow runs, the commit that
  contains linting and formatting fixes
  [doesn't create new workflow runs](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#using-the-github_token-in-a-workflow).
- It restricts edits to GitHub Actions workflows files (in `.github/workflows`).
- It may fail pushing commits to protected branches.

To work around these limitations, you do the following:

1. [Create an authentication token with additional permissions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#granting-additional-permissions).
1. Grant the authentication token the
   [`repo` and `workflow` permissions](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens).
1. Use the authentication token in the `actions/checkout` step:

   ```yaml
   - uses: actions/checkout@v5
     with:
       fetch-depth: 0
       token: ${{ secrets.SUPER_LINTER_TOKEN }}
   ```

   This example assumes that you saved the authentication token in a secret
   called `SUPER_LINTER_TOKEN`, but you can choose whatever name you prefer for
   the secret.

## Configure linters

Super-linter provides default configurations for some linters in the `TEMPLATES`
directory. You can customize the configuration for the linters that support this
by placing your own configuration files in the `LINTER_RULES_PATH` directory.
`LINTER_RULES_PATH` is relative to the `DEFAULT_WORKSPACE` directory.

By providing your own configuration files, Super-linter will ignore default
configuration files. For example, if you provide your own configuration file for
a linter, you can enable more checks and rules than what Super-linter enables by
default for that linter, or disable some checks and rules that you don't need to
enable. Super-linter configures some linters to enable more checks and rules
than linters would by default, so by providing your own configuration file,
ensure that you enable all checks and rules that you need for your use case.

Super-linter supports customizing the name of these configuration files. For
more information, refer to [Configure super-linter](#configure-super-linter).

For example, you can configure Super-linter to:

- Load configuration files from the `config/lint` directory in your repository:

  ```yaml
  env:
    LINTER_RULES_PATH: config/lint
  ```

- Load configuration files from the root directory of your repository:

  ```yaml
  env:
    LINTER_RULES_PATH: .
  ```

In order to facilitate migrations from using standalone linters and formatters
to super-linter, the following linters and formatters don't load configuration
files from `LINTER_RULES_PATH`, but rather they use their own mechanism to
discover and load configuration files. To configure these linters and
formatters, see:

- [Biome](https://biomejs.dev/guides/configure-biome/)
- [Prettier](https://prettier.io/docs/en/configuration)
- [Commitlint](https://commitlint.js.org/reference/configuration.html#config-via-file)

Some of the linters and formatters that super-linter provides can be configured
to disable certain rules or checks, and to ignore certain files or part of them.

For more information about how to configure each linter or formatter, review
[their own documentation](#supported-linters-and-formatters).

## Include or exclude files from checks

If you need to include or exclude directories from being checked, you can use
two environment variables: `FILTER_REGEX_INCLUDE` and `FILTER_REGEX_EXCLUDE`.

For example:

- Lint the `src` folder in the root of the repository:
  `FILTER_REGEX_INCLUDE: ^src/`
- Lint all `src` folders in the repository: `FILTER_REGEX_INCLUDE: (^|/)src/`
- Do not lint files inside `test` folder in the root of the repository:
  `FILTER_REGEX_EXCLUDE: ^test/`
- Do not lint files inside all `test` folders in the repository:
  `FILTER_REGEX_EXCLUDE: (^|/)test/`
- Do not lint JavaScript files inside `test` folder in the root of the
  repository: `FILTER_REGEX_EXCLUDE: ^test/[^/]+\.js$`
- Do not lint JavaScript files inside `test` folder in the root of the
  repository (recursively): `FILTER_REGEX_EXCLUDE: ^test/.+\.js$`
- Do not lint files named `gradlew` and JavaScript files inside a specific
  directory:
  `FILTER_REGEX_EXCLUDE: ((^|/)gradlew|^specific/directory/[^/]+\.js)$`

To use regular expressions that check starting from the beginning of the string
(using `^`), set `STRIP_DEFAULT_WORKSPACE_FOR_REGEX` to `true`.

<!-- This `README.md` has both markers in the text, so it is considered not generated. -->

Additionally, if you set `IGNORE_GENERATED_FILES` to `true`, super-linter
ignores any file with `@generated` string in it, unless the file also has
`@not-generated` marker. For example, super-linter considers a file with the
following contents as generated:

```bash
#!/bin/sh
echo "@generated"
```

while considers this file as not generated:

```bash
#!/bin/sh
echo "@generated" # @not-generated
```

Finally, you can set `IGNORE_GITIGNORED_FILES` to `true` to ignore a file if Git
ignores it too.

### Tools that always check the entire workspace

The following linters and formatters ignore the `FILTER_REGEX_INCLUDE`,
`FILTER_REGEX_EXCLUDE`, `IGNORE_GENERATED_FILES`, `IGNORE_GITIGNORED_FILES`,
`VALIDATE_ALL_CODEBASE` variables, and always check the entire workspace:

- ansible-lint
- Biome
- Jscpd
- Checkov
- pre-commit
- Trivy

When running these linters and formatters, Super-linter demands to them the task
of building the list of files that they should check.

To include or exclude files when using the tools in the preceding list, use
their own ignoring mechanisms.

## GitHub Actions events

When you trigger a workflow with a step that runs Super-linter on GitHub Actions
on
[specific events](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows),
consider the following if you set `VALIDATE_ALL_CODEBASE` to `false`:

- `push` events: Super-linter checks only the files that were modified in the
  commits you pushed in the push event. Examples:
  - If you push `commit-1` and `commit-2` to `branch-a`, Super-linter will lint
    the files you modified in `commit-1` and `commit-2`. Then, if you push
    `commit-3` to `branch-a`, Super-linter will check only the files you
    modified in `commit-3`.
  - If you push a merge commit that merges the default branch (example: `main`)
    in a non-default branch, Super-linter will check only the files that you
    modified in the merge commit. This might be surprising for some users,
    because, in this case, Super-linter will check only files that you modified
    in the default branch in the merge commit.
- `merge_group`, `pull_request` events: Super-linter checks all the files that
  you modified compared to the repository default branch.
- `workflow_dispatch` events: Super-linter checks all the files that you
  modified compared to the repository default branch. If you send a
  `workflow_dispatch` event to the default branch of your repository, or to a
  tag that points at the `HEAD` of your default branch, Super-linter will not
  find any file to lint unless `VALIDATE_ALL_CODEBASE` is set to `true`.
- `pull_request_target`, `repository_dispatch`, `schedule` events: Super-linter
  will not find any files to check unless `VALIDATE_ALL_CODEBASE` is set to
  `true` because these events run against the repository default branch.

By setting `FAIL_ON_INVALID_GITHUB_ACTIONS_EVENT_CONFIGURATION` to `true`,
Super-linter exits with an error if the configuration is not suitable for the
GitHub event that triggered the issue.

## Run Super-Linter outside GitHub Actions

You don't need GitHub Actions to run super-linter. It supports several runtime
environments.

### Run using a container runtime engine

You can run super-linter outside GitHub Actions. For example, you can run
super-linter from a shell:

```bash
docker run \
  -e LOG_LEVEL=DEBUG \
  -e RUN_LOCAL=true \
  -v /path/to/local/codebase:/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```

For more information, see
[Run super-linter outside GitHub Actions](https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md).

## Use your own SSH key and certificate

If you need to use your own SSH key to authenticate against private
repositories, you can use the `SSH_KEY` environment variable. The value of that
environment variable is expected to be the private key of an SSH keypair that
has access to your private repositories.

For example, you can configure this private key as an
[Encrypted Secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
and access it with the `secrets` parameter from your GitHub Actions workflow:

```yaml
env:
  SSH_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

If you need to inject a certification authority (CA) certificate in the
operating system trust store, you can use the `SSL_CERT_SECRET` variable. The
value of that variable is expected to be the path to the files that contains a
CA that can be used to validate the certificate:

```yaml
env:
  SSL_CERT_SECRET: ${{ secrets.ROOT_CA }}
```

## Outputs

Super-linter supports generating several outputs, and also supports exposing the
output of individual linters.

### Summary outputs

Super-linter writes a summary of all the checks:

- If `SAVE_SUPER_LINTER_SUMMARY` is set to `true`, Super-linter writes a summary
  to
  `${DEFAULT_WORKSPACE}/${SUPER_LINTER_OUTPUT_DIRECTORY_NAME}/${SUPER_LINTER_SUMMARY_FILE_NAME}`.
- If `ENABLE_GITHUB_ACTIONS_STEP_SUMMARY` is set to `true`, Super-linter writes
  a GitHub Actions job summary. Setting `ENABLE_GITHUB_ACTIONS_STEP_SUMMARY` to
  `true` implies setting `SAVE_SUPER_LINTER_SUMMARY` to `true`.
- If `ENABLE_GITHUB_PULL_REQUEST_SUMMARY_COMMENT` is set to `true`, Super-linter
  posts a comment on the pull request that triggered the Super-linter workflow.
  Setting `ENABLE_GITHUB_PULL_REQUEST_SUMMARY_COMMENT` to `true` implies setting
  `SAVE_SUPER_LINTER_SUMMARY` to `true`.

The summary is in Markdown format. Super-linter supports the following formats:

- Table (default)

The summary output of previous Super-linter runs is not preserved.

### Super-linter outputs

If you set `SAVE_SUPER_LINTER_OUTPUT` to `true`, Super-linter saves its output
to `${DEFAULT_WORKSPACE}/${SUPER_LINTER_OUTPUT_DIRECTORY_NAME}/super-linter`, so
you can further process it, if needed.

Most outputs are in JSON format.

The output of previous Super-linter runs is not preserved.

### Linter reports and outputs

Some linters support configuring the format of their outputs for further
processing. To get access to that output, enable it using the respective linter
configuration file. If a linter requires a path for the output directory, you
can use the value of the `${DEFAULT_WORKSPACE}` variable.

If a linter doesn't support setting an arbitrary output path as described in the
previous paragraph, but only supports emitting results to standard output or
standard error streams, you can
[enable Super-linter outputs](#super-linter-outputs) and parse them.

### Ignore output that Super-linter generates

Super-linter generates output reports and logs. To avoid that these outputs end
up in your repository, we recommend that you add the following lines to your
`.gitignore` file:

```text
# Super-linter outputs
super-linter-output
super-linter.log

# GitHub Actions leftovers
github_conf
```

## Install additional dependencies

Super-linter supports installing dependencies at runtime, on each Super-linter
run. For more information about installing additional dependencies when running
Super-linter, see
[Install additional dependencies](docs/install-additional-dependencies.md).
