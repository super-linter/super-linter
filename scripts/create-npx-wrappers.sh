#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PACKAGE_JSON_PATH="/action/dependencies/package.json"
if [[ ! -f "${PACKAGE_JSON_PATH}" ]] && [[ -f "dependencies/package.json" ]]; then
  PACKAGE_JSON_PATH="dependencies/package.json"
fi

if [[ ! -f "${PACKAGE_JSON_PATH}" ]]; then
  echo "Error: Cannot find package.json at ${PACKAGE_JSON_PATH}" >&2
  exit 1
fi

GetVersion() {
  local pkg="${1}"
  local ver
  ver="$(jq --raw-output ".dependencies[\"${pkg}\"] | sub(\"^[~^]\"; \"\")" "${PACKAGE_JSON_PATH}")"
  if [[ -z "${ver}" ]] || [[ "${ver}" == "null" ]]; then
    echo "Error: Failed to get version for ${pkg}" >&2
    exit 1
  fi
  echo "${ver}"
}

CreateWrapper() {
  local cmd="${1}"
  shift
  local target="/usr/bin/${cmd}"
  echo "Creating wrapper for ${cmd} at ${target}..."

  local -a args=(npx --yes)
  for pkg in "$@"; do
    local ver
    ver="$(GetVersion "${pkg}")"
    args+=(--package "${pkg}@${ver}")
  done
  args+=(-- "${cmd}")

  cat <<EOF >"${target}"
#!/usr/bin/env bash
exec ${args[*]} "\${@}"
EOF
  chmod +x "${target}"
}

CreateWrapper biome @biomejs/biome
CreateWrapper coffeelint @coffeelint/cli
CreateWrapper commitlint commitlint @commitlint/config-conventional
CreateWrapper eslint eslint @babel/eslint-parser @babel/preset-react @babel/preset-typescript @typescript-eslint/eslint-plugin eslint-config-prettier eslint-plugin-jest eslint-plugin-json eslint-plugin-jsonc eslint-plugin-jsx-a11y eslint-plugin-n eslint-plugin-prettier eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-vue next react react-dom react-intl react-redux react-router-dom typescript
CreateWrapper npm-groovy-lint npm-groovy-lint
CreateWrapper htmlhint htmlhint
CreateWrapper jscpd jscpd
CreateWrapper markdownlint markdownlint-cli
CreateWrapper spectral @stoplight/spectral-cli
CreateWrapper prettier prettier
CreateWrapper renovate-config-validator renovate
CreateWrapper asl-validator asl-validator
CreateWrapper stylelint stylelint stylelint-config-recommended-scss stylelint-config-standard stylelint-config-standard-scss stylelint-prettier stylelint-scss
CreateWrapper textlint textlint textlint-filter-rule-allowlist textlint-filter-rule-comments textlint-rule-terminology
