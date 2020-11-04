---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: ''
---

## Describe the bug

<!-- A clear and concise description of what the bug is. -->

## Expected behavior

<!-- A clear and concise description of what you expected to happen. -->

## Steps to Reproduce

<!-- Steps to reproduce the behavior. -->
<!-- To speed up the triaging of your request, try to reproduce the issue running super-linter locally, -->
<!-- pointing to a specific container image tag. -->
<!-- Remember to set ACTIONS_RUNNER_DEBUG=true for complete output -->
<!-- Example: -->
<!--
docker run \
  -e RUN_LOCAL=true \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e DISABLE_ERRORS=false \
  -e ERROR_ON_MISSING_EXEC_BIT=true \
  -e LINTER_RULES_PATH=. \
  -e MULTI_STATUS=false \
  -e VALIDATE_ALL_CODEBASE=true \
  -v $(pwd):/tmp/lint \
  ghcr.io/github/super-linter:v3.13.5
-->

1. Go to '...'
1. Click on '....'
1. Scroll down to '....'
1. See error

## Logs

<!-- Report logs an to help explain your problem. -->

## Additional context

<!-- Add any other relevant information about the problem here. -->
