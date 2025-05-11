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

RETRIES=5
DELAY=5
COUNT=0
while [ "${COUNT}" -lt "${RETRIES}" ]; do
  if git clone https://git.savannah.gnu.org/git/chktex.git; then
    echo "Successfully cloned the chktex Git repository"
    RETRIES=0
    break
  fi
  echo "Error while cloning the chktex Git repository."
  ((COUNT = COUNT + 1))
  sleep "${DELAY}"
done

if [[ ! -d "./chktex/chktex" ]]; then
  echo "chktex directory doesn't exist."
  exit 1
fi

cd chktex/chktex
./autogen.sh --prefix=/usr/bin
./configure
make
install chktex /usr/bin

rm -rfv /chktex

apk del --no-network --purge .chktex-build-deps
