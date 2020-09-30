#!/usr/bin/env python3
"""
Run super-linter

"""

import re


# Center the string and complete blanks with hyphens (-)
def format_hyphens(str_in):
    if str_in != "":
        str_in = ' ' + str_in + ' '
    return '{s:{c}^{n}}'.format(s=str_in, n=100, c='-')


def file_contains(file_name, regex_list):
    with open(file_name) as f:
        content = f.read()
        for regex in regex_list:
            if re.match(regex, content, re.MULTILINE):
                return True
    return False


def get_dict_string_list(dict, key, default):
    if key in dict:
        return dict[key].split(',')
    return default
