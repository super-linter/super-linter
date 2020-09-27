#!/usr/bin/env python3
"""
Run super-linter

"""

import superlinter

# Guess who's there ? :)
superlinter.possum()

# Run Super-Linter
superlinter.SuperLinter({'cli': True}).run()
