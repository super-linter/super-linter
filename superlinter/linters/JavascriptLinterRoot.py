#!/usr/bin/env python3
"""
Root class for Javascript linters
https://eslint.org/
@author: Nicolas Vuillamy
"""

from superlinter import LinterTemplate


class JavascriptLinterRoot(LinterTemplate):
    language = "JAVASCRIPT"
    file_extensions = ['.js']
    test_folder = 'javascript'
