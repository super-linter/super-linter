#!/usr/bin/env python3
"""
Root linter class for Javascript linters
https://eslint.org/
@author: Nicolas Vuillamy
"""


from superlinter import LinterTemplate


class JavascriptLinterRoot(LinterTemplate):
    language = "JAVASCRIPT"
    file_extensions = ['.js']
