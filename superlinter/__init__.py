#!/usr/bin/env python3
from .LinterTemplate import LinterTemplate
from .SuperLinter import SuperLinter
from .linters import *
from .possum import possum
from .tests.test_superlinter.test_suite import suite

__all__ = [
    'SuperLinter',
    'LinterTemplate',
    'possum',
    'suite'
]
