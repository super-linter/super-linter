#!/usr/bin/env bash

export PYTHONPATH=$PATHONPATH:`pwd`

if [ "${TEST_CASE_RUN}" == "true" ] ; then
  echo "Running test cases"
  ls -1
  if [ -d "/tmp/lint" ]; then
      ls "/tmp/lint" -1
  fi
  python -m superlinter.test
else
  python -m superlinter.run
fi
