#!/usr/bin/env bash

set -euo pipefail
set -x

case $TARGETARCH in
amd64)
  target=x86_64
  ;;
arm64)
  target=aarch64
  ;;
*)
  echo "$TARGETARCH is not supported"
  exit 1
  ;;
esac

apk add --no-cache --force-overwrite \
  php81 php81-curl php81-ctype php81-dom php81-iconv php81-mbstring \
  php81-openssl php81-phar php81-simplexml php81-tokenizer php81-xmlwriter \
  tar zstd
mkdir /tmp/libz
curl --retry 5 --retry-delay 5 -sL https://www.archlinux.org/packages/core/${target}/zlib/download | tar -x --zstd -C /tmp/libz
mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib
rm -rf /tmp/libz
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar.asc
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "0x9D8A98B29B2D5D79"
gpg --verify phive.phar.asc phive.phar
chmod +x phive.phar
mv phive.phar /usr/local/bin/phive
rm phive.phar.asc
echo y | phive --no-progress install --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1,12CE0F1D262429A5 --target /usr/bin phpstan@^1.3.3 psalm@^4.18.1 phpcs@^3.6.2
