FROM node:21.6.0-bookworm

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

# Split this from the previous RUN instruction so we can cache the costly installation step
# hadolint ignore=DL3059
RUN commitlint --version \
  && release-please --version \
  && git config --global --add safe.directory /source-repository

ARG USERNAME=super-linter-dev
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} -o "${USERNAME}" \
  && useradd -m -u ${UID} -g ${GID} -o -s /bin/bash -l "${USERNAME}"
USER $UNAME
