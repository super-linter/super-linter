#!/usr/bin/env bash

GetLinterOptions() {

  LANGUAGE_NAME="${1}" # Name of the language were looking for
  debug "Getting linter options for ${LANGUAGE_NAME}..."

  DEFAULT_LINTER_OPTIONS="${2}"
  debug "Default linter options for ${LANGUAGE_NAME}: ${DEFAULT_LINTER_OPTIONS}"

  LANGUAGE_LINTER_OPTIONS="${LANGUAGE_NAME}_LINTER_COMMAND_OPTIONS"
  debug "Name of the language linter options variable: ${LANGUAGE_LINTER_OPTIONS}"

  if [ -z "${!LANGUAGE_LINTER_OPTIONS+x}" ] && [ -n "${DEFAULT_LINTER_OPTIONS}" ]; then
    debug "${LANGUAGE_LINTER_OPTIONS} is not set and there's a default value available for ${LANGUAGE_NAME} (${DEFAULT_LINTER_OPTIONS}). Setting ${LANGUAGE_NAME} linter command options to the default value: ${DEFAULT_LINTER_OPTIONS}"
    eval "${LANGUAGE_LINTER_OPTIONS}=\"${DEFAULT_LINTER_OPTIONS}\""
    eval "export ${LANGUAGE_LINTER_OPTIONS}"
  else
    debug "Leaving ${LANGUAGE_NAME} linter command options (${LANGUAGE_LINTER_OPTIONS}) to: ${!LANGUAGE_LINTER_OPTIONS}."
    info "You provided a customized configuration for the ${LANGUAGE_NAME} linter command line options. super-linter DOES NOT validate those customizations, and does not alter them in any way. You're on your own."
  fi

  unset DEFAULT_LINTER_OPTIONS
}
