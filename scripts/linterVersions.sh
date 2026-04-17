#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck source=/dev/null
. /action/lib/globals/npxLinterCommands.sh

##############################
# Linter command names array #
##############################

set +o nounset # Disable temporarily to ignore unbound variables like rule paths
# shellcheck source=/dev/null
source /action/lib/globals/languages.sh
# shellcheck source=/dev/null
source /action/lib/functions/linterCommands.sh
set -o nounset

echo "Building linter version file: ${VERSION_FILE}"

# Start with an empty file. We might have built this file in a previous build
# stage, so we start fresh here.
rm -rfv "${VERSION_FILE}"

echo "Building linter version file ${VERSION_FILE} for ${#LANGUAGE_ARRAY[@]} languages..."

for LANGUAGE in "${LANGUAGE_ARRAY[@]}"; do
  echo "Getting version for ${LANGUAGE} language"

  if [[ "${IMAGE}" != "standard" ]]; then
    case "${LANGUAGE}" in
    ARM | CSHARP | DOTNET_SLN_FORMAT_ANALYZERS | DOTNET_SLN_FORMAT_STYLE | DOTNET_SLN_FORMAT_WHITESPACE | POWERSHELL | RUST_2015 | RUST_2018 | RUST_2021 | RUST_2024 | RUST_CLIPPY)
      echo "Skipping ${LANGUAGE} because the image is not standard."
      continue
      ;;
    esac
  fi

  declare -n CMD_ARRAY="LINTER_COMMANDS_ARRAY_${LANGUAGE}"
  LINTER=""

  # 1. Skip environment variables (like TF_DATA_DIR=...)
  for elem in "${CMD_ARRAY[@]}"; do
    first_word="${elem%% *}"
    if [[ "$first_word" != *=* ]]; then
      LINTER="$first_word"
      break
    fi
  done

  # 2. Handle wrappers (npx, java -jar, cargo, powershell)
  case "$LINTER" in
  npx)
    # Extract the linter command that comes after the `--` separator
    for i in "${!CMD_ARRAY[@]}"; do
      if [[ "${CMD_ARRAY[$i]}" == "--" ]]; then
        LINTER="${CMD_ARRAY[$((i + 1))]}"
        break
      fi
    done
    ;;
  java)
    # Extract the basename of the .jar file
    for i in "${!CMD_ARRAY[@]}"; do
      if [[ "${CMD_ARRAY[$i]}" == "-jar" ]]; then
        LINTER="$(basename "${CMD_ARRAY[$((i + 1))]}")"
        break
      fi
    done
    ;;
  cargo) LINTER="clippy" ;;
  Import-Module) LINTER="arm-ttk" ;;
  Invoke-ScriptAnalyzer) LINTER="pwsh" ;;
  esac

  unset -n CMD_ARRAY

  echo "Get version for ${LINTER}"

  # Disable errexit because we want to get the error output
  set +o errexit

  # Some linters need to account for special commands to get their version instead
  # of the default --version option

  # Execute the command, suppressing stderr if successful, but capturing it otherwise
  # for npm dependencies we should suppress npm warnings from stderr that pollute the version output.
  # Let's run the command and parse the output, but in the case statement below, we redirect 2>/dev/null for npx wrappers.

  case "${LINTER}" in
  actionlint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | head -n 1)"
    ;;
  ansible-lint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $2 }')"
    ;;
  arm-ttk)
    GET_VERSION_CMD="$(grep -iE 'version' "/usr/bin/arm-ttk" | xargs 2>&1 | awk '{ print $3 }')"
    ;;
  asl-validator)
    GET_VERSION_CMD="$("${NPX_STATES_COMMAND[@]}" --version 2>&1 | tail -n 1)"
    ;;
  bash-exec | nbqa)
    GET_VERSION_CMD="Version command not supported"
    ;;
  biome)
    GET_VERSION_CMD="$("${NPX_BIOME_COMMAND[@]}" --version 2>&1 | grep -i 'version' | awk '{ print $2 }')"
    ;;
  black | pylint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep "${LINTER}" | awk '{ print $2 }')"
    ;;
  cfn-lint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>/dev/null | awk '{ print $2 }')"
    ;;
  checkov)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $1 }')"
    ;;
  checkstyle | google-java-format)
    GET_VERSION_CMD="$(java -jar "/usr/bin/${LINTER}" --version 2>&1 | awk '{ print $3 }')"
    ;;
  chktex)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'ChkTeX' | awk '{ print $2 }')"
    ;;
  clang-format | ktlint | phpcs | snakefmt | sqlfluff | terragrunt)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $3 }')"
    ;;
  clippy)
    GET_VERSION_CMD="$(cargo clippy --version 2>&1 | awk '{ print $2 }')"
    ;;
  clj-kondo | dotenv-linter | mypy | pre-commit | psalm | pwsh | ruff | rustfmt | scalafmt | yamllint | zizmor)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | tail -n 1 | awk '{ print $2 }')"
    ;;
  coffeelint)
    GET_VERSION_CMD="$("${NPX_COFFEESCRIPT_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  commitlint)
    GET_VERSION_CMD="$("${NPX_COMMITLINT_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1 | awk -F'@' '{print $NF}')"
    ;;
  cpplint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep '^cpplint ' | awk '{ print $2 }')"
    ;;
  dart | golangci-lint | hadolint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $4 }')"
    ;;
  eslint)
    GET_VERSION_CMD="$("${NPX_ESLINT_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  flake8)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | head -n 1 | awk '{ print $1 }')"
    ;;
  gitleaks)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $3 }')"
    ;;
  goreleaser)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'GitVersion' | awk '{ print $2 }')"
    ;;
  htmlhint)
    GET_VERSION_CMD="$("${NPX_HTML_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  isort)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'VERSION' | awk '{ print $2 }')"
    ;;
  jscpd)
    GET_VERSION_CMD="$("${NPX_JSCPD_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  kubeconform)
    GET_VERSION_CMD="$("${LINTER}" -v 2>&1)"
    ;;
  luacheck)
    GET_VERSION_CMD="$("${LINTER}" -v 2>&1 | grep -i '^Luacheck:' | awk '{ print $2 }')"
    ;;
  markdownlint)
    GET_VERSION_CMD="$("${NPX_MARKDOWN_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  npm-groovy-lint)
    GET_VERSION_CMD="$("${NPX_GROOVY_COMMAND[@]}" --version 2>&1 | grep 'npm-groovy-lint' | awk '{ print $3 }')"
    ;;
  php)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'cli' | awk '{ print $2 }')"
    ;;
  phpstan)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $7 }')"
    ;;
  prettier)
    GET_VERSION_CMD="$("${NPX_PRETTIER_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  protolint)
    GET_VERSION_CMD="$("${LINTER}" version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)"
    ;;
  R)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | head -n 1 | awk '{ print $3 }')"
    ;;
  renovate-config-validator)
    GET_VERSION_CMD="$(LOG_LEVEL=WARN "${NPX_RENOVATE_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  shellcheck)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'version:' | awk '{ print $2 }')"
    ;;
  spectral)
    GET_VERSION_CMD="$("${NPX_OPENAPI_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  stylelint)
    GET_VERSION_CMD="$("${NPX_STYLELINT_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  terraform)
    GET_VERSION_CMD="$("${LINTER}" version -json 2>&1 | jq --raw-output .terraform_version)"
    ;;
  textlint)
    GET_VERSION_CMD="$("${NPX_TEXTLINT_COMMAND[@]}" --version 2>&1 | grep -v 'npm warn' | tail -n 1)"
    ;;
  tflint)
    GET_VERSION_CMD="$(
      unset TF_LOG_LEVEL
      unset TFLINT_LOG
      "${LINTER}" --version 2>&1 | grep 'version' | awk '{ print $3 }'
    )"
    ;;
  trivy)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | awk '{ print $2 }')"
    ;;
  xmllint)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1 | grep 'xmllint' | awk '{ print $5 }')"
    ;;
  *)
    GET_VERSION_CMD="$("${LINTER}" --version 2>&1)"
    ;;
  esac

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
