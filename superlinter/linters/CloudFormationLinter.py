#!/usr/bin/env python3
"""
Use cfn-lint to lint CloudFormation files
https://github.com/martysweet/cfn-lint
"""

from superlinter import LinterTemplate
from superlinter.utils import file_contains


class CloudFormationLinter(LinterTemplate):
    language = "CLOUDFORMATION"
    linter_name = "cfn-lint"
    linter_url = "https://github.com/martysweet/cfn-lint"
    config_file_name = ".cfnlintrc.yml"
    file_extensions = ['.yml', '.yaml', 'json']

    # Filter files to keep only CloudFormation files
    def collect_files(self, all_files):
        super().collect_files(all_files)
        # Apply additional filters
        cloudformation_files = []
        for file in self.files:
            if file_contains(file, ["AWSTemplateFormatVersion", r"(AWS|Alexa|Custom)::"]):
                cloudformation_files.append(file)
        self.files = cloudformation_files

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["cfn-lint"]
        if self.config_file is not None:
            cmd.extend(["--config-file", self.config_file])
        cmd.append(file)
        return cmd
