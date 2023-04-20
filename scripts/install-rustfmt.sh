#!/usr/bin/env bash
# shellcheck disable=SC2016
# shellcheck disable=SC2129

# https://doc.rust-lang.org/rustc/platform-support.html

set -euo pipefail

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

ln -s /usr/bin/rustup-init /usr/bin/rustup
rustup toolchain install stable-${target}-unknown-linux-musl
rustup component add rustfmt --toolchain=stable-${target}-unknown-linux-musl
rustup component add clippy --toolchain=stable-${target}-unknown-linux-musl
mv /root/.rustup /usr/lib/.rustup
ln -fsv /usr/lib/.rustup/toolchains/stable-${target}-unknown-linux-musl/bin/rustfmt /usr/bin/rustfmt
ln -fsv /usr/lib/.rustup/toolchains/stable-${target}-unknown-linux-musl/bin/rustc /usr/bin/rustc
ln -fsv /usr/lib/.rustup/toolchains/stable-${target}-unknown-linux-musl/bin/cargo /usr/bin/cargo
ln -fsv /usr/lib/.rustup/toolchains/stable-${target}-unknown-linux-musl/bin/cargo-clippy /usr/bin/cargo-clippy

echo '#!/usr/bin/env bash' >/usr/bin/clippy
echo 'pushd $(dirname $1)' >>/usr/bin/clippy
echo 'cargo-clippy' >>/usr/bin/clippy
echo 'rc=$?' >>/usr/bin/clippy
echo 'popd' >>/usr/bin/clippy
echo 'exit $rc' >>/usr/bin/clippy
chmod +x /usr/bin/clippy
