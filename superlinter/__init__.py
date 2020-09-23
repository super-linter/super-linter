#!/usr/bin/env python3
from .LinterTemplate import LinterTemplate
from .SuperLinter import SuperLinter
from .possum import possum
from .linters import *
from .tests.test_superlinter.test_suite import suite

__all__ = [
    'SuperLinter',
    'LinterTemplate',
    'possum',
    'suite'
]
