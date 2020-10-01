#!/usr/bin/env bash

PYTHONPATH=$PYTHONPATH:$(pwd)
export PYTHONPATH

if [ "${TEST_CASE_RUN}" == "true" ] ; then
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
  pytest --cov=superlinter --cov-report=xml superlinter/
  bash <(curl -s https://codecov.io/bash)
else
  python -m superlinter.run
fi
