#!/usr/bin/env bash

export PYTHONPATH=$PATHONPATH:`pwd`

if [ "${TEST_CASE_RUN}" == "true" ]; then
  python -m superlinter.test
else
  python -m superlinter.run
fi
