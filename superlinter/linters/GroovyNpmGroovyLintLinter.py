#!/usr/bin/env python3
"""
Use npm-groovy-lint to lint Groovy,Jenkinsfile,Gradle and Nextflow files
https://github.com/nvuillam/npm-groovy-lint
"""

import os.path

from superlinter import Linter


class GroovyNpmGroovyLintLinter(Linter):

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        dir_name = os.path.dirname(file)
        file_name = os.path.basename(file)
        cmd = [self.cli_executable,
               "--failon", "warning",
               "--path ", dir_name,
               "--files ", file_name]
        if self.config_file is not None:
            cmd.extend([self.cli_config_arg_name, self.config_file])
        return cmd
