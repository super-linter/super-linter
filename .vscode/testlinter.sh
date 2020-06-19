#!/bin/bash
#At this point you can use the debug console to add export GITHUB_WORKSPACE=/path to test only a specific folder
#You can also use ln -s /path /tmp/lint as an alternative
export RUN_LOCAL=true
/workspaces/super-linter/lib/linter.sh