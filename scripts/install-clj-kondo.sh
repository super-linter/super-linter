#!/usr/bin/env bash

set -euo pipefail

curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo

chmod +x install-clj-kondo

./install-clj-kondo --dir /usr/bin/ --download-dir /usr/bin/ --version "${CLJ_KONDO_VERSION}"
