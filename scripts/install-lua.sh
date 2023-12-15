#!/usr/bin/env bash

set -euo pipefail

curl --retry 5 --retry-delay 5 -s https://www.lua.org/ftp/lua-5.3.5.tar.gz | tar -xz
cd lua-5.3.5
make linux
make install
cd .. && rm -r lua-5.3.5/

url=$(
  set -euo pipefail
  curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
    https://api.github.com/repos/cvega/luarocks/releases/latest |
    jq -r '.tarball_url'
)
curl --retry 5 --retry-delay 5 -sL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}" | tar -xz
cd cvega-luarocks-6b1aee6
./configure --with-lua-include=/usr/local/include
make
make -b install
cd ..
rm -r cvega-luarocks-6b1aee6

luarocks install luacheck
luarocks install argparse
luarocks install luafilesystem
