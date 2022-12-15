#!/usr/bin/env bash

# CMD
HELLO_WORLD=$(echo "Hello World" | cut -f1 -d' ' 2>&1)

# Load the error code
ERROR_CODE=$?

# Check the shell
if [ ${ERROR_CODE} -ne 0 ]; then
    echo "We did it!"
    exit 0
else
    echo "We done goofed it..."
    echo "${HELLO_WORLD}"
    exit 1
fi
