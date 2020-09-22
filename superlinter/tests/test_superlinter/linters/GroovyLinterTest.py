#!/usr/bin/env python3
"""
Unit tests for GroovyLinter class

@author: Nicolas Vuillamy
"""

import contextlib
import io
import os
import unittest

from superlinter import SuperLinter
from superlinter.tests.test_superlinter.helpers import utilstest


class GroovyLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()
