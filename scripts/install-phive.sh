#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache --virtual .php-build-deps \
  gnupg

# Install phive
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar
curl --retry 5 --retry-delay 5 -sLO https://phar.io/releases/phive.phar.asc
gpg --keyserver hkps://keys.openpgp.org --recv-keys "0x9D8A98B29B2D5D79"
gpg --verify phive.phar.asc phive.phar
chmod +x phive.phar
mv phive.phar /usr/local/bin/phive
rm phive.phar.asc

# Install the PHARs listed in phive.xml
phive --no-progress install \
  --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1,12CE0F1D262429A5,5E6DDE998AB73B8E,51C67305FFC2E5C0,CBB3D576F2A0946F,689DAD778FF08760E046228BA978220305CD5C32 \
  --target /usr/bin

apk del --no-network --purge .php-build-deps
