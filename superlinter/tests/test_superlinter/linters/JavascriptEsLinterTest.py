#!/usr/bin/env python3
"""
Unit tests for JavascriptEsLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.JavascriptEsLinter import JavascriptEsLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class JavascriptEsLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(JavascriptEsLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(JavascriptEsLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(JavascriptEsLinter(), self)
