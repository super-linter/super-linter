#!/usr/bin/env python3
"""
Root class for PHP linters
"""

from superlinter import LinterTemplate


class PhpLinterRoot(LinterTemplate):
    language = "PHP"
    file_extensions = ['.php']
