#!/usr/bin/env bash

PYTHONPATH=$PYTHONPATH:$(pwd)
export PYTHONPATH

if [ "${TEST_CASE_RUN}" == "true" ] ; then
  # Run build to check if descriptors are valid
  bash build.sh
  # Run test cases with pytest
  echo "RUNNING TEST CASES"
  pytest -v --cov=superlinter --cov-report=xml superlinter/
  PYTEST_STATUS=$?
  echo Pytest exited $PYTEST_STATUS
  # Manage return code
  if [ $PYTEST_STATUS -eq 0 ]; then
    echo "Successfully executed Pytest"
  else
    echo "Error(s) found by Pytest"
    exit 1
  fi
  # Upload to codecov.io
  bash <(curl -s https://codecov.io/bash)

else
  # Normal run
  python -m superlinter.run
fi
