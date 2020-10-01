#!/usr/bin/env python3
"""
Use PHP Stan to lint PHP files
https://github.com/phpstan/phpstan
"""

from superlinter.linters.PhpLinterRoot import PhpLinterRoot


class PhpPhpStanLinter(PhpLinterRoot):
    linter_name = "phpstan"
    linter_url = "https://github.com/phpstan/phpstan"
    name = "PHP_PHPSTAN"
    config_file_name = 'phpstan.neon'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["phpstan", "analyse", "--no-progress", "--no-ansi"]
        if self.config_file is not None:
            cmd.extend(['-c', self.config_file])
        cmd.append(file)
        return cmd
