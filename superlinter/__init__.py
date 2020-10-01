#!/usr/bin/env python3
from .LinterTemplate import LinterTemplate
from .SuperLinter import SuperLinter
from .possum import possum
from .tests.test_superlinter.suite import suite

__all__ = [
    'SuperLinter',
    'LinterTemplate',
    'possum',
    'suite'
]
