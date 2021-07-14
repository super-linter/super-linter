#!/bin/sh
#
# run `clang-format` and output the diff between the file and reformatted version

die() {
  echo "$@" >&2
  exit 1
}

test "$#" -eq 1 || die "usage: $0 <file>"

# Print repo-relative path in the diff header.
# Assuming current directory is the repository root.
label=$(realpath --relative-to . "$1")

clang-format "$1" | diff -u --label "$label" "$1" --label "$label.expected" -
# `diff` exits with non-zero code on non-empty diff
