#!/usr/bin/env python3
"""
Unit tests for PythonBlackLinter class

"""
import unittest

from superlinter.linters.PythonBlackLinter import PythonBlackLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class PythonBlackLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(PythonBlackLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(PythonBlackLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(PythonBlackLinter(), self)
