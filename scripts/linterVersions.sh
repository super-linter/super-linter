#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

##############################
# Linter command names array #
##############################
declare -A LINTER_NAMES_ARRAY
LINTER_NAMES_ARRAY['ANSIBLE']="ansible-lint"
LINTER_NAMES_ARRAY['BASH']="shellcheck"
LINTER_NAMES_ARRAY['BASH_EXEC']="bash-exec"
LINTER_NAMES_ARRAY['BIOME_FORMAT']="biome"
LINTER_NAMES_ARRAY['BIOME_LINT']="biome"
LINTER_NAMES_ARRAY['CHECKOV']="checkov"
LINTER_NAMES_ARRAY['CLANG_FORMAT']="clang-format"
LINTER_NAMES_ARRAY['CLOJURE']="clj-kondo"
LINTER_NAMES_ARRAY['CLOUDFORMATION']="cfn-lint"
LINTER_NAMES_ARRAY['COFFEESCRIPT']="coffeelint"
LINTER_NAMES_ARRAY['CPP']="cpplint"
LINTER_NAMES_ARRAY['CSS']="stylelint"
LINTER_NAMES_ARRAY['CSS_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['DART']="dart"
LINTER_NAMES_ARRAY['DOCKERFILE_HADOLINT']="hadolint"
LINTER_NAMES_ARRAY['EDITORCONFIG']="editorconfig-checker"
LINTER_NAMES_ARRAY['ENV']="dotenv-linter"
LINTER_NAMES_ARRAY['GITHUB_ACTIONS']="actionlint"
LINTER_NAMES_ARRAY['GITHUB_ACTIONS_ZIZMOR']="zizmor"
LINTER_NAMES_ARRAY['GITLEAKS']="gitleaks"
LINTER_NAMES_ARRAY['GIT_COMMITLINT']="commitlint"
LINTER_NAMES_ARRAY['GIT_MERGE_CONFLICT_MARKERS']="git-merge-conflict-markers"
LINTER_NAMES_ARRAY['GO']="golangci-lint"
LINTER_NAMES_ARRAY['GO_MODULES']="${LINTER_NAMES_ARRAY['GO']}"
LINTER_NAMES_ARRAY['GO_RELEASER']="goreleaser"
LINTER_NAMES_ARRAY['GOOGLE_JAVA_FORMAT']="google-java-format"
LINTER_NAMES_ARRAY['GRAPHQL_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['GROOVY']="npm-groovy-lint"
LINTER_NAMES_ARRAY['HTML']="htmlhint"
LINTER_NAMES_ARRAY['HTML_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['JAVA']="checkstyle"
LINTER_NAMES_ARRAY['JAVASCRIPT_ES']="eslint"
LINTER_NAMES_ARRAY['JAVASCRIPT_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['JSCPD']="jscpd"
LINTER_NAMES_ARRAY['JSON']="eslint"
LINTER_NAMES_ARRAY['JSON_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['JSONC']="eslint"
LINTER_NAMES_ARRAY['JSONC_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['JSX']="eslint"
LINTER_NAMES_ARRAY['JSX_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_BLACK']="nbqa"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_FLAKE8']="nbqa"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_ISORT']="nbqa"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_MYPY']="nbqa"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_PYLINT']="nbqa"
LINTER_NAMES_ARRAY['JUPYTER_NBQA_RUFF']="nbqa"
LINTER_NAMES_ARRAY['KOTLIN']="ktlint"
LINTER_NAMES_ARRAY['KUBERNETES_KUBECONFORM']="kubeconform"
LINTER_NAMES_ARRAY['LATEX']="chktex"
LINTER_NAMES_ARRAY['LUA']="lua"
LINTER_NAMES_ARRAY['MARKDOWN']="markdownlint"
LINTER_NAMES_ARRAY['MARKDOWN_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['NATURAL_LANGUAGE']="textlint"
LINTER_NAMES_ARRAY['OPENAPI']="spectral"
LINTER_NAMES_ARRAY['PERL']="perl"
LINTER_NAMES_ARRAY['PHP_BUILTIN']="php"
LINTER_NAMES_ARRAY['PHP_PHPCS']="phpcs"
LINTER_NAMES_ARRAY['PHP_PHPSTAN']="phpstan"
LINTER_NAMES_ARRAY['PHP_PSALM']="psalm"
LINTER_NAMES_ARRAY['PRE_COMMIT']="pre-commit"
LINTER_NAMES_ARRAY['PROTOBUF']="protolint"
LINTER_NAMES_ARRAY['PYTHON_BLACK']="black"
LINTER_NAMES_ARRAY['PYTHON_PYLINT']="pylint"
LINTER_NAMES_ARRAY['PYTHON_FLAKE8']="flake8"
LINTER_NAMES_ARRAY['PYTHON_ISORT']="isort"
LINTER_NAMES_ARRAY['PYTHON_MYPY']="mypy"
LINTER_NAMES_ARRAY['PYTHON_RUFF']="ruff"
LINTER_NAMES_ARRAY['PYTHON_RUFF_FORMAT']="ruff"
LINTER_NAMES_ARRAY['R']="R"
LINTER_NAMES_ARRAY['RENOVATE']="renovate-config-validator"
LINTER_NAMES_ARRAY['RUBY']="rubocop"
LINTER_NAMES_ARRAY['SCALAFMT']="scalafmt"
LINTER_NAMES_ARRAY['SHELL_SHFMT']="shfmt"
LINTER_NAMES_ARRAY['SNAKEMAKE_LINT']="snakemake"
LINTER_NAMES_ARRAY['SNAKEMAKE_SNAKEFMT']="snakefmt"
LINTER_NAMES_ARRAY['STATES']="asl-validator"
LINTER_NAMES_ARRAY['SQLFLUFF']="sqlfluff"
LINTER_NAMES_ARRAY['TERRAFORM_FMT']="terraform"
LINTER_NAMES_ARRAY['TERRAFORM_TFLINT']="tflint"
LINTER_NAMES_ARRAY['TERRAFORM_TERRASCAN']="terrascan"
LINTER_NAMES_ARRAY['TERRAGRUNT']="terragrunt"
LINTER_NAMES_ARRAY['TRIVY']="trivy"
LINTER_NAMES_ARRAY['TSX']="eslint"
LINTER_NAMES_ARRAY['TYPESCRIPT_ES']="eslint"
LINTER_NAMES_ARRAY['TYPESCRIPT_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['VUE']="eslint"
LINTER_NAMES_ARRAY['VUE_PRETTIER']="prettier"
LINTER_NAMES_ARRAY['XML']="xmllint"
LINTER_NAMES_ARRAY['YAML']="yamllint"
LINTER_NAMES_ARRAY['YAML_PRETTIER']="prettier"

if [[ "${IMAGE}" == "standard" ]]; then
  LINTER_NAMES_ARRAY['ARM']="arm-ttk"
  LINTER_NAMES_ARRAY['CSHARP']="dotnet"
  LINTER_NAMES_ARRAY['DOTNET_SLN_FORMAT_ANALYZERS']="dotnet"
  LINTER_NAMES_ARRAY['DOTNET_SLN_FORMAT_STYLE']="dotnet"
  LINTER_NAMES_ARRAY['DOTNET_SLN_FORMAT_WHITESPACE']="dotnet"
  LINTER_NAMES_ARRAY['POWERSHELL']="pwsh"
  LINTER_NAMES_ARRAY['RUST_2015']="rustfmt"
  LINTER_NAMES_ARRAY['RUST_2018']="rustfmt"
  LINTER_NAMES_ARRAY['RUST_2021']="rustfmt"
  LINTER_NAMES_ARRAY['RUST_2024']="rustfmt"
  LINTER_NAMES_ARRAY['RUST_CLIPPY']="clippy"
fi

echo "Building linter version file: ${VERSION_FILE}"

# Start with an empty file. We might have built this file in a previous build
# stage, so we start fresh here.
rm -rfv "${VERSION_FILE}"

echo "Building linter version file ${VERSION_FILE} for the following linters: ${LINTER_NAMES_ARRAY[*]}..."

for LANGUAGE in "${!LINTER_NAMES_ARRAY[@]}"; do
  LINTER="${LINTER_NAMES_ARRAY[${LANGUAGE}]}"
  echo "Get version for ${LINTER}"

  # Disable errexit because we want to get the error output
  set +o errexit

  # Some linters need to account for special commands to get their version instead
  # of the default --version option

  if [[ "${LINTER}" == "actionlint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | head -n 1)"
  elif [[ "${LINTER}" == "ansible-lint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep -v 'available' | awk '{ print $2 }')"
  elif [[ ${LINTER} == "arm-ttk" ]]; then
    GET_VERSION_CMD="$(grep -iE 'version' "/usr/bin/arm-ttk" | xargs 2>&1 | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "biome" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "black" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'black' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "cfn-lint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "chktex" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version 2>/dev/null | grep 'ChkTeX' | awk '{ print $2 }')"
  elif [[ ${LINTER} == "checkstyle" ]] || [[ ${LINTER} == "google-java-format" ]]; then
    GET_VERSION_CMD="$(java -jar "/usr/bin/${LINTER}" --version 2>&1 | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "clang-format" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "clj-kondo" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ ${LINTER} == "clippy" ]]; then
    GET_VERSION_CMD="$(cargo clippy --version 2>&1 | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "cpplint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'cpplint' | grep -v 'github' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "dart" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $4 }')"
  elif [[ "${LINTER}" == "dotenv-linter" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ ${LINTER} == "editorconfig-checker" ]]; then
    GET_VERSION_CMD="$(${LINTER} -version)"
  elif [[ "${LINTER}" == "flake8" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | grep 'mccabe' | awk '{ print $1 }')"
  elif [[ ${LINTER} == "gitleaks" ]]; then
    GET_VERSION_CMD="$(${LINTER} version)"
  elif [[ "${LINTER}" == "golangci-lint" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | awk '{ print $4 }')"
  elif [[ "${LINTER}" == "goreleaser" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | grep 'GitVersion' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "hadolint" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | awk '{ print $4 }')"
  elif [[ "${LINTER}" == "isort" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | grep 'VERSION' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "ktlint" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | awk '{ print $3 }')"
  elif [[ ${LINTER} == "kubeconform" ]]; then
    GET_VERSION_CMD="$(${LINTER} -v)"
  elif [[ ${LINTER} == "lintr" ]]; then
    # Need specific command for lintr (--slave is deprecated in R 4.0 and replaced by --no-echo)
    GET_VERSION_CMD="$(R --slave -e "r_ver <- R.Version()\$version.string; \
                lintr_ver <- packageVersion('lintr'); \
                glue::glue('lintr { lintr_ver } on { r_ver }')")"
  elif [[ "${LINTER}" == "perl" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'This' | awk '{ print $9 }')"
  elif [[ "${LINTER}" == "php" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'cli' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "phpcs" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "phpstan" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $7 }')"
  elif [[ ${LINTER} == "protolint" ]]; then
    GET_VERSION_CMD="$(${LINTER} version | awk '{ print $3 }')"
  elif [[ ${LINTER} == "psalm" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | awk '{ print $2 }')"
  elif [[ ${LINTER} == "pre-commit" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | awk '{ print $2 }')"
  elif [[ ${LINTER} == "pylint" ]]; then
    GET_VERSION_CMD="$(${LINTER} --version | grep 'pylint' | awk '{ print $2 }')"
  elif [[ ${LINTER} == "lua" ]]; then
    GET_VERSION_CMD="$("${LINTER}" -v 2>&1 | awk '{ print $2 }')"
  elif [[ ${LINTER} == "mypy" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "npm-groovy-lint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'npm-groovy-lint' | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "pwsh" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "R" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | head -n 1 | awk '{ print $3 }')"
  elif [[ ${LINTER} == "renovate-config-validator" ]]; then
    GET_VERSION_CMD="$(renovate --version 2>/dev/null)"
  elif [[ "${LINTER}" == "ruff" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "rustfmt" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "scalafmt" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "shellcheck" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | grep 'version:' | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "snakefmt" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $3 }')"
  elif [[ "${LINTER}" == "sqlfluff" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $3 }')"
  elif [[ ${LINTER} == "terraform" ]]; then
    GET_VERSION_CMD="$("${LINTER}" version -json | jq --raw-output .terraform_version)"
  elif [[ "${LINTER}" == "terragrunt" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ ${LINTER} == "terrascan" ]]; then
    GET_VERSION_CMD="$("${LINTER}" version 2>&1 | awk '{ print $2 }')"
  elif [[ ${LINTER} == "tflint" ]]; then
    # Unset TF_LOG_LEVEL so that the version file doesn't contain debug log when running
    # commands that read TF_LOG_LEVEL or TFLINT_LOG, which are likely set to DEBUG when
    # building the versions file
    GET_VERSION_CMD="$(
      unset TF_LOG_LEVEL
      unset TFLINT_LOG
      "${LINTER}" --version | grep 'version' | awk '{ print $3 }'
    )"
  elif [[ ${LINTER} == "trivy" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $2 }')"
  elif [[ ${LINTER} == "xmllint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'xmllint' | awk '{ print $5 }')"
  elif [[ "${LINTER}" == "yamllint" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  elif [[ "${LINTER}" == "zizmor" ]]; then
    GET_VERSION_CMD="$("${LINTER}" --version | awk '{ print $2 }')"
  # Some linters don't support a "get version" command
  elif [[ ${LINTER} == "bash-exec" ]] || [[ ${LINTER} == "nbqa" ]]; then
    GET_VERSION_CMD="Version command not supported"
  else
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1)"
  fi

  ERROR_CODE=$?
  # Enable errexit back
  set -o errexit

  if [ ${ERROR_CODE} -ne 0 ]; then
    echo "[ERROR]: Failed to get version info for ${LINTER}. Exit code: ${ERROR_CODE}. Output: ${GET_VERSION_CMD}"
    exit 1
  else
    echo "Successfully found version for ${LINTER}: ${GET_VERSION_CMD}"
    if ! echo "[${LANGUAGE}] ${LINTER}: ${GET_VERSION_CMD}" >>"${VERSION_FILE}" 2>&1; then
      echo "[ERROR]: Failed to write data to file!"
      exit 1
    fi
  fi
done

if ! sort --ignore-case --unique --output="${VERSION_FILE}" "${VERSION_FILE}"; then
  echo "[ERROR]:Failed to sort file!"
  exit 1
fi

echo -e "Versions file contents:\n$(cat "${VERSION_FILE}")"
