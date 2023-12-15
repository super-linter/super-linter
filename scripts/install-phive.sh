#!/usr/bin/env bash

set -euo pipefail

# Install PHP
apk add --no-cache \
  php82 php82-curl php82-ctype php82-dom php82-iconv php82-mbstring \
  php82-openssl php82-phar php82-simplexml php82-tokenizer php82-xmlwriter

# Install phive
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar.asc
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "0x9D8A98B29B2D5D79"
gpg --verify phive.phar.asc phive.phar
chmod +x phive.phar
mv phive.phar /usr/local/bin/phive
rm phive.phar.asc

# Install the PHARs listed in phive.xml
phive --no-progress install \
  --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1,12CE0F1D262429A5,5E6DDE998AB73B8E,51C67305FFC2E5C0,CBB3D576F2A0946F \
  --target /usr/bin
