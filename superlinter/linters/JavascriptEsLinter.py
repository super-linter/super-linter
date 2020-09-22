#!/usr/bin/env python3
"""
Use eslint to lint JS files
https://eslint.org/
@author: Nicolas Vuillamy
"""

from superlinter.linters.JavascriptLinterRoot import JavascriptLinterRoot


class JavascriptEsLinter(JavascriptLinterRoot):
    linter_name = "eslint"
    linter_url = "https://eslint.org/"
    name = "JAVASCRIPT_ES"
    config_file_name = ".eslintrc.yml"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["eslint"]
        if self.config_file is not None:
            cmd.extend(["--no-eslintrc", "-c", self.config_file])
        cmd.append(file)
        return cmd
