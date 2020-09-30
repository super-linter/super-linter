#!/usr/bin/env python3
"""
Use PowerShell to lint Powershell files
https://github.com/PowerShell/PSScriptAnalyzer
"""
import sys

from superlinter import LinterTemplate


class PowershellLinter(LinterTemplate):
    language = "POWERSHELL"
    linter_name = "powershell" if sys.platform == 'win32' else 'pwsh'
    linter_url = "https://github.com/PowerShell/PSScriptAnalyzer"
    config_file_name = ".powershell-psscriptanalyzer.psd1"
    file_extensions = ['.ps1', '.psm1', '.psd1', '.ps1xml', '.pssc', '.psrc', '.cdxml']

    # Build the CLI command to call to lint a file with a powershell script
    def build_lint_command(self, file):
        pwsh_script = ["Invoke-ScriptAnalyzer -EnableExit"]
        if self.config_file is not None:
            pwsh_script[0] += ' -Settings ' + self.config_file
        pwsh_script[0] += ' -Path ' + file
        cmd = [("powershell" if sys.platform == 'win32' else 'pwsh'),
               '-NoProfile',
               '-NoLogo',
               '-Command', '\n'.join(pwsh_script)
               ]
        return cmd

    # Build the CLI command to get linter version
    def build_version_command(self):
        cmd = [("powershell" if sys.platform == 'win32' else 'pwsh'),
               '-Command', 'Write-Output $PsVersionTable.PsVersion;'
               ]
        return cmd

    # Build regular expression to extract version from output
    # noinspection PyMethodMayBeStatic
    def build_extract_version_regex(self):
        return r"(\d+) *(\d+) *(\d+)"
