#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache \
  lua5.4

apk add --no-cache --virtual .lua-build-deps \
  gcc \
  lua5.4-dev \
  luarocks5.4 \
  make \
  musl-dev \
  readline-dev

ln -s /usr/bin/lua5.4 /usr/bin/lua

luarocks-5.4 install luacheck
luarocks-5.4 install argparse
luarocks-5.4 install luafilesystem

apk del --no-network --purge .lua-build-deps
