#!/usr/bin/env bash

export PYTHONPATH=$PATHONPATH:`pwd`

if [ "${TEST_CASE_RUN}" == "true" ] ; then
  echo "RUNNING TEST CASES"
  echo ""
  echo "CURRENT FOLDER CONTENT"
  echo ""
  ls -1
  if [ -d "/tmp/lint" ]; then
      echo "CONTENT OF /tmp/lint"
      echo ""
      ls "/tmp/lint" -1
  fi
  if [ -d "/action" ]; then
      echo "CONTENT OF /action"
      echo ""
      ls "/action" -1
  fi
  python -m superlinter.test
else
  python -m superlinter.run
fi
