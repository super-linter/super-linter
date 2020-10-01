#!/usr/bin/env python3
"""
Use Psalm to lint PHP files
https://psalm.dev/
"""

from superlinter.linters.PhpLinterRoot import PhpLinterRoot


class PhpPsalmLinter(PhpLinterRoot):
    linter_name = "psalm"
    linter_url = "https://psalm.dev/"
    name = "PHP_PSALM"
    config_file_name = 'psalm.xml'

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["psalm"]
        if self.config_file is not None:
            cmd.append(f"--config={self.config_file}")
        cmd.append(file)
        return cmd
