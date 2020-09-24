#!/usr/bin/env python3
"""
Use dockerfilelint to lint Dockerfile
https://github.com/replicatedhq/dockerfilelint
@author: Nicolas Vuillamy
"""
import os

from superlinter.linters.DockerfileLinterRoot import DockerfileLinterRoot


class DockerfileDockerfilelintLinter(DockerfileLinterRoot):
    linter_name = "dockerfilelint"
    linter_url = "https://github.com/replicatedhq/dockerfilelint"
    name = "DOCKERFILE_DOCKERFILELINT"
    config_file_name = ".dockerfilelintrc"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["dockerfilelint"]
        if self.config_file is not None:
            cmd.extend(["-c", os.path.realpath(self.config_file)])
        cmd.append(file)
        return cmd
