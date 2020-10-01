#!/usr/bin/env python3
"""
Template class for custom linters: any linter class in /linters folder must inherit from this class
The following list of items can/must be overridden on custom linter local class:
- field language (required) ex: "JAVASCRIPT"
- field name (optional) ex: "JAVASCRIPT_ES". If not set, language value is used
- field linter_name (required) ex: "eslint"
- field linter_url (required) ex: "https://eslint.org/"
- field test_folder (optional) ex: "docker". If not set, language.lowercase() value is used
- field config_file_name (optional) ex: ".eslintrc.yml". If not set, no default config file will be searched
- field file_extensions (optional) ex: [".js"]. At least file_extension of file_names must be set
- field file_names (optional) ex: ["Dockerfile"]. At least file_extension of file_names must be set
- method build_lint_command (optional) : Return CLI command to lint a file with the related linter
                                         Default: linter_name + (if config_file(-c + config_file)) + config_file
- method build_version_command (optional): Returns CLI command to get the related linter version.
                                           Default: linter_name --version
- method build_extract_version_regex (optional): Returns RegEx to extract version from version command output
                                                 Default: r"\\d+(\\.\\d+)+"

"""
import errno
import logging
import os
import re
import shutil
import subprocess
import sys

from superlinter import utils
# Abstract Linter class
from superlinter.utils import decode_utf8


class LinterTemplate:
    # Definition fields: can be overridden at custom linter class level
    language = "Field 'Language' must be overridden at custom linter class level"  # Ex: JAVASCRIPT
    name = None  # If you have several linters for the same language,override with a different name.Ex: JAVASCRIPT_ES
    linter_name = "Field 'linter_name' must be overridden at custom linter class level"  # Ex: eslint
    linter_url = "Field 'linter_url' must be overridden at custom linter class level"  # ex: https://eslint.org/
    test_folder = None  # Override only if different from language.lowercase()

    config_file_name = None  # Default name of the configuration file to use with the linter. Ex: '.eslintrc.js'
    file_extensions = []  # Array of strings defining file extensions. Ex: ['.js','.cjs']
    file_names = []  # Array of file names. Ex: ['Dockerfile']

    version_command_return_code = 0  # If linter --version does not return 0 when it is in success, override. ex: 1

    # Constructor: Initialize Linter instance with name and config variables
    def __init__(self, params=None):
        if params is None:
            params = {'default_linter_activation': False,
                      'enable_languages': [],
                      'enable_linters': [],
                      'disable_languages': [],
                      'disable_linters': []}

        self.is_active = params['default_linter_activation']
        if self.name is None:
            self.name = self.language
        if self.test_folder is None:
            self.test_folder = self.language.lower()
        self.linter_version_cache = None

        self.manage_activation(params)

        if self.is_active is True:
            # Config items
            self.linter_rules_path = params['linter_rules_path'] if "linter_rules_path" in params else '.'
            self.default_rules_location = params[
                'default_rules_location'] if "default_rules_location" in params else '.'
            self.workspace = params['workspace'] if "workspace" in params else '.'
            self.config_file = None
            self.filter_regex_include = None
            self.filter_regex_exclude = None

            self.load_config_vars()

            # Runtime items
            self.files = []
            self.status = "success"
            self.number_errors = 0
            self.files_lint_results = {}

    # Enable or disable linter
    def manage_activation(self, params):
        if self.name in params['enable_linters']:
            self.is_active = True
        elif self.name in params['disable_linters']:
            self.is_active = False
        elif self.language in params['disable_languages'] or self.name in params['disable_linters']:
            self.is_active = False
        elif self.language in params['enable_languages']:
            self.is_active = True
        elif "VALIDATE_" + self.name in os.environ and os.environ["VALIDATE_" + self.name] == 'false':
            self.is_active = False
        elif "VALIDATE_" + self.language in os.environ and os.environ["VALIDATE_" + self.language] == 'false':
            self.is_active = False
        elif "VALIDATE_" + self.name in os.environ and os.environ["VALIDATE_" + self.name] == 'true':
            self.is_active = True
        elif "VALIDATE_" + self.language in os.environ and os.environ["VALIDATE_" + self.language] == 'true':
            self.is_active = True

    # Manage configuration variables
    def load_config_vars(self):
        # Configuration file name: try first NAME + _FILE_NAME, then LANGUAGE + _FILE_NAME
        if self.name + "_FILE_NAME" in os.environ:
            self.config_file_name = os.environ[self.name + "_FILE_NAME"]
        elif self.language + "_FILE_NAME" in os.environ:
            self.config_file_name = os.environ[self.language + "_FILE_NAME"]

        # Linter rules path: try first NAME + _RULE_PATH, then LANGUAGE + _RULE_PATH
        if self.name + "_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ[self.name + "_RULES_PATH"]
        elif self.language + "_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ[self.language + "_RULES_PATH"]

        # Linter config file:
        # 1: repo + config_name_name
        # 2: linter_rules_path + config_file_name
        # 3: super-linter default rules path + config_file_name
        if self.config_file_name is not None and self.config_file_name != "LINTER_DEFAULT":
            if os.path.exists(self.workspace + os.path.sep + self.config_file_name):
                self.config_file = self.workspace + os.path.sep + self.config_file_name
            # in user repo ./github/linters folder
            elif os.path.exists(self.linter_rules_path + os.path.sep + self.config_file_name):
                self.config_file = self.linter_rules_path + os.path.sep + self.config_file_name
            # in user repo directory provided in <Linter>RULES_PATH or LINTER_RULES_PATH
            elif os.path.exists(self.default_rules_location + os.path.sep + self.config_file_name):
                self.config_file = self.default_rules_location + os.path.sep + self.config_file_name

        # Include regex :try first NAME + _FILTER_REGEX_INCLUDE, then LANGUAGE + _FILTER_REGEX_INCLUDE
        if self.name + "_FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ[self.name + "_FILTER_REGEX_INCLUDE"]
        elif self.language + "_FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ[self.language + "_FILTER_REGEX_INCLUDE"]

        # Exclude regex: try first NAME + _FILTER_REGEX_EXCLUDE, then LANGUAGE + _FILTER_REGEX_EXCLUDE
        if self.name + "_FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ[self.name + "_FILTER_REGEX_EXCLUDE"]
        elif self.language + "_FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ[self.language + "_FILTER_REGEX_EXCLUDE"]

    # Processes the linter
    def run(self):
        self.display_header()
        for file in self.files:
            logging.info("File:[" + file + "]")
            return_code, stdout = self.lint_file(file)
            if return_code == 0:
                logging.info(
                    " - File:[" + os.path.basename(file) + "] was linted with [" + self.linter_name + "] successfully")
                self.files_lint_results[file] = {"status": "success"}
            else:
                logging.error(" - File:[" + os.path.basename(
                    file) + "] contains error(s) according to [" + self.linter_name + "]")
                logging.error(stdout)
                self.files_lint_results[file] = {"status": "error"}
                self.status = "error"
                self.number_errors = self.number_errors + 1
            logging.info(utils.format_hyphens(""))

    def display_header(self):
        linter_version = self.get_linter_version()
        # Linter header prints
        msg = "Linting [" + self.language + "] files with [" + self.linter_name + ' v' + \
              linter_version + '] (' + self.linter_url + ')'
        logging.info("")
        logging.info(utils.format_hyphens(""))
        logging.info(utils.format_hyphens(msg))
        if self.language != self.name:
            logging.info(utils.format_hyphens("Key: [" + self.name + "]"))
        if self.config_file is not None:
            logging.info(utils.format_hyphens("Rules: [" + self.config_file + "]"))
        else:
            logging.info(utils.format_hyphens("Rules: identified by [" + self.linter_name + ']'))
        logging.info(utils.format_hyphens(""))
        logging.info("")

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
        # Build command using method locally defined on Linter class
        command = self.build_lint_command(file)
        logging.debug('Linter command: ' + str(command))
        return_code, return_output = self.execute_lint_command(command)
        logging.debug(
            'Linter result: ' + str(return_code) + " " + return_output)
        return return_code, return_output

    # Execute a linting command . Can be overridden for special cases, like use of PowerShell script
    # noinspection PyMethodMayBeStatic
    def execute_lint_command(self, command):
        # Use full executable path if we are on Windows
        if sys.platform == 'win32':
            cli_absolute = shutil.which(command[0])
            if cli_absolute is not None:
                command[0] = cli_absolute
            else:
                msg = "Unable to find command: " + command[0]
                logging.error(msg)
                return errno.ESRCH, msg

        # Call linter with a sub-process
        process = subprocess.run(command,
                                 stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT)
        return_code = process.returncode
        return_stdout = decode_utf8(process.stdout)
        # Return linter result
        return return_code, return_stdout

    # Returns linter version (can be overridden in special cases, like version has special format)
    def get_linter_version(self):
        if self.linter_version_cache is not None:
            return self.linter_version_cache
        version_output = self.get_linter_version_output()
        reg = self.build_extract_version_regex()
        m = re.search(reg, version_output, re.MULTILINE)
        if m:
            self.linter_version_cache = '.'.join(m.group().split())
        else:
            logging.error(f"Unable to extract version with regex {str(reg)} from {version_output}")
            self.linter_version_cache = "ERROR"
        return self.linter_version_cache

    # Returns the version of the associated linter (can be overridden in special cases, like version has special format)
    def get_linter_version_output(self):
        command = self.build_version_command()
        if sys.platform == 'win32':
            cli_absolute = shutil.which(command[0])
            if cli_absolute is not None:
                command[0] = cli_absolute
        logging.debug('Linter version command: ' + str(command))
        try:
            process = subprocess.run(command,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT)
            return_code = process.returncode
            output = decode_utf8(process.stdout)
            logging.debug(
                'Linter version result: ' + str(return_code) + " " + output)
        except FileNotFoundError:
            logging.warning('Unable to call command [' + ' '.join(command) + ']')
            return_code = 666
            output = 'ERROR'

        if return_code != self.version_command_return_code:
            logging.warning('Unable to get version for linter [' + self.linter_name + ']')
            logging.warning(' '.join(command) + ' returned output: ' + output)
            return 'ERROR'
        else:
            return output

    ########################################
    # Methods that can be overridden below #
    ########################################

    # Build the CLI command to call to lint a file (can be overridden)
    def build_lint_command(self, file):
        cmd = [self.linter_name]
        if self.config_file is not None:
            cmd.extend(["-c", self.config_file])
        cmd.append(file)
        return cmd

    # Build the CLI command to get linter version (can be overridden if --version is not the way to get the version)
    def build_version_command(self):
        cmd = [self.linter_name, '--version']
        return cmd

    # Build regular expression to extract version from output
    # noinspection PyMethodMayBeStatic
    def build_extract_version_regex(self):
        return r"\d+(\.\d+)+"
