#!/usr/bin/env python3
"""
Use Rubocop to lint Ruby files
https://github.com/rubocop-hq/rubocop
"""

from superlinter import LinterTemplate


class RubyLinter(LinterTemplate):
    language = "RUBY"
    linter_name = "rubocop"
    linter_url = "https://github.com/rubocop-hq/rubocop"
    config_file_name = ".ruby-lint.yml"
    file_extensions = ['.rb']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["rubocop", "--force-exclusion"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
