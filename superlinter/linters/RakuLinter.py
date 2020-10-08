#!/usr/bin/env python3
"""
Use Raku to lint raku files
https://raku.org/
"""
import logging
import os
import subprocess

import superlinter


class RakuLinter(superlinter.Linter):

    # To execute before linting files
    def before_lint_files(self):
        if os.path.exists(self.workspace + os.path.sep + self.config_file_name):  # META6.json
            pre_command = f"cd {self.workspace} && zef install --deps-only --/test ."
            logging.debug('Raku before_lint_files: ' + pre_command)
            process = subprocess.run(pre_command,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT,
                                     shell=True)
            return_code = process.returncode
            return_stdout = superlinter.utils.decode_utf8(process.stdout)
            logging.debug(f"{return_code} : {return_stdout}")

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = [self.cli_executable,
               "-I", self.workspace + os.path.sep + 'lib',
               "-c", file]
        return cmd
