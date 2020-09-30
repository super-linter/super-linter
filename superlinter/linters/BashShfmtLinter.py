#!/usr/bin/env python3
"""
Use SHFMT to lint shell files
https://github.com/mvdan/sh
"""

from superlinter.linters.BashLinterRoot import BashLinterRoot


class BashShfmtLinter(BashLinterRoot):
    linter_name = "shfmt"
    linter_url = "https://github.com/mvdan/sh"
    name = "BASH_SHFMT"
    test_folder = 'shell_shfmt'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["shfmt",
               "-d", file]
        return cmd
