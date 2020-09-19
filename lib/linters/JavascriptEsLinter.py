#!/usr/bin/env python3
"""
Use eslint to lint JS files
@author: Nicolas Vuillamy
"""

import os.path

class JavascriptEsLinter(LinterTemplate):
    language = "JAVASCRIPT"
    name = "JAVASCRIPT_ES"
    configFileName = ".eslintrc.json"
    fileExtensions = ['.js']

    # Build the CLI command to call to lint a file
    def buildLintCommand(file):
        dirName = os.path.dirname(file)
        fileName = os.path.basename(file)
        cmd = "eslint"
        if (self.configFile):
            cmd = cmd + " --no-eslintrc -c "+self.configFile
        return cmd
