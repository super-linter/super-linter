#!/usr/bin/env python3
"""
Use npm-groovy-lint to lint Groovy,Jenkinsfile,Gradle and Nextflow files
@author: Nicolas Vuillamy
"""

import os.path

class GroovyLinter(LinterTemplate):
    language = "GROOVY"
    configFileName = ".groovylintrc.json"
    fileExtensions = ['.groovy','.gvy','.gradle','.nf']
    fileNames = ['Jenkinsfile']

    # Build the CLI command to call to lint a file
    def buildLintCommand(file):
        dirName = os.path.dirname(file)
        fileName = os.path.basename(file)
        cmd = "npm-groovy-lint --failon warning --path "+dirName+" --files "+fileName
        if (self.configFile):
            cmd = cmd + " -c "+self.configFile
        return cmd
