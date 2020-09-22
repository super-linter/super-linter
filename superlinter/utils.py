#!/usr/bin/env python3
"""
Run super-linter

@author: Nicolas Vuillamy
"""


# Center the string and complete blanks with hyphens (-)
def format_hyphens(str_in):
    if str_in != "":
        str_in = ' ' + str_in + ' '
    return '{s:{c}^{n}}'.format(s=str_in, n=100, c='-')
