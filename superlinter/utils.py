#!/usr/bin/env python3
"""
Run super-linter

"""

# Center the string and complete blanks with hyphens (-)
import logging
import re


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
    except Exception as e:
        logging.debug('Error while decoding :' + str(e))
        res = str(stdout)
    return res
