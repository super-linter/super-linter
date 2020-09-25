#!/usr/bin/env python3
"""
Unit tests for CssLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.CssLinter import CssLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class CssLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(CssLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(CssLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(CssLinter(), self)
