#!/usr/bin/env python3
"""
Use eslint to lint JSX files
https://eslint.org/
"""

from superlinter import LinterTemplate


class JsxLinter(LinterTemplate):
    language = "JSX"
    linter_name = "eslint"
    linter_url = "https://eslint.org/"
    config_file_name = ".eslintrc.yml"
    file_extensions = ['.jsx']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["eslint"]
        if self.config_file is not None:
            cmd.extend(["--no-eslintrc",
                        "--no-ignore",
                        "-c", self.config_file])
        cmd.append(file)
        return cmd
