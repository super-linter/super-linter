#!/usr/bin/env python3
"""
Use stylelint to lint CSS files
https://stylelint.io/
"""

from superlinter import LinterTemplate


class CssLinter(LinterTemplate):
    language = "CSS"
    linter_name = "stylelint"
    linter_url = "https://stylelint.io/"
    config_file_name = ".stylelintrc.json"
    file_extensions = ['.css', '.scss', '.saas']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["stylelint"]
        if self.config_file is not None:
            cmd.extend(["--config", self.config_file])
        cmd.append(file)
        return cmd
