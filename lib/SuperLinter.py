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


class SuperLinter:

    # Constructor: Load global config, linters & compute file extensions
    def __init__(self, params=None):
        if params is None:
            params = {}
        logging_level = params['logging_level'] if "logging_level" in params else logging.INFO
        logging.basicConfig(level=logging_level)

        self.display_header()
        self.rules_location = '/action/lib/.automation'
        self.github_api_uri = 'https://api.github.com'
        self.linter_rules_path = params['linter_rules_path'] if "linter_rules_path" in params else '.github/linters'
        self.files_to_lint_root = params['lint_root_path'] if "lint_root_path" in params else './tmp/lint'
        self.filter_regex_include = None
        self.filter_regex_exclude = None

        self.linters = []
        self.file_extensions = []
        self.file_names = []
        self.status = "success"

        self.load_config_vars()
        self.load_linters()
        self.compute_file_extensions()

    # Collect files, run linters on them and write reports
    def run(self):
        self.collect_files()
        for linter in self.linters:
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
        # Linter rules root path
        if "LINTER_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ["LINTER_RULES_PATH"]
        # Filtering regex (inclusion)
        if "FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ["FILTER_REGEX_INCLUDE"]
        # Filtering regex (exclusion)
        if "FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ["FILTER_REGEX_EXCLUDE"]

    # List all classes from /linter folder then instantiate each of them
    def load_linters(self):
        for file in glob.glob('./linters/*.py'):
            linter_class_file_name = os.path.splitext(os.path.basename(file))[0]
            linter_class = getattr(importlib.import_module('linters.' + linter_class_file_name), linter_class_file_name)
            linter = linter_class({'linter_rules_path': self.linter_rules_path})
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
        all_files = list()
        for (dirpath, dirnames, filenames) in os.walk(self.files_to_lint_root):
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

        # Collect matching files for each linter
        for linter in self.linters:
            linter.collect_files(filtered_files)

    @staticmethod
    def display_header():
        # Header prints
        logging.info("---------------------------------------------")
        logging.info("--- GitHub Actions Multi Language Linter ----")
        logging.info(
            "- Image Creation Date: " + (os.environ['BUILD_DATE'] if "BUILD_DATE" in os.environ else 'No docker image'))
        logging.info(
            "- Image Revision: " + (os.environ['BUILD_REVISION'] if "BUILD_REVISION" in os.environ else 'No docker image'))
        logging.info(
            "- Image Version: " + (os.environ['BUILD_VERSION'] if "BUILD_VERSION" in os.environ else 'No docker image'))
        logging.info("---------------------------------------------")
        logging.info("---------------------------------------------")
        logging.info("The Super-Linter source code can be found at:")
        logging.info(" - https://github.com/github/super-linter")
        logging.info("---------------------------------------------")

    def manage_reports(self):
        logging.info('Reports not implemented yet')

    def check_results(self):
        if self.status == 'success':
            logging.info('Successfully linted all files without errors')
        else:
            logging.error('Error(s) has been found during linting')
            sys.exit(1)

# Run script
if sys.argv is not None and len(sys.argv) > 1 and sys.argv[1] == '--cli':
    # Run Super-Linter
    SuperLinter().run()
