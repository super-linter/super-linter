# !/usr/bin/env python3
"""
Unit tests for Linter class (and sub-classes)
"""
import unittest

from superlinter import utils
from superlinter.tests.test_superlinter.helpers import utilstest


class LinterTestRoot(unittest.TestCase):
    language = None
    linter_name = None

    def setUp(self):
        utilstest.linter_test_setup()

    def get_linter_instance(self):
        return utils.build_linter(self.language, self.linter_name)

    def test_success(self):
        if self.language is not None:
            utilstest.test_linter_success(self.get_linter_instance(), self)

    def test_failure(self):
        if self.language is not None:
            utilstest.test_linter_failure(self.get_linter_instance(), self)

    def test_get_linter_version(self):
        if self.language is not None:
            utilstest.test_get_linter_version(self.get_linter_instance(), self)
