#!/usr/bin/env python3
"""
Template class for custom linters: any linter class in /linters folder must inherit from this class
The following list of items can/must be overridden on custom linter local class:
- field descriptor_id (required) ex: "JAVASCRIPT"
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
import glob
import logging
import os
import re
import shutil
import subprocess
import sys

import requests

import superlinter


class Linter:
    # Definition fields: can be overridden at custom linter class level
    descriptor_id = "Field 'descriptor_id' must be overridden at custom linter class level"  # Ex: JAVASCRIPT
    name = None  # If you have several linters for the same language,override with a different name.Ex: JAVASCRIPT_ES
    linter_name = "Field 'linter_name' must be overridden at custom linter class level"  # Ex: eslint
    linter_url = "Field 'linter_url' must be overridden at custom linter class level"  # ex: https://eslint.org/
    test_folder = None  # Override only if different from language.lowercase()

    file_extensions = []  # Array of strings defining file extensions. Ex: ['.js','.cjs']
    file_names = []  # Array of file names. Ex: ['Dockerfile']
    config_file_name = None  # Default name of the configuration file to use with the linter. Ex: '.eslintrc.js'
    files_sub_directory = None
    file_contains = []
    files_names_not_ends_with = []
    active_only_if_file_found = None

    cli_executable = None
    cli_executable_version = None
    cli_config_arg_name = '-c'  # Default arg name for configurations to use in linter CLI call
    cli_config_extra_args = []  # Extra arguments to send to cli when a config file is used
    cli_lint_extra_args = []  # Extra arguments to send to cli everytime
    cli_lint_extra_args_after = []  # Extra arguments to send to cli everytime, just before file argument
    cli_version_arg_name = '--version'  # Default arg name for configurations to use in linter version call
    cli_version_extra_args = []  # Extra arguments to send to cli everytime

    version_extract_regex = r"\d+(\.\d+)+"
    version_command_return_code = 0  # If linter --version does not return 0 when it is in success, override. ex: 1

    report_type = ''  # Can be tap or tap_detailed
    report_folder = ''

    # Constructor: Initialize Linter instance with name and config variables
    def __init__(self, params=None, linter_config=None):
        self.linter_version_cache = None
        # Initialize with configuration data
        for key, value in linter_config.items():
            self.__setattr__(key, value)
        # Initialize parameters
        if params is None:
            params = {'default_linter_activation': False,
                      'enable_descriptors': [],
                      'enable_linters': [],
                      'disable_descriptors': [],
                      'disable_linters': [],
                      'post_linter_status': True}

        self.is_active = params['default_linter_activation']
        if self.name is None:
            self.name = self.descriptor_id
        if self.cli_executable is None:
            self.cli_executable = self.linter_name
        if self.cli_executable_version is None:
            self.cli_executable_version = self.cli_executable
        if self.test_folder is None:
            self.test_folder = self.descriptor_id.lower()

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
            self.post_linter_status = params['post_linter_status'] if "post_linter_status" in params else False
            self.github_api_url = params['github_api_url'] if "github_api_url" in params else None

            self.report_type = params['report_type'] if "report_type" in params else ''
            self.report_folder = params['report_folder'] if "report_folder" in params else ''

            self.load_config_vars()

            # Manage sub-directory filter if defined
            if self.files_sub_directory is not None:
                self.files_sub_directory = os.environ.get(f"{self.descriptor_id}_DIRECTORY", self.files_sub_directory)
                if not os.path.exists(self.workspace + os.path.sep + self.files_sub_directory):
                    self.is_active = False

            # Some linters require a file to be existing, else they are deactivated ( ex: .editorconfig )
            if self.active_only_if_file_found is not None:
                found_files = glob.glob(f"{self.workspace}/**/{self.active_only_if_file_found}", recursive=True)
                if len(found_files) == 0:
                    self.is_active = False

            # Runtime items
            self.files = []
            self.status = "success"
            self.number_errors = 0
            self.files_lint_results = {}
            self.report_lines = []

    # Enable or disable linter
    def manage_activation(self, params):
        if self.name in params['enable_linters']:
            self.is_active = True
        elif self.name in params['disable_linters']:
            self.is_active = False
        elif self.descriptor_id in params['disable_descriptors'] or self.name in params['disable_linters']:
            self.is_active = False
        elif self.descriptor_id in params['enable_descriptors']:
            self.is_active = True
        elif "VALIDATE_" + self.name in os.environ and os.environ["VALIDATE_" + self.name] == 'false':
            self.is_active = False
        elif "VALIDATE_" + self.descriptor_id in os.environ and os.environ["VALIDATE_" + self.descriptor_id] == 'false':
            self.is_active = False
        elif "VALIDATE_" + self.name in os.environ and os.environ["VALIDATE_" + self.name] == 'true':
            self.is_active = True
        elif "VALIDATE_" + self.descriptor_id in os.environ and os.environ["VALIDATE_" + self.descriptor_id] == 'true':
            self.is_active = True

    # Manage configuration variables
    def load_config_vars(self):
        # Configuration file name: try first NAME + _FILE_NAME, then LANGUAGE + _FILE_NAME
        if self.name + "_FILE_NAME" in os.environ:
            self.config_file_name = os.environ[self.name + "_FILE_NAME"]
        elif self.descriptor_id + "_FILE_NAME" in os.environ:
            self.config_file_name = os.environ[self.descriptor_id + "_FILE_NAME"]

        # Linter rules path: try first NAME + _RULE_PATH, then LANGUAGE + _RULE_PATH
        if self.name + "_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ[self.name + "_RULES_PATH"]
        elif self.descriptor_id + "_RULES_PATH" in os.environ:
            self.linter_rules_path = os.environ[self.descriptor_id + "_RULES_PATH"]

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
        elif self.descriptor_id + "_FILTER_REGEX_INCLUDE" in os.environ:
            self.filter_regex_include = os.environ[self.descriptor_id + "_FILTER_REGEX_INCLUDE"]

        # Exclude regex: try first NAME + _FILTER_REGEX_EXCLUDE, then LANGUAGE + _FILTER_REGEX_EXCLUDE
        if self.name + "_FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ[self.name + "_FILTER_REGEX_EXCLUDE"]
        elif self.descriptor_id + "_FILTER_REGEX_EXCLUDE" in os.environ:
            self.filter_regex_exclude = os.environ[self.descriptor_id + "_FILTER_REGEX_EXCLUDE"]

    # Processes the linter
    def run(self):
        self.display_header()
        self.before_lint_files()

        index = 0
        for file in self.files:
            index = index + 1
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
            logging.info(superlinter.utils.format_hyphens(""))
            self.update_report(file, return_code, stdout, index)
        self.generate_reports()

    def display_header(self):
        linter_version = self.get_linter_version()
        # Linter header prints
        msg = "Linting [" + self.descriptor_id + "] files with [" + self.linter_name + ' v' + \
              linter_version + '] (' + self.linter_url + ')'
        logging.info("")
        logging.info(superlinter.utils.format_hyphens(""))
        logging.info(superlinter.utils.format_hyphens(msg))
        if self.descriptor_id != self.name:
            logging.info(superlinter.utils.format_hyphens("Key: [" + self.name + "]"))
        if self.config_file is not None:
            logging.info(superlinter.utils.format_hyphens("Rules: [" + self.config_file + "]"))
        else:
            logging.info(superlinter.utils.format_hyphens("Rules: identified by [" + self.linter_name + ']'))
        logging.info(superlinter.utils.format_hyphens(""))
        logging.info("")

    # Collect all files that will be analyzed by the current linter
    def collect_files(self, all_files):
        # Filter all files to keep only the ones matching with the current linter
        for file in all_files:
            if self.filter_regex_include is not None and re.search(self.filter_regex_include, file) is None:
                continue
            elif self.filter_regex_exclude is not None and re.search(self.filter_regex_exclude, file) is not None:
                continue
            elif self.files_sub_directory is not None and self.files_sub_directory not in file:
                continue
            elif not superlinter.utils.check_file_extension_or_name(file, self.file_extensions, self.file_names):
                continue
            elif file.endswith(tuple(self.files_names_not_ends_with)):
                continue
            elif len(self.file_contains) > 0 and not superlinter.utils.file_contains(file, self.file_contains):
                continue
            self.files += [file]

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
        if type(command) == str:
            # Call linter with a sub-process
            process = subprocess.run(command,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT,
                                     shell=True,
                                     executable=shutil.which('bash') if sys.platform == 'win32' else '/bin/bash')
        else:
            # Use full executable path if we are on Windows
            if sys.platform == 'win32':
                cli_absolute = shutil.which(command[0])
                if cli_absolute is not None:
                    command[0] = cli_absolute
                else:
                    msg = "Unable to find command: " + command[0]
                    logging.error(msg)
                    return errno.ESRCH, msg

            # Call linter with a sub-process (RECOMMENDED: with a list of strings corresponding to the command)
            process = subprocess.run(command,
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT)
        return_code = process.returncode
        return_stdout = superlinter.utils.decode_utf8(process.stdout)
        # Return linter result
        return return_code, return_stdout

    # Returns linter version (can be overridden in special cases, like version has special format)
    def get_linter_version(self):
        if self.linter_version_cache is not None:
            return self.linter_version_cache
        version_output = self.get_linter_version_output()
        reg = self.version_extract_regex
        if type(reg) == str:
            reg = re.compile(reg)
        m = re.search(reg, version_output)
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
            output = superlinter.utils.decode_utf8(process.stdout)
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

    def update_report(self, file, return_code, stdout, index):
        if self.report_type.startswith('tap'):
            tap_status = "ok" if return_code == 0 else 'not ok'
            file_tap_lines = [f"{tap_status} {str(index)} - {os.path.basename(file)}"]
            if self.report_type == 'tap_detailed' and stdout != '' and return_code != 0:
                std_out_tap = stdout.rstrip(f" {os.linesep}") + os.linesep
                std_out_tap = "\\n".join(std_out_tap.split(os.linesep))
                std_out_tap = std_out_tap.replace(':', ' ')
                detailed_lines = ["  ---",
                                  f"  message: {std_out_tap}",
                                  "  ..."]
                file_tap_lines += detailed_lines
            self.report_lines += file_tap_lines

    def generate_reports(self):
        # Create TAP file if necessary
        if self.report_type.startswith('tap'):
            tap_report_lines = ["TAP version 13",
                                f"1..{str(len(self.files))}"]
            tap_report_lines += self.report_lines
            tap_file_name = f"{self.report_folder}{os.path.sep}super-linter-{self.name}.tap"
            if not os.path.exists(os.path.dirname(tap_file_name)):
                os.makedirs(os.path.dirname(tap_file_name))
            with open(tap_file_name, 'w', encoding='utf-8') as tap_file:
                tap_file_content = "\n".join(tap_report_lines) + "\n"
                tap_file.write(tap_file_content)

        # Post status to Github
        if self.post_linter_status is True and 'GITHUB_REPOSITORY' in os.environ and 'GITHUB_SHA' in os.environ and \
                'GITHUB_TOKEN' in os.environ and 'GITHUB_RUN_ID' in os.environ:
            github_repo = os.environ['GITHUB_REPOSITORY']
            sha = os.environ['GITHUB_SHA']
            run_id = os.environ['GITHUB_RUN_ID']
            success_msg = 'No errors were found in the linting process'
            error_msg = 'Errors were detected, please view logs'
            url = f"{self.github_api_url}/repos/{github_repo}/statuses/{sha}"
            headers = {
                'accept': 'application/vnd.github.v3+json',
                'authorization': f"Bearer {os.environ['GITHUB_TOKEN']}",
                'content-type': 'application/json'
            }
            target_url = f"https://github.com/{github_repo}/actions/runs/{run_id}"
            data = {
                'state': self.status,
                'target_url': target_url,
                'description': success_msg if self.status == 'success' else error_msg,
                'context': f"--> Lint: {self.descriptor_id} with {self.linter_name}"
            }
            response = requests.post(url,
                                     headers=headers,
                                     json=data)
            if 200 <= response.status_code < 299:
                logging.debug(f"Successfully posted Github Status for {self.descriptor_id} with {self.linter_name}")
            else:
                logging.error(
                    f"Error posting Github Status for {self.descriptor_id}"
                    f"with {self.linter_name}: {response.status_code}")
                logging.error(f"GitHub API response: {response.text}")
        else:
            logging.debug(f"Skipped post of Github Status for {self.descriptor_id} with {self.linter_name}")

    ########################################
    # Methods that can be overridden below #
    ########################################

    def before_lint_files(self):
        pass

    # Build the CLI command to call to lint a file (can be overridden)
    def build_lint_command(self, file):
        cmd = [self.cli_executable]
        # Add other lint cli arguments if defined
        cmd += self.cli_lint_extra_args
        # Add config arguments if defined
        if self.config_file is not None:
            if self.cli_config_arg_name.endswith('='):
                cmd += [self.cli_config_arg_name + self.config_file]
            else:
                cmd += [self.cli_config_arg_name, self.config_file]
            cmd += self.cli_config_extra_args
        # Add other lint cli arguments after other arguments if defined
        cmd += self.cli_lint_extra_args_after
        # Append file in command arguments
        cmd += [file]
        return cmd

    # Build the CLI command to get linter version (can be overridden if --version is not the way to get the version)
    def build_version_command(self):
        cmd = [self.cli_executable_version]
        cmd += self.cli_version_extra_args
        cmd += [self.cli_version_arg_name]
        return cmd
