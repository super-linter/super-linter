#!/usr/bin/env bash

if [ "${TEST_CASE_RUN}" == "true" ]; then
  python /action/lib/test.py
else
  python /action/lib/SuperLinter.py --cli
fi
