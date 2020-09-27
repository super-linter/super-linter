#!/usr/bin/env python3
"""
Use HtmlHint to lint HTML files
https://github.com/htmlhint/HTMLHint
"""

from superlinter import LinterTemplate


class HtmlLinter(LinterTemplate):
    language = "HTML"
    linter_name = "htmlhint"
    linter_url = "https://github.com/htmlhint/HTMLHint"
    config_file_name = ".htmlhintrc"
    file_extensions = ['.html', '.htm']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["htmlhint"]
        if self.config_file is not None:
            cmd.extend(["--config", self.config_file])
        cmd.append(file)
        return cmd
