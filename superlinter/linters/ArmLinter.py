#!/usr/bin/env python3
"""
Use Azure Resource Manager Template Toolkit to lint ARM files
https://github.com/Azure/arm-ttk
"""
import os
import sys

from superlinter import Linter


class ArmLinter(Linter):
    cli_executable = "powershell" if sys.platform == 'win32' else 'pwsh'
    arm_ttk_psd1 = os.environ.get('ARM_TTK_PSD1', '/usr/bin/arm-ttk')

    # Build the CLI command to call to lint a file with a powershell script
    def build_lint_command(self, file):
        pwsh_script = ["Import-Module " + self.arm_ttk_psd1 + " ;"]
        if self.config_file is not None:
            pwsh_script += [
                '${config} = $(Import-PowerShellDataFile -Path "' + self.config_file + '") ;',
                "Test-AzTemplate @config -TemplatePath " + file + " ;"]
        else:
            pwsh_script += ["Test-AzTemplate -TemplatePath " + file + " ;"]
        pwsh_script += ['if (${Error}.Count) {exit 1}']
        cmd = [self.cli_executable,
               '-NoProfile',
               '-NoLogo',
               '-Command', '\n'.join(pwsh_script)
               ]
        return cmd

