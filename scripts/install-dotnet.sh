#!/usr/bin/env bash

set -euo pipefail

# dotnet-install.sh:
# Possible values: x64, arm, arm64 and s390x
case $TARGETARCH in
amd64)
  target=x64
  ;;
arm64)
  target=arm64
  ;;
*)
  echo "$TARGETARCH is not supported"
  exit 1
  ;;
esac

curl --retry 5 --retry-delay 5 -sLO https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --install-dir /usr/share/dotnet -channel STS -version latest --architecture "$target"
/usr/share/dotnet/dotnet tool install --tool-path /usr/bin dotnet-format --version 5.0.211103
