#!/usr/bin/env zsh

# This script should be ignored by Super-linter because shellcheck doesn't
# support ZSH scripts

# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if ((${+terminfo[smkx]})) && ((${+terminfo[rmkx]})); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi
