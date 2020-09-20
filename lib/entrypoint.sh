#!/usr/bin/env bash

if [ "${TEST_CASE_RUN}" == "true" ]; then
  python test.py
else
  python SuperLinter.py --cli
fi
