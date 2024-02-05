#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache --virtual .chktex-build-deps \
  autoconf \
  automake \
  gcc \
  git \
  libc-dev \
  libtool \
  make

git clone https://git.savannah.gnu.org/git/chktex.git

cd chktex/chktex
./autogen.sh --prefix=/usr/bin
./configure
make
install chktex /usr/bin

rm -rfv /chktex

apk del --no-network --purge .chktex-build-deps
