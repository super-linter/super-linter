#!/usr/bin/env bash

if [ "${TEST_CASE_RUN}" == "true" ]; then
  python ./superlinter/test.py
else
  python ./superlinter/run.py
fi
