#!/usr/bin/env bash

# shellcheck disable=SC2034 # Disable unused variables warning because we
# source this script and use these variables as globals

# npx commands

NPX_COMMAND=(npx --yes)

NPX_BIOME_COMMAND=("${NPX_COMMAND[@]}" --package @biomejs/biome@2.4.10 -- biome)
NPX_COFFEESCRIPT_COMMAND=("${NPX_COMMAND[@]}" --package @coffeelint/cli@5.2.11 -- coffeelint)
NPX_COMMITLINT_COMMAND=("${NPX_COMMAND[@]}"
  --package commitlint@20.5.0
  --package @commitlint/config-conventional@20.5.0
  -- commitlint
)
NPX_ESLINT_COMMAND=("${NPX_COMMAND[@]}"
  --package eslint@9.39.2
  --package @babel/eslint-parser@7.28.6
  --package @babel/preset-react@7.28.5
  --package @babel/preset-typescript@7.28.5
  --package @typescript-eslint/eslint-plugin@8.58.0
  --package eslint-config-prettier@10.1.8
  --package eslint-plugin-jest@29.15.1
  --package eslint-plugin-json@4.0.1
  --package eslint-plugin-jsonc@3.1.2
  --package eslint-plugin-jsx-a11y@6.10.2
  --package eslint-plugin-n@17.24.0
  --package eslint-plugin-prettier@5.5.5
  --package eslint-plugin-react@7.37.5
  --package eslint-plugin-react-hooks@7.0.1
  --package eslint-plugin-vue@10.8.0
  --package next@16.2.2
  --package react@19.2.4
  --package react-dom@19.2.4
  --package react-intl@10.1.1
  --package react-redux@9.2.0
  --package react-router-dom@7.14.0
  --package typescript@6.0.2
  -- eslint
)
NPX_GROOVY_COMMAND=("${NPX_COMMAND[@]}" --package npm-groovy-lint@17.0.3 -- npm-groovy-lint)
NPX_HTML_COMMAND=("${NPX_COMMAND[@]}" --package htmlhint@1.9.2 -- htmlhint)
NPX_JSCPD_COMMAND=("${NPX_COMMAND[@]}" --package jscpd@4.0.8 -- jscpd)
NPX_MARKDOWN_COMMAND=("${NPX_COMMAND[@]}" --package markdownlint-cli@0.48.0 -- markdownlint)
NPX_OPENAPI_COMMAND=("${NPX_COMMAND[@]}" --package @stoplight/spectral-cli@6.15.0 -- spectral)
NPX_PRETTIER_COMMAND=("${NPX_COMMAND[@]}" --package prettier@3.8.1 -- prettier)
NPX_RENOVATE_COMMAND=("${NPX_COMMAND[@]}" --package renovate@43.101.3 -- renovate-config-validator)
NPX_STATES_COMMAND=("${NPX_COMMAND[@]}" --package asl-validator@4.0.0 -- asl-validator)
NPX_STYLELINT_COMMAND=("${NPX_COMMAND[@]}"
  --package stylelint@17.6.0
  --package stylelint-config-recommended-scss@17.0.0
  --package stylelint-config-standard@40.0.0
  --package stylelint-config-standard-scss@17.0.0
  --package stylelint-prettier@5.0.3
  --package stylelint-scss@7.0.0
  -- stylelint
)
NPX_TEXTLINT_COMMAND=("${NPX_COMMAND[@]}"
  --package textlint@15.5.2
  --package textlint-filter-rule-allowlist@4.0.0
  --package textlint-filter-rule-comments@1.3.0
  --package textlint-rule-terminology@5.2.16
  -- textlint
)
