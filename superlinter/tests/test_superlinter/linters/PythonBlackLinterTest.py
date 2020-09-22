#!/usr/bin/env python3
"""
Unit tests for PythonBlackLinter class

@author: Nicolas Vuillamy
"""
import os
import unittest

from superlinter.linters.PythonBlackLinter import PythonBlackLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class JavascriptStandardLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(PythonBlackLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(PythonBlackLinter(), self)
