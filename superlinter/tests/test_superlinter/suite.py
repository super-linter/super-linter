#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

"""
import importlib
import unittest

import superlinter
from superlinter.tests.test_superlinter.SuperLinter_test import SuperLinterTest


def suite():
    """Test suite"""
    # Core test classes
    test_suite = unittest.TestSuite()
    test_suite.addTests(
        unittest.TestLoader().loadTestsFromTestCase(SuperLinterTest)
    )
    # Linter test classes: one must exist for each linter class ( run .automation/build.py if not present)
    linter_classes = superlinter.SuperLinter.list_linter_classes()
    for linter_class in linter_classes:
        linter_test_class_name = linter_class.__name__ + '_test'
        test_module_name = 'superlinter.tests.test_superlinter.linters.' + linter_test_class_name
        linter_module = importlib.import_module(test_module_name, package=__package__)
        linter_test_class = getattr(linter_module, linter_test_class_name)
        test_suite.addTests(
            unittest.TestLoader().loadTestsFromTestCase(linter_test_class)
        )
    return test_suite


if __name__ == '__main__':
    # noinspection PyTypeChecker
    unittest.TextTestRunner(verbosity=2).run(suite())
