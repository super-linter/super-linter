#!/usr/bin/env python3
"""
Run super-linter

@author: Nicolas Vuillamy
"""

from superlinter import SuperLinter

# Run Super-Linter
SuperLinter({'cli': True}).run()
