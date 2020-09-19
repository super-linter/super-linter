#!/usr/bin/env python3
"""
Template class for custom linters: any linter class in /linters folder must inherit from this class
The following list of items can/must be overriden on custom linter local class:
- field language (required)
- field name (optional)
- field configFileName (required)
- field fileExtensions (required)
- method buildLintCommand (required)

@author: Nicolas Vuillamy
"""
import logging
import os
import subprocess

# Abstract Linter class 
class LinterTemplate:

    # Definition fields: can be overriden at custom linter class level 
    language = "Field 'Language' must be overriden at custom linter class level" # Ex: JAVASCRIPT
    name # If you have sevel linters for the same language, please override with a different name. Ex: JAVASCRIPT_ES

    configFileName # Default name of the configuration file to use with the linter. Override at custom linter class level. Ex: '.eslintrc.js'
    fileExtensions = [] # Array of strings defining file extensions. Override at custom linter class level. Ex: ['.js','.cjs']
    fileNames = [] # Array of file names. Ex: ['Dockerfile']

    # Runtime fields 
    isActive = True
    files = []

    # Constructor: Initialize Linter instance with name and config variables 
    def __init__():
        if self.name is None:
            self.name = self.language
        loadConfigVars()

    # Manage configuration variables 
    def loadConfigVars():
        # Activation / Deactivation of the linter 
        if (os.environ["VALIDATE_"+self.name] == False):
            self.isActive = False
        # Configuration file name 
        if (os.environ[self.name+"_FILE_NAME"]):
            self.configFileName = os.environ[self.name+"_FILE_NAME"]

    # Processes the linter 
    def run():
        for file in self.files:
            returnCode,stdout,stderr = lintFile(file)
            if (returnCode == 0)
                logging.info("Successfully linted "+file)
            else pylint
                logging.error("Error(s) detected in "+file+"\n"+stderr+"\n"+stdout)

    # Filter files to keep only the ones matching extension or file name
    def collectFiles(allFiles):
        for file in allFiles:
            baseFileName = os.path.basename(file)
            filename, file_extension = os.path.splitext(baseFileName)
            if (file_extension in self.fileExtensions)
                self.files.append(file)
            elif (filename in self.fileNames)
                self.files.append(file)

    # lint a single file 
    def lintFile(file):
        command = buildLintCommand()
        logging.debug('Linter command: '+command)
        process = subprocess.Popen(command,
                             stdout=subprocess.PIPE, 
                             stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        returnCode = process.returncode
        logging.debug('Linter result: '+returnCode+" "+stdout+" "+stderr)
        return (returnCode,stdout,stderr)

    # Build the CLI command to call to lint a file 
    def buildLintCommand(file):
        errorMsg = "Method buildLintCommand should be overriden at custom linter class level, to return a shell command string"
        raise Exception(errorMsg)