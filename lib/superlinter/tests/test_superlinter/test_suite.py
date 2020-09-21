#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

@author: Nicolas Vuillamy
"""
import unittest

from lib.superlinter.tests.test_superlinter.SuperLinterTest import SuperLinterTest


def suite():
    """Test suite"""
    test_suite = unittest.TestSuite()
    test_suite.addTests(
        unittest.TestLoader().loadTestsFromTestCase(SuperLinterTest)
    )
    return test_suite


if __name__ == '__main__':
    # noinspection PyTypeChecker
    unittest.TextTestRunner(verbosity=2).run(suite())
