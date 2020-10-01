#!/usr/bin/env python3
"""
Use PHP Built-in linter to lint PHP files
https://www.php.net
"""

from superlinter.linters.PhpLinterRoot import PhpLinterRoot


class PhpBuiltInLinter(PhpLinterRoot):
    linter_name = "php"
    linter_url = "https://www.php.net"
    name = "PHP_BUILTIN"
    config_file_name = 'phpcs.xml'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["php", "-l", file]
        return cmd
