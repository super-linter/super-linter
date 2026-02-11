#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SHELLHARDEN_VERSION="${SHELLHARDEN_VERSION:-}"
if [[ -z "${SHELLHARDEN_VERSION}" ]]; then
  echo "SHELLHARDEN_VERSION is not set."
  exit 1
fi
echo "Installing Shellharden: ${SHELLHARDEN_VERSION}"

github_token=""
if [[ -r /run/secrets/GITHUB_TOKEN ]]; then
  github_token="$(cat /run/secrets/GITHUB_TOKEN)"
fi

github_auth_header=()
if [[ -n "${github_token}" ]]; then
  github_auth_header=(-H "Authorization: Bearer ${github_token}")
fi

if [[ -z "${TARGETARCH:-}" ]]; then
  echo "TARGETARCH is not set. Expected amd64 or arm64."
  exit 1
fi

case "${TARGETARCH}" in
amd64)
  SHELLHARDEN_ARCH="x86_64"
  ;;
arm64)
  SHELLHARDEN_ARCH="aarch64"
  ;;
*)
  echo "Unsupported TARGETARCH: ${TARGETARCH}"
  exit 1
  ;;
esac

SHELLHARDEN_ASSET="shellharden-${SHELLHARDEN_ARCH}-unknown-linux-musl.tar.gz"

if ! api_response="$(
  curl --silent --show-error \
    -H "Accept: application/vnd.github+json" \
    "${github_auth_header[@]}" \
    "https://api.github.com/repos/anordal/shellharden/releases/tags/${SHELLHARDEN_VERSION}" \
    2>&1
)"; then
  echo "Error while fetching shellharden release information: ${api_response}"
  exit 1
fi

if ! url="$(
  jq --raw-output --arg asset "${SHELLHARDEN_ASSET}" \
    '.assets[] | select(.name==$asset) | .url' \
    <<<"${api_response}" \
    2>&1
)"; then
  echo "Error while parsing shellharden release information: ${url}"
  exit 1
fi

if [[ -z "${url:-}" ]] || [[ "${url:-}" == "null" ]]; then
  echo "Failed to locate shellharden asset: ${SHELLHARDEN_ASSET}. Output: ${url:-not set}"
  exit 1
fi

tmp_dir="$(mktemp -d)"
if ! curl --retry 5 --retry-delay 5 --silent --show-error --location \
  --output "${tmp_dir}/${SHELLHARDEN_ASSET}" \
  -H "Accept: application/octet-stream" \
  "${github_auth_header[@]}" \
  "${url}"; then
  echo "Failed to download shellharden asset from ${url}"
  exit 1
fi
tar -xzf "${tmp_dir}/${SHELLHARDEN_ASSET}" -C "${tmp_dir}"

shellharden_path="${tmp_dir}/shellharden"
if [[ ! -f "${shellharden_path}" ]]; then
  echo "Shellharden binary not found in ${SHELLHARDEN_ASSET}"
  exit 1
fi

install -m 0755 "${shellharden_path}" /usr/bin/shellharden
rm -rf "${tmp_dir}"
