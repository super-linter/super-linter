#!/usr/bin/env python3
"""
Root class for Python linters
"""

from superlinter import LinterTemplate


class PythonLinterRoot(LinterTemplate):
    language = "PYTHON"
    file_extensions = ['.py']
