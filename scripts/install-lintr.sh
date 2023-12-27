#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache --virtual .r-build-deps \
  g++ \
  gcc \
  libxml2-dev \
  linux-headers \
  make \
  R-dev \
  R-doc

Rscript --no-save /install-r-package-or-fail.R lintr purrr remotes

apk del --no-network --purge .r-build-deps
