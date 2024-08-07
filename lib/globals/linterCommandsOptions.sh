#!/usr/bin/env bash

# shellcheck disable=SC2034 # Disable ununsed variables warning because we
# source this script and use these variables as globals

# "check only" mode options for linters that that we reuse across several languages
PRETTIER_CHECK_ONLY_MODE_OPTIONS=(--check)
RUSTFMT_CHECK_ONLY_MODE_OPTIONS=(--check)

# Define configuration options to enable "check only" mode.
# Some linters and formatters only support a "check only" mode so there's no
# need to define a "check only" mode option for those.
CLANG_FORMAT_CHECK_ONLY_MODE_OPTIONS=(--dry-run)
CSHARP_CHECK_ONLY_MODE_OPTIONS=(--verify-no-changes)
GOOGLE_JAVA_FORMAT_CHECK_ONLY_MODE_OPTIONS=(--dry-run --set-exit-if-changed)
JAVASCRIPT_PRETTIER_CHECK_ONLY_MODE_OPTIONS=("${PRETTIER_CHECK_ONLY_MODE_OPTIONS[@]}")
PYTHON_BLACK_CHECK_ONLY_MODE_OPTIONS=(--diff --check)
PYTHON_ISORT_CHECK_ONLY_MODE_OPTIONS=(--diff --check)
RUST_2015_CHECK_ONLY_MODE_OPTIONS=("${RUSTFMT_CHECK_ONLY_MODE_OPTIONS[@]}")
RUST_2018_CHECK_ONLY_MODE_OPTIONS=("${RUSTFMT_CHECK_ONLY_MODE_OPTIONS[@]}")
RUST_2021_CHECK_ONLY_MODE_OPTIONS=("${RUSTFMT_CHECK_ONLY_MODE_OPTIONS[@]}")
SCALAFMT_CHECK_ONLY_MODE_OPTIONS=(--test)
SHELL_SHFMT_CHECK_ONLY_MODE_OPTIONS=(--diff)
SNAKEMAKE_SNAKEFMT_CHECK_ONLY_MODE_OPTIONS=(--check --compact-diff)
SQLFLUFF_CHECK_ONLY_MODE_OPTIONS=(lint)
TERRAFORM_FMT_CHECK_ONLY_MODE_OPTIONS=(-check -diff)
TYPESCRIPT_PRETTIER_CHECK_ONLY_MODE_OPTIONS=("${PRETTIER_CHECK_ONLY_MODE_OPTIONS[@]}")

# Fix mode options for linters that that we reuse across several languages
ESLINT_FIX_MODE_OPTIONS=(--fix)
GOLANGCI_LINT_FIX_MODE_OPTIONS=(--fix)
PRETTIER_FIX_MODE_OPTIONS=(--write)
STANDARD_FIX_MODE_OPTIONS=(--fix)

# Define configuration options to enable "fix mode".
# Not all linters and formatters support this.
ANSIBLE_FIX_MODE_OPTIONS=(--fix)
CSS_FIX_MODE_OPTIONS=(--fix)
ENV_FIX_MODE_OPTIONS=(fix)
GO_FIX_MODE_OPTIONS=("${GOLANGCI_LINT_FIX_MODE_OPTIONS[@]}")
GO_MODULES_FIX_MODE_OPTIONS=("${GOLANGCI_LINT_FIX_MODE_OPTIONS[@]}")
GROOVY_FIX_MODE_OPTIONS=(--fix)
JAVASCRIPT_ES_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
JAVASCRIPT_PRETTIER_FIX_MODE_OPTIONS=("${PRETTIER_FIX_MODE_OPTIONS[@]}")
JAVASCRIPT_STANDARD_FIX_MODE_OPTIONS=("${STANDARD_FIX_MODE_OPTIONS[@]}")
JSON_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
JSONC_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
JSX_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
MARKDOWN_FIX_MODE_OPTIONS=(--fix)
POWERSHELL_FIX_MODE_OPTIONS=(-Fix)
PROTOBUF_FIX_MODE_OPTIONS=(-fix)
PYTHON_RUFF_FIX_MODE_OPTIONS=(--fix)
RUBY_FIX_MODE_OPTIONS=(--autocorrect)
RUST_CLIPPY_FIX_MODE_OPTIONS=(--fix)
SHELL_SHFMT_FIX_MODE_OPTIONS=(--write)
SQLFLUFF_FIX_MODE_OPTIONS=(fix)
TSX_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
TYPESCRIPT_ES_FIX_MODE_OPTIONS=("${ESLINT_FIX_MODE_OPTIONS[@]}")
TYPESCRIPT_PRETTIER_FIX_MODE_OPTIONS=("${PRETTIER_FIX_MODE_OPTIONS[@]}")
TYPESCRIPT_STANDARD_FIX_MODE_OPTIONS=("${STANDARD_FIX_MODE_OPTIONS[@]}")

# sqlfluff is a special case because it needs a different subcommand and
# subcommand options
SQLFLUFF_SHARED_SUBCOMMAND_OPTIONS=(--config "${SQLFLUFF_LINTER_RULES}")
SQLFLUFF_CHECK_ONLY_MODE_OPTIONS+=("${SQLFLUFF_SHARED_SUBCOMMAND_OPTIONS[@]}")
SQLFLUFF_FIX_MODE_OPTIONS+=("${SQLFLUFF_SHARED_SUBCOMMAND_OPTIONS[@]}")

# If there's no input argument, GNU Parallel adds a default {} at the end of the
# command it runs. In a few cases, such as ANSIBLE, GO_MODULES, and RUST_CLIPPY,
# consume the {} element by artifically adding it to the command to run because
# we need the input to set the working directory, but we don't need it appended
# at the end of the command.
# Setting the -n 0 GNU Parallel would not help in this case, because the input
# will not be passed to the --workdir option as well.
INPUT_CONSUME_COMMAND=("&& echo \"Linted: {}\"")
