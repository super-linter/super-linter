#!/usr/bin/env python3
"""
Unit tests for CssLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.linters.HtmlLinter import HtmlLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class HtmlLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(HtmlLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(HtmlLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(HtmlLinter(), self)
