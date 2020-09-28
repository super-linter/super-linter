#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

"""
import unittest

from superlinter.tests.test_superlinter.SuperLinterTest import SuperLinterTest
from superlinter.tests.test_superlinter.linters.GenericLinterTest import GenericLinterTest


def suite():
    """Test suite"""
    # Core test classes
    test_suite = unittest.TestSuite()
    test_suite.addTests(
        unittest.TestLoader().loadTestsFromTestCase(SuperLinterTest)
    )
    # Linter test classes
    test_suite.addTests(
        unittest.TestLoader().loadTestsFromTestCase(GenericLinterTest)
    )
    return test_suite


if __name__ == '__main__':
    # noinspection PyTypeChecker
    unittest.TextTestRunner(verbosity=2).run(suite())
