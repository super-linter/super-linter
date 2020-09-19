#!/usr/bin/env python3
"""
Main Super-Linter class, encapsulating all linters process and reporting

@author: Nicolas Vuillamy
"""

import importlib
import os
import re
from glob import glob
from collections import OrderedDict

class SuperLinter:

    defaultRulesLocation = '/action/lib/.automation'
    gitHubApiUri = 'https://api.github.com'
    linterRulesPath = '.github/linters'
    filesToLintRoot = './tmp/lint'

    linters = []
    fileExtensions = []
    fileNames = []

    filterRegexInclude
    filterRegexExclude

    # Constructor: Load global config, linters & compute file extensions
    def __init__():
        loadConfigVars()
        loadLinters()
        computeFileExtensions()

    # Collect files, run linters on them and write reports
    def run():
        files = collectFiles()
        for linter in self.linters:
            linter.run(files)

    # Manage configuration variables 
    def loadConfigVars():
        # Linter rules root path
        if os.environ["LINTER_RULES_PATH"] :
            self.linterRulesPath = os.environ["LINTER_RULES_PATH"]        
        # Filtering regex (inclusion)
        if os.environ["FILTER_REGEX_INCLUDE"] :
            self.filterRegexInclude = os.environ["FILTER_REGEX_INCLUDE"]
        # Filtering regex (exclusion)
        if os.environ["FILTER_REGEX_EXCLUDE"] :
            self.filterRegexExclude = os.environ["FILTER_REGEX_EXCLUDE"]

    # List all classes from /linter folder then instanciate each of them
    def loadLinters():
        for file in glob('/linters'), "*.py"):
            linterClassFileName = os.path.splitext(os.path.basename(file))[0]
            linterClass = getattr(importlib.import_module(linterClassFileName), linterClassFileName)
            linter = linterClass()
            linters.append(linter)

    # Define all file extensions to browse
    def computeFileExtensions():
        for linter in self.linters
            self.fileExtensions.extend(linter.fileExtensions)
            self.fileNames.extend(linter.fileNames)
        # Remove duplicates
        self.fileExtensions=list(OrderedDict.fromkeys(self.fileExtensions))
        self.fileNames=list(OrderedDict.fromkeys(self.fileNames))

    # Collect list of files matchins extensions and regex
    def collectFiles():
        # Lisl all files of root directory
        allFiles = os.listdir(self.filesToLintRoot) 

        # Filter files according to fileExtensions, fileNames , filterRegexInclude and filterRegexExclude
        filteredFiles = []
        for file in allFiles:
            baseFileName = os.path.basename(file)
            filename, file_extension = os.path.splitext(baseFileName)
            if self.filterRegexInclude and re.search(self.filterRegexInclude,file) == None :
                continue 
            if self.filterRegexExclude and re.search(self.filterRegexExclude,file) != None :
                continue 
            elif file_extension in self.fileExtensions
                filteredFiles.append(file)
            elif filename in self.fileNames
                filteredFiles.append(file)

        # Collect matching files for each linter
        for linter in self.linters:
            linter.collectFiles(filteredFiles)

# Run script
if sys.argv[1] == '--cli' :
    SuperLinter().run()
