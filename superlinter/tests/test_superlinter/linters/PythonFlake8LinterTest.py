#!/usr/bin/env python3
"""
Unit tests for PythonFlake8Linter class

"""
import unittest

from superlinter.linters.PythonFlake8Linter import PythonFlake8Linter
from superlinter.tests.test_superlinter.helpers import utilstest


class PythonFlake8LinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(PythonFlake8Linter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(PythonFlake8Linter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(PythonFlake8Linter(), self)
