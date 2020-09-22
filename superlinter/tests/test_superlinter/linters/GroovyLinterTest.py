#!/usr/bin/env python3
"""
Unit tests for GroovyLinter class

@author: Nicolas Vuillamy
"""
import os
import unittest

from superlinter.linters.GroovyLinter import GroovyLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class GroovyLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(GroovyLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(GroovyLinter(), self)
