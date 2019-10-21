###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

##################
# Get base image #
##################
FROM python:alpine

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="GitHub Super-Linter" \
      com.github.actions.description="Lint your code base with Github Actions" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="GitHub DevOps <github_devops@github.com>"

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    bash git musl-dev curl gcc \
    npm nodejs \
    libxml2-utils \
    ruby ruby-bundler \
    py3-setuptools ansible-lint

#####################
# Run Pip3 Installs #
#####################
RUN pip3 install --upgrade --no-cache-dir \
    yamllint pylint

####################
# Run NPM Installs #
####################
RUN npm -g install \
    markdownlint-cli jsonlint prettyjson

######################
# Install shellcheck #
######################
RUN wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz" | tar -xJv \
    && cp "shellcheck-stable/shellcheck" /usr/bin/

###########################################
# Load GitHub Env Vars for Github Actions #
###########################################
ENV GITHUB_SHA=${GITHUB_SHA}
ENV GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH}
ENV GITHUB_WORKSPACE=${GITHUB_WORKSPACE}

###########################
# Copy files to container #
###########################
COPY lib /action/lib \
     && TEMPLATES /action/lib/.automation

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/entrypoint.sh"]
