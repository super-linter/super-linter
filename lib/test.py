#!/usr/bin/env python3
import unittest

from lib.SuperLinter import SuperLinter

"""
Unit tests for Super-Linter

@author: Nicolas Vuillamy
"""


class SuperLinterTest(unittest.TestCase):

    @staticmethod
    def test_super_linter():
        super_linter = SuperLinter('../.automation/test')
        super_linter.run()
