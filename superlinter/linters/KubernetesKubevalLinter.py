#!/usr/bin/env python3
"""
Use kubeval to lint Kubernetes files
https://github.com/instrumenta/kubeval
"""

import os

from superlinter import LinterTemplate
from superlinter.utils import file_contains


class KubernetesKubevalLinter(LinterTemplate):
    language = "KUBERNETES"
    name = "KUBERNETES_KUBEVAL"
    linter_name = "kubeval"
    linter_url = "https://github.com/instrumenta/kubeval"
    file_extensions = ['.yml', '.yaml', '.json']

    def __init__(self, params=None):
        super().__init__(params)
        if self.is_active is True:
            self.kubernetes_directory = os.environ.get('KUBERNETES_DIRECTORY',
                                                       self.workspace + os.path.sep + 'kubernetes')
            if not (self.is_active is True and os.path.exists(self.kubernetes_directory)):
                self.is_active = False

    # Filter files to keep only Ansible files
    def collect_files(self, all_files):
        # Lint only if there is an ansible directory
        if os.path.exists(self.kubernetes_directory):
            # Call super method to apply common filters
            super().collect_files(all_files)
            # Apply additional filters
            kubernetes_files = []
            for file in self.files:
                if self.kubernetes_directory in file and file_contains(file, ['apiVersion:']):
                    kubernetes_files.append(file)
            self.files = kubernetes_files

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["kubeval", "--strict", file]
        return cmd

    # Returns linter version: it can be "dev"
    def get_linter_version(self):
        version = super().get_linter_version()
        if version != "ERROR":
            return version
        else:
            version_output = self.get_linter_version_output()
            if "dev" in version_output:
                return "dev"
            else:
                return "ERROR"
