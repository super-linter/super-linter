#!/usr/bin/env python3
"""
Main Super-Linter class, encapsulating all linters process and reporting

@author: Nicolas Vuillamy
"""

import glob
import importlib
import logging
import os
import re
import sys
from collections import OrderedDict

from terminaltables import AsciiTable

from superlinter import utils


class SuperLinter:

    # Constructor: Load global config, linters & compute file extensions
    def __init__(self, params=None):
        if params is None:
            params = {}
        self.initialize_logger()
        self.display_header()
        self.rules_location = '/action/lib/.automation'
        self.github_api_uri = 'https://api.github.com'
        self.github_workspace = os.environ['GITHUB_WORKSPACE'] if "GITHUB_WORKSPACE" in os.environ else '/tmp/lint'
        self.linter_rules_path = '.github/linters'
        self.filter_regex_include = None
        self.filter_regex_exclude = None
        self.cli = params['cli'] if "cli" in params else False
        self.default_linter_activation = True

        self.load_config_vars()

        self.linters = []
        self.file_extensions = []
        self.file_names = []
        self.status = "success"

        self.load_linters()
        self.compute_file_extensions()

    # Collect files, run linters on them and write reports
    def run(self):

        # Collect files for each identified linter
        self.collect_files()

        # Display collection summary in log
        table_data = [["Language", "Linter", "Criteria", "Matching files"]]
        for linter in self.linters:
            if len(linter.files) > 0:
                all_criteria = linter.file_extensions + linter.file_names
                table_data.append([linter.language,
                                   linter.linter_name,
                                   '|'.join(all_criteria),
                                   str(len(linter.files))])
        table = AsciiTable(table_data)
        table.title = "----MATCHING LINTERS"
        logging.info("")
        for table_line in table.table.splitlines():
            logging.info(table_line)
        logging.info("")

        # Run linters
        for linter in self.linters:
            if linter.is_active is True:
                linter.run()
                if linter.status != 'success':
                    self.status = 'error'
        self.manage_reports()
        self.check_results()

    # Manage configuration variables 
    def load_config_vars(self):
        # Linter rules root path
        if "LINTER_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ["LINTER_RULES_PATH"]
        # Filtering regex (inclusion)
        if "FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ["FILTER_REGEX_INCLUDE"]
        # Filtering regex (exclusion)
        if "FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ["FILTER_REGEX_EXCLUDE"]
        # Define default value for linter validation
        for env_var in os.environ:
            if env_var.startswith('VALIDATE_') and env_var != 'VALIDATE_ALL_CODE_BASE':
                if os.environ[env_var] == 'true':
                    self.default_linter_activation = False

    # List all classes from /linter folder then instantiate each of them
    def load_linters(self):
        linters_dir = os.path.dirname(os.path.abspath(__file__)) + '/linters'
        linters_glob_pattern = linters_dir + '/*Linter.py'
        for file in glob.glob(linters_glob_pattern):
            linter_class_file_name = os.path.splitext(os.path.basename(file))[0]
            linter_module = importlib.import_module('.linters.' + linter_class_file_name, package=__package__)
            linter_class = getattr(linter_module, linter_class_file_name)
            linter = linter_class({'linter_rules_path': self.linter_rules_path,
                                   'default_linter_activation': self.default_linter_activation})
            if linter.is_active is False:
                logging.info('Skipped [' + linter.language + '] linter [' + linter.linter_name + ']: Deactivated')
                continue
            self.linters.append(linter)

    # Define all file extensions to browse
    def compute_file_extensions(self):
        for linter in self.linters:
            self.file_extensions.extend(linter.file_extensions)
            self.file_names.extend(linter.file_names)
        # Remove duplicates
        self.file_extensions = list(OrderedDict.fromkeys(self.file_extensions))
        self.file_names = list(OrderedDict.fromkeys(self.file_names))

    # Collect list of files matching extensions and regex
    def collect_files(self):
        # List all files of root directory
        logging.info(
            'Listing all files in directory [' + os.path.dirname(os.path.abspath(self.github_workspace)) + ']')
        all_files = list()
        for (dirpath, dirnames, filenames) in os.walk(self.github_workspace):
            all_files += [os.path.join(dirpath, file) for file in filenames]

        # Filter files according to fileExtensions, fileNames , filterRegexInclude and filterRegexExclude
        filtered_files = []
        for file in all_files:
            base_file_name = os.path.basename(file)
            filename, file_extension = os.path.splitext(base_file_name)
            if self.filter_regex_include is not None and re.search(self.filter_regex_include, file) is None:
                continue
            if self.filter_regex_exclude is not None and re.search(self.filter_regex_exclude, file) is not None:
                continue
            elif file_extension in self.file_extensions:
                filtered_files.append(file)
            elif filename in self.file_names:
                filtered_files.append(file)

        logging.info('Kept [' + str(len(filtered_files)) + '] files on [' + str(len(all_files)) + '] found files')

        # Collect matching files for each linter
        for linter in self.linters:
            linter.collect_files(filtered_files)
            if len(linter.files) == 0:
                linter.is_active = False

    # noinspection PyArgumentList
    @staticmethod
    def initialize_logger():
        logging_level_key = os.environ['LOG_LEVEL'] if "LOG_LEVEL" in os.environ else 'INFO'
        logging_level_list = {'INFO': logging.INFO,
                              "DEBUG": logging.DEBUG,
                              "WARNING": logging.WARNING,
                              "ERROR": logging.ERROR,
                              # Previous values for v3 ascending compatibility
                              "TRACE": logging.WARNING,
                              "VERBOSE": logging.INFO
                              }
        logging_level = logging_level_list[
            logging_level_key] if logging_level_key in logging_level_list else logging.INFO
        logging.basicConfig(stream=sys.stdout,
                            force=True,
                            level=logging_level,
                            format='%(asctime)s [%(levelname)s] %(message)s')

    @staticmethod
    def display_header():
        # Header prints
        logging.info(utils.format_hyphens(""))
        logging.info(utils.format_hyphens("GitHub Actions Multi Language Linter"))
        logging.info(utils.format_hyphens(""))
        logging.info(
            " - Image Creation Date: " + (
                os.environ['BUILD_DATE'] if "BUILD_DATE" in os.environ else 'No docker image'))
        logging.info(
            " - Image Revision: " + (
                os.environ['BUILD_REVISION'] if "BUILD_REVISION" in os.environ else 'No docker image'))
        logging.info(
            " - Image Version: " + (
                os.environ['BUILD_VERSION'] if "BUILD_VERSION" in os.environ else 'No docker image'))
        logging.info(utils.format_hyphens(""))
        logging.info("The Super-Linter source code can be found at:")
        logging.info(" - https://github.com/github/super-linter")
        logging.info(utils.format_hyphens(""))
        logging.info("")

    def manage_reports(self):
        logging.info("")
        table_data = [["Language", "Linter", "Files with error(s)", "Total files"]]
        for linter in self.linters:
            if linter.is_active is True:
                table_data.append(
                    [linter.language, linter.linter_name, str(linter.number_errors), str(len(linter.files))])
        table = AsciiTable(table_data)
        table.title = "----SUMMARY"
        for table_line in table.table.splitlines():
            logging.info(table_line)
        logging.info("")

    def check_results(self):
        if self.status == 'success':
            logging.info('Successfully linted all files without errors')
        else:
            logging.error('Error(s) has been found during linting')
            if self.cli is True:
                sys.exit(1)
