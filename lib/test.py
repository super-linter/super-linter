#!/usr/bin/env python3
import logging
import unittest

from lib.SuperLinter import SuperLinter

"""
Unit tests for Super-Linter

@author: Nicolas Vuillamy
"""


class SuperLinterTest(unittest.TestCase):

    @staticmethod
    def test_super_linter():
        super_linter = SuperLinter({'lint_root_path': '../.automation/test',
                                    'linter_rules_path': '../.github/linters',
                                    'logging_level': logging.DEBUG})
        super_linter.run()
