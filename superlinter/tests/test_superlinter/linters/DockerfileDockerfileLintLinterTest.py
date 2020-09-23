#!/usr/bin/env python3
"""
Unit tests for DockerfileDockerfileLintLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.DockerfileDockerfileLintLinter import DockerfileDockerfileLintLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class DockerfileDockerfileLintLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(DockerfileDockerfileLintLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(DockerfileDockerfileLintLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(DockerfileDockerfileLintLinter(), self)
