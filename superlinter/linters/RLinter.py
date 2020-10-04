#!/usr/bin/env python3
"""
Use lintr to lint R files
https://github.com/jimhester/lintr
"""
import os
from shutil import copyfile

from superlinter import Linter


class RLinter(Linter):

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        # lintr requires .lintr in folder: copy it there if necessary
        dir_name = os.path.dirname(file)
        if not os.path.exists(dir_name + os.path.sep + self.config_file_name):
            copyfile(self.config_file, dir_name + os.path.sep + self.config_file_name)
        # Build command in R format
        r_commands = [f"errors <- lintr::lint('{file}');",
                      "print(errors);",
                      "quit(save = 'no', status = if (length(errors) > 0) 1 else 0)"]
        # Build shell command
        cmd = ["R",
               "--slave",
               "-e", "".join(r_commands)]
        return cmd

    # Build the CLI command to request lintr version
    def build_version_command(self):
        # Build command in R format
        r_commands = ["packageVersion(\"lintr\");"]
        # Build shell command
        cmd = ["R",
               "--slave",
               "-e", "".join(r_commands)]
        return cmd
