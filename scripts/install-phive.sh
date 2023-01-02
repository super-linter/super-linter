#!/usr/bin/env bash

set -euo pipefail
set -x

apk add curl jq
url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/tags/${GLIBC_VERSION}" |
  jq --arg name "glibc-${GLIBC_VERSION}.apk" -r '.assets | .[] | select(.name | contains($name)) | .url')
curl --retry 5 --retry-delay 5 -sL -o "glibc-${GLIBC_VERSION}.apk" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${url}"
apk add --no-cache \
  bash \
  ca-certificates \
  "glibc-${GLIBC_VERSION}.apk" \
  gnupg \
  php7 php7-curl php7-ctype php7-dom php7-iconv php7-json php7-mbstring \
  php7-openssl php7-phar php7-simplexml php7-tokenizer php-xmlwriter \
  tar zstd
rm "glibc-${GLIBC_VERSION}.apk"
mkdir /tmp/libz
curl --retry 5 --retry-delay 5 -sL https://www.archlinux.org/packages/core/x86_64/zlib/download | tar -x --zstd -C /tmp/libz
mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib
rm -rf /tmp/libz
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar.asc
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "0x9D8A98B29B2D5D79"
gpg --verify phive.phar.asc phive.phar
chmod +x phive.phar
mv phive.phar /usr/local/bin/phive
rm phive.phar.asc
phive --no-progress install --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1,12CE0F1D262429A5 --target /usr/bin phpstan@^1.3.3 psalm@^4.18.1 phpcs@^3.6.2
