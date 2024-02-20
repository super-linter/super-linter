#!/usr/bin/env bash

function SetupSshAgent() {
  # Check to see if a SSH_KEY_SECRET was passed
  if [ -n "${SSH_KEY:-}" ]; then
    info "--------------------------------------------"
    info "SSH key found, setting up agent..."
    export SSH_AUTH_SOCK=/tmp/ssh_agent.sock
    ssh-agent -a "${SSH_AUTH_SOCK}" >/dev/null
    ssh-add - <<<"${SSH_KEY}" 2>/dev/null
  fi
}

function GetGitHubSshRsaKeyFingerprint() {
  local GET_SSH_RSA_KEY_FINGERPRINT_CMD
  if ! GET_SSH_RSA_KEY_FINGERPRINT_CMD=$(
    curl -f -s --show-error -X GET \
      --url "${GITHUB_META_URL}" \
      -H 'Accept: application/vnd.github.v3+json' \
      -H "Authorization: Bearer ${GITHUB_TOKEN}" \
      -H "X-GitHub-Api-Version: 2022-11-28" 2>&1
  ); then
    fatal "Failed to get GitHub RSA key fingerprint from ${GITHUB_META_URL}: ${GET_SSH_RSA_KEY_FINGERPRINT_CMD}"
  fi

  local SSH_RSA_KEY_FINGERPRINT
  SSH_RSA_KEY_FINGERPRINT="SHA256:$(jq -r '.ssh_key_fingerprints.SHA256_RSA' <<<"${GET_SSH_RSA_KEY_FINGERPRINT_CMD}")"
  echo "${SSH_RSA_KEY_FINGERPRINT}"
}
export -f GetGitHubSshRsaKeyFingerprint

function SetupGithubComSshKeys() {
  if [[ -n "${SSH_KEY:-}" || "${SSH_SETUP_GITHUB}" == "true" ]]; then
    info "Adding ${GITHUB_DOMAIN} SSH keys"
    # Fetched out of band from
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    GITHUB_RSA_FINGERPRINT="$(GetGitHubSshRsaKeyFingerprint)"
    debug "${GITHUB_DOMAIN} key RSA key fingerprint: ${GITHUB_RSA_FINGERPRINT}"
    ssh-keyscan -t rsa "${GITHUB_DOMAIN}" >/tmp/github.pub 2>/dev/null
    if [[ "${SSH_INSECURE_NO_VERIFY_GITHUB_KEY}" == "true" ]]; then
      warn "Skipping ${GITHUB_DOMAIN} key verification and adding without checking fingerprint"
      mkdir -p ~/.ssh
      cat /tmp/github.pub >>~/.ssh/known_hosts
    elif [[ "$(ssh-keygen -lf /tmp/github.pub)" == "3072 ${GITHUB_RSA_FINGERPRINT} ${GITHUB_DOMAIN} (RSA)" ]]; then
      info "Successfully verified ${GITHUB_DOMAIN} key"
      mkdir -p ~/.ssh
      cat /tmp/github.pub >>~/.ssh/known_hosts
    else
      error "Could not verify ${GITHUB_DOMAIN} key. SSH requests to ${GITHUB_DOMAIN} will likely fail."
    fi
  fi
}
