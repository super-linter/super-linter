#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache gcompat

# Install zlib
apk add --no-cache --virtual .glibc-build-deps \
  tar \
  zlib \
  zstd

apk del --no-network --purge .glibc-build-deps
