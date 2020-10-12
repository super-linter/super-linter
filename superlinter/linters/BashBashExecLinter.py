#!/usr/bin/env python3
"""
Use bash-exec to lint bash files
"""
import os

import superlinter


class BashBashExecLinter(superlinter.Linter):

    # To execute before linting files
    def before_lint_files(self):
        if os.environ.get('ERROR_ON_MISSING_EXEC_BIT', 'false') == 'true':
            self.disable_errors = False
        else:
            self.disable_errors = True
