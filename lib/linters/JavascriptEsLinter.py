#!/usr/bin/env python3
"""
Use eslint to lint JS files
@author: Nicolas Vuillamy
"""

from lib.LinterTemplate import LinterTemplate


class JavascriptEsLinter(LinterTemplate):
    language = "JAVASCRIPT"
    name = "JAVASCRIPT_ES"
    config_file_name = ".eslintrc.json"
    file_extensions = ['.js']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["eslint"]
        if self.config_file is not None:
            cmd.extend(["--no-eslintrc", "-c", self.config_file])
        return cmd
