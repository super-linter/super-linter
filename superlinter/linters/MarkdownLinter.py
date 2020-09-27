#!/usr/bin/env python3
"""
Use markdownlint to lint Markdown files
https://github.com/DavidAnson/markdownlint
"""

from superlinter import LinterTemplate


class MarkdownLinter(LinterTemplate):
    language = "MARKDOWN"
    linter_name = "markdownlint"
    linter_url = "https://github.com/DavidAnson/markdownlint"
    config_file_name = ".markdown-lint.yml"
    file_extensions = ['.md']
