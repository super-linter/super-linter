#!/usr/bin/env python3
"""
Use golangci-lint to lint GO files
https://github.com/golangci/golangci-lint
"""

from superlinter import LinterTemplate


class GoLinter(LinterTemplate):
    language = "GO"
    linter_name = "golangci-lint"
    linter_url = "https://github.com/golangci/golangci-lint"
    config_file_name = ".golangci.yml"
    file_extensions = ['.go']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["golangci-lint",
               "run"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
