#!/usr/bin/env python3
"""
Root class for BASH linters
"""

from superlinter import LinterTemplate


class BashLinterRoot(LinterTemplate):
    language = "BASH"
    file_extensions = ['.sh', '.bash', '.dash', '.ksh']
    test_folder = 'shell'
