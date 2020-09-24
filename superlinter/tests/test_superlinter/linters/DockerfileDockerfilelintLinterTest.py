#!/usr/bin/env python3
"""
Unit tests for DockerfileDockerfileLintLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.DockerfileDockerfilelintLinter import DockerfileDockerfilelintLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class DockerfileDockerfilelintLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(DockerfileDockerfilelintLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(DockerfileDockerfilelintLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(DockerfileDockerfilelintLinter(), self)
