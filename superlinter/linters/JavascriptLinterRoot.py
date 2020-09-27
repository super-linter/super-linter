#!/usr/bin/env python3
"""
Root class for Javascript linters
"""

from superlinter import LinterTemplate


class JavascriptLinterRoot(LinterTemplate):
    language = "JAVASCRIPT"
    file_extensions = ['.js']
