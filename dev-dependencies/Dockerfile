FROM node:21.4.0-bookworm

SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]

RUN apt-get update \
  && apt-get --assume-yes --no-install-recommends install \
  jq \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY package.json ./

RUN jq '.dependencies | to_entries[] | select(.key | startswith("@commitlint/")) | .key + "@" + .value' package.json > commitlint-packages.txt \
  && xargs npm install -g < commitlint-packages.txt \
  && rm package.json commitlint-packages.txt \
  && commitlint --version \
  && git config --global --add safe.directory /source-repository

ENTRYPOINT [ "commitlint" ]
