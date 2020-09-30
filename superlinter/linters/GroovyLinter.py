#!/usr/bin/env python3
"""
Use npm-groovy-lint to lint Groovy,Jenkinsfile,Gradle and Nextflow files
https://github.com/nvuillam/npm-groovy-lint
"""

import os.path

from superlinter import LinterTemplate


class GroovyLinter(LinterTemplate):
    language = "GROOVY"
    linter_name = "npm-groovy-lint"
    linter_url = "https://github.com/nvuillam/npm-groovy-lint"
    config_file_name = ".groovylintrc.json"
    file_extensions = ['.groovy', '.gvy', '.gradle', '.nf']
    file_names = ['Jenkinsfile']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        dir_name = os.path.dirname(file)
        file_name = os.path.basename(file)
        cmd = ["npm-groovy-lint",
               "--failon", "warning",
               "--path ", dir_name,
               "--files ", file_name]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        return cmd

    # Build regular expression to extract version from output
    # noinspection PyMethodMayBeStatic
    def build_extract_version_regex(self):
        return r"(?<=npm-groovy-lint version )\d+(\.\d+)+"
