#!/usr/bin/env python3
"""
Use dockerfilelint to lint Dockerfile
https://github.com/replicatedhq/dockerfilelint
@author: Nicolas Vuillamy
"""

from superlinter.linters.DockerfileLinterRoot import DockerfileLinterRoot


class DockerfileDockerfilelintLinter(DockerfileLinterRoot):
    linter_name = "dockerfilelint"
    linter_url = "https://github.com/replicatedhq/dockerfilelint"
    name = "DOCKERFILE_DOCKERFILELINT"
    config_file_name = ".dockerfilelintrc"
