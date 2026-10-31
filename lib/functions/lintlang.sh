#!/usr/bin/env bash

# LintLang scans the whole workspace, so a repository without an AI instruction
# surface is valid input: --allow-empty makes an empty scan exit 0. All other
# non-zero exits still report malformed inputs or findings selected by --fail-on.
lintlang scan --allow-empty "$@"
