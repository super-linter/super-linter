#!/usr/bin/env bash

set -euo pipefail

Rscript --no-save /install-r-package-or-fail.R lintr purrr remotes
