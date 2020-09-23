#!/usr/bin/env python3
"""
Unit tests for PythonPyLintLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.PythonPyLintLinter import PythonPyLintLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class PythonPyLintLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(PythonPyLintLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(PythonPyLintLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(PythonPyLintLinter(), self)
