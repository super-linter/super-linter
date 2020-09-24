#!/usr/bin/env python3
"""
Use standard to lint JS files
https://github.com/standard/standard
@author: Nicolas Vuillamy
"""

from superlinter.linters.JavascriptLinterRoot import JavascriptLinterRoot


class JavascriptStandardLinter(JavascriptLinterRoot):
    linter_name = "standard"
    linter_url = "https://github.com/standard/standard"
    name = "JAVASCRIPT_STANDARD"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["standard", file]
        return cmd
