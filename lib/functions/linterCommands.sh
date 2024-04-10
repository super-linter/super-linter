#!/usr/bin/env bash

##########################
# Define linter commands #
##########################

# If there's no input argument, parallel adds a default {} at the end of the command.
# In a few cases, such as ANSIBLE and GO_MODULES,
# Consume the input before running the command because we need the input
# to set the working directory, but we don't need it appended at the end of the command.
# Setting -n 0 would not help in this case, because the input will not be passed
# to the --workdir option as well.
# shellcheck disable=SC2034 # Variable is referenced in other scripts
LINTER_COMMANDS_ARRAY_ANSIBLE=(ansible-lint -c "${ANSIBLE_LINTER_RULES}" "&& echo \"Linted: {}\"")
LINTER_COMMANDS_ARRAY_ARM=(pwsh -NoProfile -NoLogo -Command "\"Import-Module ${ARM_TTK_PSD1} ; \\\${config} = \\\$(Import-PowerShellDataFile -Path ${ARM_LINTER_RULES}) ; Test-AzTemplate @config -TemplatePath '{}'; if (\\\${Error}.Count) { exit 1 }\"")
LINTER_COMMANDS_ARRAY_BASH=(shellcheck --color --external-sources)
if [ -n "${BASH_SEVERITY}" ]; then
  LINTER_COMMANDS_ARRAY_BASH+=(--severity="${BASH_SEVERITY}")
fi
LINTER_COMMANDS_ARRAY_BASH_EXEC=(bash-exec '{}')
if [ "${BASH_EXEC_IGNORE_LIBRARIES}" == 'true' ]; then
  debug "Enabling bash-exec option to ignore shell library files."
  LINTER_COMMANDS_ARRAY_BASH_EXEC+=('true')
fi
LINTER_COMMANDS_ARRAY_CHECKOV=(checkov --config-file "${CHECKOV_LINTER_RULES}")
if CheckovConfigurationFileContainsDirectoryOption "${CHECKOV_LINTER_RULES}"; then
  # Consume the input as we do with ANSIBLE
  debug "Consume the input of the Checkov command because we don't need to add it as an argument."
  LINTER_COMMANDS_ARRAY_CHECKOV+=("&& echo \"Got the list of directories to lint from the configuration file: {}\"")
else
  debug "Adding the '--directory' option to the Checkov command."
  LINTER_COMMANDS_ARRAY_CHECKOV+=(--directory)
fi
LINTER_COMMANDS_ARRAY_CLANG_FORMAT=(clang-format --Werror --dry-run)
LINTER_COMMANDS_ARRAY_CLOJURE=(clj-kondo --config "${CLOJURE_LINTER_RULES}" --lint)
LINTER_COMMANDS_ARRAY_CLOUDFORMATION=(cfn-lint --config-file "${CLOUDFORMATION_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_COFFEESCRIPT=(coffeelint -f "${COFFEESCRIPT_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_CPP=(cpplint)
LINTER_COMMANDS_ARRAY_CSHARP=(dotnet format whitespace --folder --verify-no-changes --exclude / --include "{/}")
LINTER_COMMANDS_ARRAY_CSS=(stylelint --config "${CSS_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_DART=(dart analyze --fatal-infos --fatal-warnings)
LINTER_COMMANDS_ARRAY_DOCKERFILE_HADOLINT=(hadolint -c "${DOCKERFILE_HADOLINT_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_EDITORCONFIG=(editorconfig-checker -config "${EDITORCONFIG_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_ENV=(dotenv-linter)
LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS=(actionlint -config-file "${GITHUB_ACTIONS_LINTER_RULES}")
if [ "${GITHUB_ACTIONS_COMMAND_ARGS}" != "null" ] && [ -n "${GITHUB_ACTIONS_COMMAND_ARGS}" ]; then
  LINTER_COMMANDS_ARRAY_GITHUB_ACTIONS+=("${GITHUB_ACTIONS_COMMAND_ARGS}")
fi
LINTER_COMMANDS_ARRAY_GITLEAKS=(gitleaks detect --no-banner --no-git --redact --config "${GITLEAKS_LINTER_RULES}" --verbose --source)
LINTER_COMMANDS_ARRAY_GHERKIN=(gherkin-lint -c "${GHERKIN_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_GO=(golangci-lint run -c "${GO_LINTER_RULES}" --fast)
# Consume the input as we do with ANSIBLE
LINTER_COMMANDS_ARRAY_GO_MODULES=(golangci-lint run --allow-parallel-runners -c "${GO_LINTER_RULES}" "&& echo \"Linted: {}\"")
LINTER_COMMANDS_ARRAY_GOOGLE_JAVA_FORMAT=(java -jar /usr/bin/google-java-format --dry-run --set-exit-if-changed)
LINTER_COMMANDS_ARRAY_GROOVY=(npm-groovy-lint -c "${GROOVY_LINTER_RULES}" --failon warning --no-insight)
LINTER_COMMANDS_ARRAY_HTML=(htmlhint --config "${HTML_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_JAVA=(java -jar /usr/bin/checkstyle -c "${JAVA_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_JAVASCRIPT_ES=(eslint --no-eslintrc -c "${JAVASCRIPT_ES_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_JAVASCRIPT_STANDARD=(standard "${JAVASCRIPT_STANDARD_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_JAVASCRIPT_PRETTIER=(prettier --check)
LINTER_COMMANDS_ARRAY_JSCPD=(jscpd --config "${JSCPD_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_JSON=(eslint --no-eslintrc -c "${JAVASCRIPT_ES_LINTER_RULES}" --ext '.json')
LINTER_COMMANDS_ARRAY_JSONC=(eslint --no-eslintrc -c "${JAVASCRIPT_ES_LINTER_RULES}" --ext '.json5,.jsonc')
LINTER_COMMANDS_ARRAY_JSX=(eslint --no-eslintrc -c "${JSX_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_KOTLIN=(ktlint "{/}")
LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM=(kubeconform -strict)
if [ "${KUBERNETES_KUBECONFORM_OPTIONS}" != "null" ] && [ -n "${KUBERNETES_KUBECONFORM_OPTIONS}" ]; then
  LINTER_COMMANDS_ARRAY_KUBERNETES_KUBECONFORM+=("${KUBERNETES_KUBECONFORM_OPTIONS}")
fi
LINTER_COMMANDS_ARRAY_LATEX=(chktex -q -l "${LATEX_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_LUA=(luacheck --config "${LUA_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_MARKDOWN=(markdownlint -c "${MARKDOWN_LINTER_RULES}")
if [ -n "${MARKDOWN_CUSTOM_RULE_GLOBS}" ]; then
  IFS="," read -r -a MARKDOWN_CUSTOM_RULE_GLOBS_ARRAY <<<"${MARKDOWN_CUSTOM_RULE_GLOBS}"
  for glob in "${MARKDOWN_CUSTOM_RULE_GLOBS_ARRAY[@]}"; do
    if [ -z "${LINTER_RULES_PATH}" ]; then
      LINTER_COMMANDS_ARRAY_MARKDOWN+=(-r "${GITHUB_WORKSPACE}/${glob}")
    else
      LINTER_COMMANDS_ARRAY_MARKDOWN+=(-r "${GITHUB_WORKSPACE}/${LINTER_RULES_PATH}/${glob}")
    fi
  done
fi
LINTER_COMMANDS_ARRAY_NATURAL_LANGUAGE=(textlint -c "${NATURAL_LANGUAGE_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_OPENAPI=(spectral lint -r "${OPENAPI_LINTER_RULES}" -D)
LINTER_COMMANDS_ARRAY_PERL=(perlcritic)
if [ "${PERL_PERLCRITIC_OPTIONS}" != "null" ] && [ -n "${PERL_PERLCRITIC_OPTIONS}" ]; then
  LINTER_COMMANDS_ARRAY_PERL+=("${PERL_PERLCRITIC_OPTIONS}")
fi
LINTER_COMMANDS_ARRAY_PHP_BUILTIN=(php -l -c "${PHP_BUILTIN_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PHP_PHPCS=(phpcs --standard="${PHP_PHPCS_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PHP_PHPSTAN=(phpstan analyse --no-progress --no-ansi --memory-limit 1G -c "${PHP_PHPSTAN_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PHP_PSALM=(psalm --config="${PHP_PSALM_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_POWERSHELL=(pwsh -NoProfile -NoLogo -Command "\"Invoke-ScriptAnalyzer -EnableExit -Settings ${POWERSHELL_LINTER_RULES} -Path '{}'; if (\\\${Error}.Count) { exit 1 }\"")
LINTER_COMMANDS_ARRAY_PROTOBUF=(protolint lint --config_path "${PROTOBUF_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PYTHON_BLACK=(black --config "${PYTHON_BLACK_LINTER_RULES}" --diff --check)
LINTER_COMMANDS_ARRAY_PYTHON_PYLINT=(pylint --rcfile "${PYTHON_PYLINT_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PYTHON_FLAKE8=(flake8 --config="${PYTHON_FLAKE8_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PYTHON_ISORT=(isort --check --diff --sp "${PYTHON_ISORT_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_PYTHON_MYPY=(mypy --config-file "${PYTHON_MYPY_LINTER_RULES}" --install-types --non-interactive)
LINTER_COMMANDS_ARRAY_PYTHON_RUFF=(ruff check --config "${PYTHON_RUFF_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_R=(R --slave -e "\"lints <- lintr::lint('{}');print(lints);errors <- purrr::keep(lints, ~ .\\\$type == 'error');quit(save = 'no', status = if (length(errors) > 0) 1 else 0)\"")
LINTER_COMMANDS_ARRAY_RAKU=(raku)
LINTER_COMMANDS_ARRAY_RENOVATE=(renovate-config-validator --strict)
LINTER_COMMANDS_ARRAY_RUBY=(rubocop -c "${RUBY_LINTER_RULES}" --force-exclusion --ignore-unrecognized-cops)
LINTER_COMMANDS_ARRAY_RUST_2015=(rustfmt --check --edition 2015)
LINTER_COMMANDS_ARRAY_RUST_2018=(rustfmt --check --edition 2018)
LINTER_COMMANDS_ARRAY_RUST_2021=(rustfmt --check --edition 2021)
LINTER_COMMANDS_ARRAY_RUST_CLIPPY=(clippy)
LINTER_COMMANDS_ARRAY_SCALAFMT=(scalafmt --config "${SCALAFMT_LINTER_RULES}" --test)
LINTER_COMMANDS_ARRAY_SHELL_SHFMT=(shfmt -d)
LINTER_COMMANDS_ARRAY_SNAKEMAKE_LINT=(snakemake --lint -s)
LINTER_COMMANDS_ARRAY_SNAKEMAKE_SNAKEFMT=(snakefmt --config "${SNAKEMAKE_SNAKEFMT_LINTER_RULES}" --check --compact-diff)
LINTER_COMMANDS_ARRAY_STATES=(asl-validator --json-path)
LINTER_COMMANDS_ARRAY_SQL=(sql-lint --config "${SQL_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_SQLFLUFF=(sqlfluff lint --config "${SQLFLUFF_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_TEKTON=(tekton-lint)
LINTER_COMMANDS_ARRAY_TERRAFORM_FMT=(terraform fmt -check -diff)
LINTER_COMMANDS_ARRAY_TERRAFORM_TFLINT=("TF_DATA_DIR=\"/tmp/.terraform-TERRAFORM_TFLINT-{//}\"" tflint -c "${TERRAFORM_TFLINT_LINTER_RULES}" "--filter=\"{/}\"")
LINTER_COMMANDS_ARRAY_TERRAFORM_TERRASCAN=(terrascan scan -i terraform -t all -c "${TERRAFORM_TERRASCAN_LINTER_RULES}" -f)
LINTER_COMMANDS_ARRAY_TERRAGRUNT=(terragrunt hclfmt --terragrunt-check --terragrunt-log-level error --terragrunt-hclfmt-file)
LINTER_COMMANDS_ARRAY_TSX=(eslint --no-eslintrc -c "${TSX_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_TYPESCRIPT_ES=(eslint --no-eslintrc -c "${TYPESCRIPT_ES_LINTER_RULES}")
LINTER_COMMANDS_ARRAY_TYPESCRIPT_STANDARD=(ts-standard --parser @typescript-eslint/parser --plugin @typescript-eslint/eslint-plugin --project "${TYPESCRIPT_STANDARD_TSCONFIG_FILE}")
LINTER_COMMANDS_ARRAY_TYPESCRIPT_PRETTIER=(prettier --check)
LINTER_COMMANDS_ARRAY_XML=(xmllint)
LINTER_COMMANDS_ARRAY_YAML=(yamllint -c "${YAML_LINTER_RULES}" -f parsable)
if [ "${YAML_ERROR_ON_WARNING}" == 'true' ]; then
  LINTER_COMMANDS_ARRAY_YAML+=(--strict)
fi
