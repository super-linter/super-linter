#!/usr/bin/env python3
"""
Unit tests for GroovyLinter class

@author: Nicolas Vuillamy
"""

import unittest

from superlinter.tests.test_superlinter.helpers import utilstest


class GroovyLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()
