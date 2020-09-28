#!/usr/bin/env python3
"""
Generic Unit tests for all linter class

"""
import unittest

import superlinter
from superlinter.tests.test_superlinter.helpers import utilstest

linter_classes = superlinter.SuperLinter.list_linter_classes()


class GenericLinterTest(unittest.TestCase):

    def test_generic_linter(self):
        for linter_class in linter_classes:
            with self.subTest(msg="test_get_linter_version for "+linter_class.__name__):
                utilstest.linter_test_setup()
                utilstest.test_linter_success(linter_class(), self)
            with self.subTest(msg="test_linter_success for "+linter_class.__name__):
                utilstest.linter_test_setup()
                utilstest.test_linter_success(linter_class(), self)
            with self.subTest(msg="test_linter_failure for "+linter_class.__name__):
                utilstest.linter_test_setup()
                utilstest.test_linter_failure(linter_class(), self)
