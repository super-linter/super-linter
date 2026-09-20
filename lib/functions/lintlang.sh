#!/usr/bin/env bash

function RunLintLang() {
  local STDERR_FILE_PATH
  STDERR_FILE_PATH="$(mktemp)"

  lintlang scan "$@" 2>"${STDERR_FILE_PATH}"
  local LINTLANG_EXIT_CODE=$?

  cat "${STDERR_FILE_PATH}" >&2

  # LintLang scans the whole workspace, so a repository without an AI
  # instruction surface is valid input. Keep its other non-zero exits intact:
  # they report malformed inputs or lint findings selected by --fail-on.
  if [[ "${LINTLANG_EXIT_CODE}" -eq 1 ]] &&
    [[ "$(cat "${STDERR_FILE_PATH}")" == "Error: No files were successfully scanned." ]]; then
    rm -f "${STDERR_FILE_PATH}"
    return 0
  fi

  rm -f "${STDERR_FILE_PATH}"
  return "${LINTLANG_EXIT_CODE}"
}

RunLintLang "$@"
