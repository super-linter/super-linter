#!/usr/bin/env python3
"""
Use Hadolint to lint Dockerfile
https://github.com/hadolint/hadolint
"""

from superlinter.linters.DockerfileLinterRoot import DockerfileLinterRoot


class DockerfileHadolintLinter(DockerfileLinterRoot):
    linter_name = "hadolint"
    linter_url = "https://github.com/hadolint/hadolint"
    name = "DOCKERFILE_HADOLINT"
    config_file_name = ".hadolint.yml"

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["hadolint"]
        # TODO: find why someones it's "" instead of ".hadolint.yml"
        if self.config_file is not None and self.config_file_name != '':
            print("HADOLINTCONFIGFILENAME" + self.config_file_name)
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
