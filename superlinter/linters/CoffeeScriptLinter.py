#!/usr/bin/env python3
"""
Use coffeelint to lint CoffeeScript files
http://www.coffeelint.org/
"""

from superlinter import LinterTemplate


class CoffeeScriptLinter(LinterTemplate):
    language = "COFFEE"
    linter_name = "coffeelint"
    linter_url = "http://www.coffeelint.org/"
    config_file_name = ".coffee-lint.json"
    file_extensions = ['.coffee']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["coffeelint"]
        if self.config_file is not None:
            cmd.extend(["-f", self.config_file])
        cmd.append(file)
        return cmd
