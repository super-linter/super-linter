#!/usr/bin/env python3
"""
Use ansible-lint to lint Ansible files
https://github.com/ansible/ansible-lint
"""

import os

from superlinter import LinterTemplate


class AnsibleLinter(LinterTemplate):
    language = "ANSIBLE"
    linter_name = "ansible-lint"
    linter_url = "https://github.com/ansible/ansible-lint"
    config_file_name = ".ansible-lint.yml"
    file_extensions = ['.yml', 'yaml']

    file_end_exclude = ["vault.yml", "vault.yaml", "galaxy.yml", "galaxy.yaml"]

    def __init__(self, params=None):
        super().__init__(params)
        if self.is_active is True:
            self.ansible_directory = os.environ['ANSIBLE_DIRECTORY'] if "ANSIBLE_DIRECTORY" in os.environ \
                else self.workspace + os.path.sep + 'ansible'
            if not (self.is_active is True and os.path.exists(self.ansible_directory)):
                self.is_active = False

    # Filter files to keep only the ones matching extension or file name
    def collect_files(self, all_files):
        # Lint only if there is an ansible directory
        if os.path.exists(self.ansible_directory):
            # Call super method to apply common filters
            super().collect_files(all_files)
            # Apply additional filters
            ansible_files = []
            for file in self.files:
                if self.ansible_directory in file and not file.endswith(tuple(self.file_end_exclude)):
                    ansible_files.append(file)
            self.files = ansible_files

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["ansible-lint", "-v"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
