#!/usr/bin/env python3
"""
Use yamllint to lint YAML files
https://github.com/adrienverge/yamllint
"""

from superlinter import LinterTemplate


class YamlLinter(LinterTemplate):
    language = "YAML"
    linter_name = "yamllint"
    linter_url = "https://github.com/adrienverge/yamllint"
    config_file_name = ".yaml-lint.yml"
    file_extensions = ['.yml', '.yaml']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["yamllint"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
