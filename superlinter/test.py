#!/usr/bin/env python3
"""
Unit tests for Super-Linter

"""
import sys
import unittest

import superlinter

if __name__ == '__main__':
    # Guess who's there ? :)
    superlinter.possum()

    # noinspection PyTypeChecker
    run_result = unittest.TextTestRunner(verbosity=2).run(superlinter.tests.test_superlinter.test_suite.suite())
    if run_result.wasSuccessful():
        sys.exit(0)
    else:
        sys.exit(1)
