#!/usr/bin/env python3
"""
Main Super-Linter class, encapsulating all linters process and reporting

@author: Nicolas Vuillamy
"""

import importlib
import os
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
        if (os.environ["LINTER_RULES_PATH"]):
            self.linterRulesPath = os.environ["LINTER_RULES_PATH"]        
        # Filtering regex (inclusion)
        if (os.environ["FILTER_REGEX_INCLUDE"]):
            self.filterRegexInclude = os.environ["FILTER_REGEX_INCLUDE"]
        # Filtering regex (exclusion)
        if (os.environ["FILTER_REGEX_EXCLUDE"]):
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
        allFiles = os.listdir(self.filesToLintRoot) 
        # to do : make a first filter with self.fileExtensions , self.fileNames, self.filterRegexInclude and self.filterRegexExclude
        # ....
        # Collect matching files for each linter
        for file in allFiles:
            linter.collectFiles(allFiles)

# Run script
SuperLinter().run()
