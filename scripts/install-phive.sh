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

apk add curl jq
url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "https://api.github.com/repos/sgerrand/alpine-pkg-glibc/releases/tags/${GLIBC_VERSION}" |
  jq --arg name "glibc-${GLIBC_VERSION}.apk" -r '.assets | .[] | select(.name | contains($name)) | .url')
curl --retry 5 --retry-delay 5 -sL -o "glibc-${GLIBC_VERSION}.apk" \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer $(cat /run/secrets/GITHUB_TOKEN)" \
  "${url}"
apk add --no-cache --force-overwrite \
  bash \
  ca-certificates \
  "glibc-${GLIBC_VERSION}.apk" \
  gnupg \
  php82 php82-curl php82-ctype php82-dom php82-iconv php82-mbstring \
  php82-openssl php82-phar php82-simplexml php82-tokenizer php82-xmlwriter \
  tar zstd
rm "glibc-${GLIBC_VERSION}.apk"
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

# Install the PHARs listed in phive.xml
phive --no-progress install \
  --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1,12CE0F1D262429A5,5E6DDE998AB73B8E,51C67305FFC2E5C0,CBB3D576F2A0946F \
  --target /usr/bin
