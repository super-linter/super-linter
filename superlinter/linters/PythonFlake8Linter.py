#!/usr/bin/env python3
"""
Use Flake8 to lint Python files
https://flake8.pycqa.org/
@author: Nicolas Vuillamy
"""


from superlinter.linters.PythonLinterRoot import PythonLinterRoot


class PythonFlake8Linter(PythonLinterRoot):
    linter_name = "flake8"
    linter_url = "https://flake8.pycqa.org/"
    name = "PYTHON_FLAKE8"
    config_file_name = ".flake8"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["flake8"]
        if self.config_file is not None:
            cmd.extend(["--config", self.config_file])
        cmd.append(file)
        return cmd
