#!/usr/bin/env python3
"""
Use dotnet-format to lint CSharp files
"""

import os.path

from superlinter import Linter


class CSharpDotnetFormatLinter(Linter):

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        commands = [f'cd "{os.path.realpath(os.path.dirname(file))}" || exit 1',
                    " ".join(super().build_lint_command(os.path.basename(file))) + ' | tee /dev/tty2 2>&1',
                    'exit "${PIPESTATUS[0]}"']
        return " && ".join(commands)
