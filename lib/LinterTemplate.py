#!/usr/bin/env python3
"""
Template class for custom linters: any linter class in /linters folder must inherit from this class
The following list of items can/must be overridden on custom linter local class:
- field language (required)
- field name (optional)
- field config_file_name (required)
- field file_extensions (required)
- method build_lint_command (required)

@author: Nicolas Vuillamy
"""
import logging
import os
import re
import shutil
import subprocess
import sys


# Abstract Linter class
class LinterTemplate:
    # Definition fields: can be overridden at custom linter class level
    language = "Field 'Language' must be overridden at custom linter class level"  # Ex: JAVASCRIPT
    name = None  # If you have several linters for the same language, please override with a different name. Ex: JAVASCRIPT_ES

    config_file_name = None  # Default name of the configuration file to use with the linter. Override at custom linter class level. Ex: '.eslintrc.js'
    file_extensions = []  # Array of strings defining file extensions. Override at custom linter class level. Ex: ['.js','.cjs']
    file_names = []  # Array of file names. Ex: ['Dockerfile']

    # Constructor: Initialize Linter instance with name and config variables
    def __init__(self, params):
        self.linter_rules_path = params['linter_rules_path'] if "linter_rules_path" in params else '.'
        self.config_file = None
        self.filter_regex_include = None
        self.filter_regex_exclude = None
        self.isActive = True
        self.files = []
        if self.name is None:
            self.name = self.language
        self.load_config_vars()

    # Manage configuration variables 
    def load_config_vars(self):
        # Activation / Deactivation of the linter 
        if "VALIDATE_" + self.name is False:
            self.isActive = False
        # Configuration file name 
        if self.name + "_FILE_NAME" in os.environ:
            self.config_file_name = os.environ[self.name + "_FILE_NAME"]
        # Linter rules path
        if self.name + "_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ[self.name + "_RULES_PATH"]
        # Linter config file
        if self.config_file_name is not None and self.config_file_name != "LINTER_DEFAULT":
            self.config_file = os.path.join(self.linter_rules_path,self.config_file_name)
        # Include regex
        if self.name + "_FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ[self.name + "_FILTER_REGEX_INCLUDE"]
        # Exclude regex 
        if self.name + "_FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ[self.name + "_FILTER_REGEX_EXCLUDE"]

    # Processes the linter 
    def run(self):
        for file in self.files:
            return_code, stdout, stderr = self.lint_file(file)
            if return_code == 0:
                logging.info("Successfully linted " + file)
            else:
                logging.error(
                    "Error(s) detected in " + file + "\n" + stderr + "\n" + stdout)

    # Filter files to keep only the ones matching extension or file name
    def collect_files(self, all_files):
        for file in all_files:
            base_file_name = os.path.basename(file)
            filename, file_extension = os.path.splitext(base_file_name)
            if self.filter_regex_include is not None and re.search(self.filter_regex_include, file) is None:
                continue
            elif self.filter_regex_exclude is not None and re.search(self.filter_regex_exclude, file) is not None:
                continue
            elif file_extension in self.file_extensions:
                self.files.append(file)
            elif filename in self.file_names:
                self.files.append(file)

    # lint a single file 
    def lint_file(self, file):
        command = self.build_lint_command(file)
        if sys.platform == 'win32':
            command[0] = shutil.which(command[0])
        logging.debug('Linter command: ' + str(command))
        process = subprocess.run(command,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE)
        return_code = process.returncode
        logging.debug(
            'Linter result: ' + str(return_code) + " " + process.stdout.decode("utf-8") + " " + process.stderr.decode("utf-8"))
        return return_code, process.stdout.decode("utf-8"), process.stderr.decode("utf-8")

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        error_msg = "Method buildLintCommand should be overridden at custom linter class level, to return a shell command string"
        raise Exception(error_msg + "\nself:" + str(self) + "\nfile:" + file)
