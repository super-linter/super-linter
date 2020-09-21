#!/usr/bin/env python3
"""
Unit tests for SuperLinter class

@author: Nicolas Vuillamy
"""
import contextlib
import io
import os
import unittest

from lib.superlinter import SuperLinter


class SuperLinterTest(unittest.TestCase):
    def setUp(self):
        root_dir = os.path.dirname(os.path.abspath(__file__))+'/../../../..'
        os.environ["LINTER_RULES_PATH"] = root_dir+'/.github/linters'
        os.environ["LINT_FILES_ROOT_PATH"] = root_dir+'/.automation/test'
        os.environ["LOG_LEVEL"] = "INFO"

    def test_logging_level_info(self):
        usage_stdout = io.StringIO()
        with contextlib.redirect_stdout(usage_stdout):
            super_linter = SuperLinter()
            super_linter.run()
        output = usage_stdout.getvalue().strip()
        print(output)
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn("[INFO]", output)
        self.assertNotIn("[DEBUG]", output)

    def test_logging_level_debug(self):
        usage_stdout = io.StringIO()
        with contextlib.redirect_stdout(usage_stdout):
            os.environ["LOG_LEVEL"] = "DEBUG"
            super_linter = SuperLinter()
            super_linter.run()
        output = usage_stdout.getvalue().strip()
        print(output)
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn("[INFO]", output)
        self.assertIn("[DEBUG]", output)

    def test_disable_language(self):
        usage_stdout = io.StringIO()
        with contextlib.redirect_stdout(usage_stdout):
            os.environ["VALIDATE_JAVASCRIPT"] = 'false'
            super_linter = SuperLinter()
            super_linter.run()
            del os.environ["VALIDATE_JAVASCRIPT"]
        output = usage_stdout.getvalue().strip()
        print(output)
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn('Skipped [JAVASCRIPT] linter [eslint]: Deactivated', output)

    def test_disable_linter(self):
        usage_stdout = io.StringIO()
        with contextlib.redirect_stdout(usage_stdout):
            os.environ["VALIDATE_JAVASCRIPT_ES"] = 'false'
            super_linter = SuperLinter()
            super_linter.run()
            del os.environ["VALIDATE_JAVASCRIPT_ES"]
        output = usage_stdout.getvalue().strip()
        print(output)
        self.assertTrue(len(super_linter.linters) > 0, "Linters have been created and run")
        self.assertIn('Skipped [JAVASCRIPT] linter [eslint]: Deactivated', output)



