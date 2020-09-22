#!/usr/bin/env python3
"""
Use eslint to lint JS files
https://github.com/psf/black
@author: Nicolas Vuillamy
"""


from superlinter.linters.PythonLinterRoot import PythonLinterRoot


class PythonBlackLinter(PythonLinterRoot):
    linter_name = "black"
    linter_url = "https://github.com/psf/black"
    name = "PYTHON_BLACK"
    config_file_name = ".python-black"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["black", "--diff", "--check"]
        if self.config_file is not None:
            cmd.extend(["--config", self.config_file])
        cmd.append(file)
        return cmd
