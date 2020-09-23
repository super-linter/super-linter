#!/usr/bin/env python3
"""
Use markdownlint to lint Markdown files
https://github.com/DavidAnson/markdownlint
@author: Nicolas Vuillamy
"""

import os.path

from superlinter import LinterTemplate


class MarkdownLinter(LinterTemplate):
    language = "MARKDOWN"
    linter_name = "markdownlint"
    linter_url = "https://github.com/DavidAnson/markdownlint"
    config_file_name = ".markdown-lint.yml"
    file_extensions = ['.md']
    test_folder = 'markdown'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        dir_name = os.path.dirname(file)
        file_name = os.path.basename(file)
        cmd = ["markdownlint"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd

