#!/usr/bin/env python3
"""
Unit tests for Super-Linter

@author: Nicolas Vuillamy
"""
import sys
import unittest

from superlinter.tests.test_superlinter.test_suite import suite

if __name__ == '__main__':
    # noinspection PyTypeChecker
    run_result = unittest.TextTestRunner(verbosity=2).run(suite())
    if run_result.wasSuccessful():
        sys.exit(0)
    else:
        sys.exit(1)
