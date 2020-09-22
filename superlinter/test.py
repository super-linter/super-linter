#!/usr/bin/env python3
"""
Unit tests for Super-Linter

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.tests.test_superlinter.test_suite import suite

if __name__ == '__main__':
    # noinspection PyTypeChecker
    unittest.TextTestRunner(verbosity=2).run(suite())
