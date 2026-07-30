#!/usr/bin/env bash

set -euo pipefail

# fprettify always exits with 0, even when the files it processed need
# formatting changes, and even when it fails to process an input file, in
# which case it reports errors on stderr. Because of this, in check-only
# mode (--diff), we can't rely on the fprettify exit code to detect if
# files need formatting. This wrapper captures fprettify output (the diff
# on stdout, eventual error messages on stderr) and exits with a non-zero
# code if fprettify emitted any output, because an empty output is the
# only reliable indication that fprettify processed all the input files
# without errors, and that no file needs formatting changes.

DIFF_MODE="false"
for arg in "$@"; do
  if [[ "${arg}" == "--diff" ]]; then
    DIFF_MODE="true"
    break
  fi
done

# In fix mode (no --diff), fprettify formats files in place, so there's no
# need to inspect its output.
if [[ "${DIFF_MODE}" == "false" ]]; then
  exec fprettify "$@"
fi

exit_code=0
output="$(fprettify "$@" 2>&1)" || exit_code=$?

if [[ ${exit_code} -ne 0 ]]; then
  echo "${output}" >&2
  exit "${exit_code}"
fi

if [[ -n "${output}" ]]; then
  echo "${output}"
  exit 1
fi
