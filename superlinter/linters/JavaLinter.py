#!/usr/bin/env python3
"""
Use checkstyle to lint Java files
https://checkstyle.sourceforge.io/
"""

from superlinter import LinterTemplate


class JavaLinter(LinterTemplate):
    language = "JAVA"
    linter_name = "checkstyle"
    linter_url = "https://checkstyle.sourceforge.io/"
    config_file_name = "sun_checks.xml"
    file_extensions = ['.java']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["java", "-jar", "/usr/bin/checkstyle"]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd
