#!/usr/bin/env python3
"""
Use bash-exec to lint bash files
"""

from superlinter.linters.BashLinterRoot import BashLinterRoot


class BashBashExecLinter(BashLinterRoot):
    linter_name = "bash-exec"
    linter_url = "Unknown"
    name = "BASH_EXEC"

    # Returns linter version (not implemented for bash-exec)
    def get_linter_version(self):
        return '0.0.0'
