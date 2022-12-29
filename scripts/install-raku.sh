#!/usr/bin/env bash

set -euo pipefail

apk add --no-cache rakudo zef

######################
# Install CheckStyle #
######################
url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/checkstyle/checkstyle/releases/tags/checkstyle-${CHECKSTYLE_VERSION}" |
  jq --arg name "checkstyle-${CHECKSTYLE_VERSION}-all.jar" -r '.assets | .[] | select(.name==$name) | .url')
curl --retry 5 --retry-delay 5 -sL -o /usr/bin/checkstyle \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${url}"
chmod a+x /usr/bin/checkstyle

##############################
# Install google-java-format #
##############################
url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "https://api.github.com/repos/google/google-java-format/releases/tags/v${GOOGLE_JAVA_FORMAT_VERSION}" |
  jq --arg name "google-java-format-${GOOGLE_JAVA_FORMAT_VERSION}-all-deps.jar" -r '.assets | .[] | select(.name==$name) | .url')
curl --retry 5 --retry-delay 5 -sL -o /usr/bin/google-java-format \
  -H "Accept: application/octet-stream" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  "${url}"
chmod a+x /usr/bin/google-java-format

#################################
# Install luacheck and luarocks #
#################################
curl --retry 5 --retry-delay 5 -s https://www.lua.org/ftp/lua-5.3.5.tar.gz | tar -xz
cd lua-5.3.5
make linux
make install
cd .. && rm -r lua-5.3.5/

url=$(curl -s \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  https://api.github.com/repos/cvega/luarocks/releases/latest | jq -r '.tarball_url')
curl --retry 5 --retry-delay 5 -sL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
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
mv /etc/R/* /usr/lib/R/etc/
find /usr/ -type f -name '*.md' -exec rm {} +
