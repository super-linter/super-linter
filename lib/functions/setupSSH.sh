#!/usr/bin/env bash

################################################################################
################################################################################
########### Super-Linter linting Functions #####################################
################################################################################
################################################################################
########################## FUNCTION CALLS BELOW ################################
################################################################################
################################################################################
#### Function SetupSshAgent ####################################################
function SetupSshAgent() {
  # Check to see if a SSH_KEY_SECRET was passed
  if [ -n "${SSH_KEY}" ]; then
    info "--------------------------------------------"
    info "SSH key found, setting up agent..."
    export SSH_AUTH_SOCK=/tmp/ssh_agent.sock
    ssh-agent -a "${SSH_AUTH_SOCK}" >/dev/null
    ssh-add - <<<"${SSH_KEY}" 2>/dev/null
  fi
}
################################################################################
#### Function SetupGithubComSshKeys ############################################
function SetupGithubComSshKeys() {
  if [[ -n "${SSH_KEY}" || "${SSH_SETUP_GITHUB}" == "true" ]]; then
    info "Adding github.com SSH keys"
    # Fetched out of band from
    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    GITHUB_RSA_FINGERPRINT="SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8"
    ssh-keyscan -t rsa github.com >/tmp/github.pub 2>/dev/null
    if [[ "${SSH_INSECURE_NO_VERIFY_GITHUB_KEY}" == "true" ]]; then
      warn "Skipping github.com key verification and adding without checking fingerprint"
      mkdir -p ~/.ssh
      cat /tmp/github.pub >>~/.ssh/known_hosts
    elif [[ "$(ssh-keygen -lf /tmp/github.pub)" == "2048 ${GITHUB_RSA_FINGERPRINT} github.com (RSA)" ]]; then
      info "Successfully verified github.com key"
      mkdir -p ~/.ssh
      cat /tmp/github.pub >>~/.ssh/known_hosts
    else
      error "Could not verify github.com key. SSH requests to github.com will likely fail."
    fi
  fi
}
################################################################################
