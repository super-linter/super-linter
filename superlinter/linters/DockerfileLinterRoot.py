#!/usr/bin/env python3
"""
Root class for Dockerfile linters
@author: Nicolas Vuillamy
"""

from superlinter import LinterTemplate


class DockerfileLinterRoot(LinterTemplate):
    language = "DOCKERFILE"
    file_names = ['Dockerfile']
    test_folder = 'docker'
