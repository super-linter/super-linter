#!/usr/bin/env python3
"""
Use shellcheck to lint bash files
https://github.com/koalaman/shellcheck
"""

from superlinter.linters.BashLinterRoot import BashLinterRoot


class BashShellcheckLinter(BashLinterRoot):
    linter_name = "shellcheck"
    linter_url = "https://github.com/koalaman/shellcheck"
    name = "BASH_SHELLCHECK"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["shellcheck",
               "--color=auto",
               "--external-sources",
               file]
        return cmd
