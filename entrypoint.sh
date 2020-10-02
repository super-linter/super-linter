#!/usr/bin/env bash

PYTHONPATH=$PYTHONPATH:$(pwd)
export PYTHONPATH

if [ "${TEST_CASE_RUN}" == "true" ] ; then
  # Test cases run
  echo "RUNNING TEST CASES"
  echo ""
  echo "[CURRENT FOLDER CONTENT]"
  ls -a -1
  if [ -d "/tmp/lint" ]; then
      echo "[CONTENT OF /tmp/lint]"
      ls "/tmp/lint" -a -1
      echo ""
  fi
  if [ -d "/action" ]; then
      echo "[CONTENT OF /action]"
      ls "/action" -a -1
      echo ""
  fi
  # Run pytest
  pytest --cov=superlinter --cov-report=xml superlinter/
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
