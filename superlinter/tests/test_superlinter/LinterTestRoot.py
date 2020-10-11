# !/usr/bin/env python3
"""
Unit tests for Linter class (and sub-classes)
"""

from superlinter import utils
from superlinter.tests.test_superlinter.helpers import utilstest


class LinterTestRoot:
    descriptor_id = None
    linter_name = None

    def get_linter_instance(self):
        return utils.build_linter(self.descriptor_id, self.linter_name)

    def test_success(self):
        utilstest.linter_test_setup()
        utilstest.test_linter_success(self.get_linter_instance(), self)

    def test_failure(self):
        utilstest.linter_test_setup()
        utilstest.test_linter_failure(self.get_linter_instance(), self)

    def test_get_linter_version(self):
        utilstest.linter_test_setup()
        utilstest.test_get_linter_version(self.get_linter_instance(), self)

    def test_reports(self):
        utilstest.linter_test_setup({'report_type': 'tap'})
        utilstest.test_linter_reports(self.get_linter_instance(), self)
