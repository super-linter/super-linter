#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

@author: Nicolas Vuillamy
"""
import unittest

from superlinter.tests.test_superlinter.helpers import utilstest


class SuperLinterTest(unittest.TestCase):
    def setUp(self):
        utilstest.linter_test_setup()

    def test_logging_level_info(self):
        super_linter, output = utilstest.call_super_linter({"LOG_LEVEL": 'INFO'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn("[INFO]", output)
        self.assertNotIn("[DEBUG]", output)

    def test_logging_level_debug(self):
        super_linter, output = utilstest.call_super_linter({"LOG_LEVEL": 'DEBUG'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn("[INFO]", output)
        self.assertIn("[DEBUG]", output)

    def test_disable_language(self):
        super_linter, output = utilstest.call_super_linter({"VALIDATE_JAVASCRIPT": 'false'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        utilstest.assert_is_skipped('JAVASCRIPT_ES', output, self)
        utilstest.assert_is_skipped('JAVASCRIPT_STANDARD', output, self)

    def test_disable_linter(self):
        super_linter, output = utilstest.call_super_linter({"VALIDATE_JAVASCRIPT_ES": 'false'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        utilstest.assert_is_skipped('JAVASCRIPT_ES', output, self)
        self.assertIn('Linting [JAVASCRIPT] files with [standard]', output)

    def test_enable_only_one_linter(self):
        super_linter, output = utilstest.call_super_linter({"VALIDATE_JAVASCRIPT_ES": 'true'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn('Linting [JAVASCRIPT] files with [eslint]', output)
        utilstest.assert_is_skipped('JAVASCRIPT_STANDARD', output, self)
        utilstest.assert_is_skipped('GROOVY', output, self)

    def test_enable_only_one_language(self):
        super_linter, output = utilstest.call_super_linter({"VALIDATE_JAVASCRIPT": 'true'})
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn('Linting [JAVASCRIPT] files with [eslint]', output)
        self.assertIn('Linting [JAVASCRIPT] files with [standard]', output)
        utilstest.assert_is_skipped('GROOVY', output, self)
