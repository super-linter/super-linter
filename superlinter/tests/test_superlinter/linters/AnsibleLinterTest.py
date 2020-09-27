#!/usr/bin/env python3
"""
Unit tests for AnsibleLinter class

"""
import unittest

from superlinter.linters.AnsibleLinter import AnsibleLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class AnsibleLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_success(self):
        utilstest.test_linter_success(AnsibleLinter(), self)

    def test_failure(self):
        utilstest.test_linter_failure(AnsibleLinter(), self)

    def test_get_linter_version(self):
        utilstest.test_get_linter_version(AnsibleLinter(), self)
