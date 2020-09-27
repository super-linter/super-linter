#!/usr/bin/env python3
"""
Root class for Dockerfile linters
"""

from superlinter import LinterTemplate


class DockerfileLinterRoot(LinterTemplate):
    language = "DOCKERFILE"
    file_names = ['Dockerfile']
    test_folder = 'docker'
