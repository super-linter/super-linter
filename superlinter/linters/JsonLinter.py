#!/usr/bin/env python3
"""
Use jsonlint to lint JSON files
https://github.com/zaach/jsonlint
"""

from superlinter import LinterTemplate


class JsonLinter(LinterTemplate):
    language = "JSON"
    linter_name = "jsonlint"
    linter_url = "https://github.com/zaach/jsonlint"
    file_extensions = ['.json']

    version_command_return_code = 1  # Strangely, ok return code of jsonlint --version is 1
