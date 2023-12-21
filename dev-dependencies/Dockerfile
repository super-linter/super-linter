FROM node:21.4.0-bookworm

SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

RUN apt-get update \
  && apt-get --assume-yes --no-install-recommends install \
  jq \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./

ENV NPM_PACKAGES_FILE_PATH="npm-packages.txt"

RUN jq '.dependencies | to_entries[] | select(.key | startswith("@commitlint/")) | .key + "@" + .value' package.json >> "${NPM_PACKAGES_FILE_PATH}" \
  && jq '.dependencies | to_entries[] | select(.key | startswith("release-please")) | .key + "@" + .value' package.json >> "${NPM_PACKAGES_FILE_PATH}" \
  && xargs npm install -g < "${NPM_PACKAGES_FILE_PATH}" \
  && rm package.json "${NPM_PACKAGES_FILE_PATH}"

RUN commitlint --version \
  && release-please --version \
  && git config --global --add safe.directory /source-repository
