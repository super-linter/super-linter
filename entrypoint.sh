#!/usr/bin/env bash

export PYTHONPATH=$PATHONPATH:`pwd`

ls -1

if [ -d "/tmp/lint" ]
then
    ls "/tmp/lint" -1

if [ "${TEST_CASE_RUN}" == "true" ]; then
  python -m superlinter.test
else
  python -m superlinter.run
fi
