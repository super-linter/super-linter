###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

################################################################################
######################## PYTHON INTERMEDIATE CONTAINER #########################
################################################################################

#####################################
# Get base image for pyton and pip3 #
#####################################
FROM python:alpine as python-builder

#####################
# Run Pip3 Installs #
#####################
RUN pip3 --no-cache-dir install --upgrade --no-cache-dir \
    yamllint pylint yq

################################################################################
######################## RUBY INTERMEDIATE CONTAINER ###########################
################################################################################

####################################
# Get base image for ruby and gems #
####################################
FROM ruby:2.6.5-alpine as ruby-builder

####################
# Run GEM installs #
####################
RUN gem install rubocop rubocop-rails

################################################################################
######################## NODEJS INTERMEDIATE CONTAINER #########################
################################################################################

#####################################
# Get base image for nodejs and npm #
#####################################
FROM node:apline as node-builder

####################
# Run NPM Installs #
####################
RUN npm -g --no-cache install \
    markdownlint-cli \
    jsonlint prettyjson \
    coffeelint \
    typescript eslint \
    standard \
    babel-eslint \
    @typescript-eslint/eslint-plugin \
    @typescript-eslint/parser \
    eslint-plugin-jest \
    && npm --no-cache install \
    markdownlint-cli \
    jsonlint prettyjson \
    coffeelint \
    typescript eslint \
    standard \
    babel-eslint \
    prettier \
    eslint-config-prettier \
    @typescript-eslint/eslint-plugin \
    @typescript-eslint/parser

    # I think we could fix this with path but not sure the language...
    # https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md

################################################################################
############################ BASE APP CONTAINER ################################
################################################################################

#####################################
# Get base image for nodejs and npm #
#####################################
FROM python:apline

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    bash git musl-dev curl gcc jq \
    npm nodejs \
    libxml2-utils perl \
    ruby ruby-dev ruby-bundler ruby-rdoc make \
    py3-setuptools ansible-lint

######################
# Install shellcheck #
######################
RUN wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz" | tar -xJv \
    && cp "shellcheck-stable/shellcheck" /usr/bin/

###########################################
# Load GitHub Env Vars for Github Actions #
###########################################
ENV GITHUB_SHA=${GITHUB_SHA} \
    GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH} \
    GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} \
    VALIDATE_YAML=${VALIDATE_YAML} \
    VALIDATE_JSON=${VALIDATE_JSON} \
    VALIDATE_XML=${VALIDATE_XML} \
    VALIDATE_MD=${VALIDATE_MD} \
    VALIDATE_BASH=${VALIDATE_BASH} \
    VALIDATE_PERL=${VALIDATE_PERL} \
    VALIDATE_PYTHON=${VALIDATE_PYTHON} \
    VALIDATE_RUBY=${VALIDATE_RUBY} \
    VALIDATE_COFFEE=${VALIDATE_COFFEE} \
    VALIDATE_ANSIBLE=${VALIDATE_ANSIBLE} \
    VALIDATE_JAVASCRIPT=${VALIDATE_JAVASCRIPT} \
    ANSIBLE_DIRECTORY=${ANSIBLE_DIRECTORY} \
    RUN_LOCAL=${RUN_LOCAL}

#############################
# Copy scripts to container #
#############################
COPY lib /action/lib

##################################
# Copy linter rules to container #
##################################
COPY TEMPLATES /action/lib/.automation

#####################################################
# Copy PYTHON-BUILDER Libraries into base container #
#####################################################

###################################################
# Copy RUBY-BUILDER Libraries into base container #
###################################################

#####################################################
# Copy NODEJS-BUILDER Libraries into base container #
#####################################################

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="GitHub Super-Linter" \
      com.github.actions.description="Lint your code base with Github Actions" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="GitHub DevOps <github_devops@github.com>"

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/linter.sh"]

#CMD tail -f /dev/null
