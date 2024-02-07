#!/usr/bin/env bash

set -euo pipefail

curl --retry 5 --retry-delay 5 -sLO https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --install-dir /usr/share/dotnet --version 8.0.101
rm -rfv ./dotnet-install.sh
