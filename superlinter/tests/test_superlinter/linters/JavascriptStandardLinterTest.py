#!/usr/bin/env python3
"""
Unit tests for JavascriptStandardLinter class

"""
import unittest

from superlinter.linters.JavascriptStandardLinter import JavascriptStandardLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class JavascriptStandardLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(JavascriptStandardLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(JavascriptStandardLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(JavascriptStandardLinter(), self)
