#!/usr/bin/env python3
"""
Use eslint to lint JS files
https://eslint.org/
"""

from superlinter.linters.PythonLinterRoot import PythonLinterRoot


class PythonPyLintLinter(PythonLinterRoot):
    linter_name = "pylint"
    linter_url = "https://www.pylint.org/"
    name = "PYTHON_PYLINT"
    config_file_name = ".python-lint"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["pylint"]
        if self.config_file is not None:
            cmd.extend(["--rcfile", self.config_file])
        cmd.append(file)
        return cmd
