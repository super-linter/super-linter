#!/usr/bin/env python3
"""
Use dartanalyzer to lint dart files
https://github.com/dart-lang/sdk/tree/master/pkg/analyzer_cli
"""

from superlinter import LinterTemplate


class DartLinter(LinterTemplate):
    language = "DART"
    linter_name = "dartanalyzer"
    linter_url = "https://github.com/dart-lang/sdk/tree/master/pkg/analyzer_cli"
    config_file_name = "analysis_options.yml"
    file_extensions = ['.dart']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["dartanalyzer",
               "--fatal-infos",
               "--fatal-warnings"]
        if self.config_file is not None:
            cmd.extend(["--options", self.config_file])
        cmd.append(file)
        return cmd

    # dartanalyzer --version returns <unknown> (bug)
    def get_linter_version(self):
        return '0.0.0'
