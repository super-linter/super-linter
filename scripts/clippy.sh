#!/usr/bin/env bash

pushd "$(dirname "$1")" || exit 1

cargo-clippy

rc=$?

popd || exit 1

exit $rc
