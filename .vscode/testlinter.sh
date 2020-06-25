#!/bin/bash
#At this point you can use the debug console to add export GITHUB_WORKSPACE=/path to test only a specific folder
#You can also use ln -s /path /tmp/lint as an alternative
#If you do neither, this will default to running against the test automation files
tmppath=/tmp/lint
if [ ! -L $tmppath ]; then
  ln -s "$PWD"/.automation/test $tmppath
fi

export RUN_LOCAL=true
# shellcheck source=lib/linter.sh
source "$PWD"/lib/linter.sh