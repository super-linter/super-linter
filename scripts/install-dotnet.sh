#!/usr/bin/env bash

curl --retry 5 --retry-delay 5 -sLO https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --install-dir /usr/share/dotnet -channel STS -version latest
