#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

"""
import glob
import importlib
import os
import unittest

from superlinter.tests.test_superlinter.SuperLinterTest import SuperLinterTest


def suite():
    """Test suite"""
    # Core test classes
    test_suite = unittest.TestSuite()
    test_suite.addTests(
        unittest.TestLoader().loadTestsFromTestCase(SuperLinterTest)
    )
    # Linter test classes
    linters_dir = os.path.dirname(os.path.abspath(__file__)) + '/linters'
    linters_glob_pattern = linters_dir + '/*Test.py'
    for file in glob.glob(linters_glob_pattern):
        linter_class_file_name = os.path.splitext(os.path.basename(file))[0]
        linter_module = importlib.import_module('superlinter.tests.test_superlinter.linters.' + linter_class_file_name)
        linter_class = getattr(linter_module, linter_class_file_name)
        test_suite.addTests(
            unittest.TestLoader().loadTestsFromTestCase(linter_class)
        )
    return test_suite


if __name__ == '__main__':
    # noinspection PyTypeChecker
    unittest.TextTestRunner(verbosity=2).run(suite())
