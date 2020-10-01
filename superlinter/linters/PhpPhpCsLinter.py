#!/usr/bin/env python3
"""
Use PHP CodeSniffer to lint PHP files
https://github.com/squizlabs/PHP_CodeSniffer
"""

from superlinter.linters.PhpLinterRoot import PhpLinterRoot


class PhpPhpCsLinter(PhpLinterRoot):
    linter_name = "phpcs"
    linter_url = "https://github.com/squizlabs/PHP_CodeSniffer"
    name = "PHP_PHPCS"
    config_file_name = 'phpcs.xml'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["phpcs"]
        if self.config_file is not None:
            cmd.append(f"--standard={self.config_file}")
        cmd.append(file)
        return cmd
