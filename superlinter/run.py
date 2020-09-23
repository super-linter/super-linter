#!/usr/bin/env python3
"""
Run super-linter

@author: Nicolas Vuillamy
"""

import superlinter

# Guess who's there ? :)
superlinter.possum()

# Run Super-Linter
superlinter.SuperLinter({'cli': True}).run()
