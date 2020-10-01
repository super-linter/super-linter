#!/usr/bin/env python3
"""
Use xmllint to lint XML files
http://xmlsoft.org/xmllint.html
"""

from superlinter import LinterTemplate


class XmlLinter(LinterTemplate):
    language = "XML"
    linter_name = "xmllint"
    linter_url = "http://xmlsoft.org/xmllint.html"
    file_extensions = ['.xml']

    # Build regular expression to extract version from output
    # noinspection PyMethodMayBeStatic
    def build_extract_version_regex(self):
        return r"(?<=libxml version )\d+(\d+)+"
