#!/usr/bin/env python3
"""
Run super-linter

"""

# Center the string and complete blanks with hyphens (-)
import glob
import importlib
import os
import re

import yaml

from superlinter.Linter import Linter


# Returns directory where all .yml language descriptors are defined
def get_descriptor_dir():
    return os.path.dirname(os.path.abspath(__file__)) + '/descriptors'


# List all defined linters
def list_all_linters(linters_init_params=None):
    descriptor_files = list_descriptor_files()
    linters = []
    for descriptor_file in descriptor_files:
        descriptor_linters = build_descriptor_linters(descriptor_file, linters_init_params)
        linters += descriptor_linters
    return linters


# List all descriptor files (one by language)
def list_descriptor_files():
    descriptors_dir = get_descriptor_dir()
    linters_glob_pattern = descriptors_dir + '/*.yml'
    descriptor_files = []
    for descriptor_file in glob.glob(linters_glob_pattern):
        descriptor_files += [descriptor_file]
    return descriptor_files


# Build linter instances from a descriptor file name, and initialize them
def build_descriptor_linters(file, linter_init_params=None, linter_names=None):
    if linter_names is None:
        linter_names = []
    linters = []
    # Dynamic generation from yaml
    with open(file) as f:
        language_descriptor = yaml.load(f, Loader=yaml.FullLoader)

        # Build common attributes
        common_attributes = {}
        for attr_key, attr_value in language_descriptor.items():
            if attr_key not in ['linters', 'install']:
                common_attributes[attr_key] = attr_value

        # Browse linters defined for language
        for linter_descriptor in language_descriptor.get('linters'):
            if len(linter_names) > 0 and linter_descriptor['linter_name'] not in linter_names:
                continue

            # Use custom class if defined in file
            linter_class = Linter
            if linter_descriptor.get('class'):
                linter_class_file_name = os.path.splitext(os.path.basename(linter_descriptor.get('class')))[0]
                linter_module = importlib.import_module('.linters.' + linter_class_file_name,
                                                        package=__package__)
                linter_class = getattr(linter_module, linter_class_file_name)

            # Create a Linter class instance by linter
            instance_attributes = {**common_attributes, **linter_descriptor}
            linter_instance = linter_class(linter_init_params, instance_attributes)
            linters += [linter_instance]

    return linters


# Build a single linter instance from language and linter name
def build_linter(language, linter_name):
    language_descriptor_file = get_descriptor_dir() + os.path.sep + language.lower() + '.yml'
    assert os.path.exists(language_descriptor_file), f"Unable to find {language_descriptor_file}"
    linters = build_descriptor_linters(language_descriptor_file, None, [linter_name])
    assert len(linters) == 1, f"Unable to find linter {linter_name} in {language_descriptor_file}"
    return linters[0]


def check_file_extension_or_name(file, file_extensions, file_names):
    base_file_name = os.path.basename(file)
    filename, file_extension = os.path.splitext(base_file_name)
    if len(file_extensions) > 0 and file_extension in file_extensions:
        return True
    elif len(file_names) > 0 and filename in file_names:
        return True
    elif len(file_extensions) == 1 and file_extensions[0] == "*":
        return True
    return False


# Center the string and complete blanks with hyphens (-)
def format_hyphens(str_in):
    if str_in != "":
        str_in = ' ' + str_in + ' '
    return '{s:{c}^{n}}'.format(s=str_in, n=100, c='-')


# Can receive a list of strings, regexes, or even mixed :)
def file_contains(file_name, regex_or_str_list):
    with open(file_name) as f:
        content = f.read()
        for regex_or_str in regex_or_str_list:
            if hasattr(regex_or_str, 'match'):
                if regex_or_str.match(content, re.MULTILINE):
                    return True
            else:
                if regex_or_str in content:
                    return True
    return False


def get_dict_string_list(dict_obj, key, default):
    if key in dict_obj:
        return dict_obj[key].split(',')
    return default


def decode_utf8(stdout):
    # noinspection PyBroadException
    try:
        res = stdout.decode("utf-8")
    except Exception:
        res = str(stdout)
    return res
