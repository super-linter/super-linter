#!/usr/bin/env python3
"""
Use dotnet-format to lint C# files
https://dotnet.microsoft.com/
"""

from superlinter import LinterTemplate


class CSharpLinter(LinterTemplate):
    language = "CSHARP"
    linter_name = "dotnet-format"
    linter_url = "https://dotnet.microsoft.com/"
    file_extensions = ['.cs']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["dotnet-format", "--folder", "--check", "--exclude", "/", "--include", file]
        return cmd
