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
      com.github.actions.description="Lint your code base with GitHub Actions" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="GitHub DevOps <github_devops@github.com>"

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    bash git git-lfs musl-dev curl gcc jq file\
    npm nodejs \
    libxml2-utils perl \
    ruby ruby-dev ruby-bundler ruby-rdoc make \
    py3-setuptools ansible-lint \
    go \
    openjdk8-jre \
    php7 \
    ca-certificates less ncurses-terminfo-base \
    krb5-libs libgcc libintl libssl1.1 libstdc++ \
    tzdata userspace-rcu zlib icu-libs lttng-ust

#########################################
# Install Powershell + PSScriptAnalyzer #
#########################################
# Reference: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7
# Slightly modified to always retrieve latest stable Powershell version
# Specify PSScriptAnalyzer Repository and Version for stability
ARG PSSA_VERSION='1.19.0'
RUN mkdir -p /opt/microsoft/powershell/7 \
    && curl -s https://api.github.com/repos/powershell/powershell/releases/latest \
    | grep browser_download_url \
    | grep linux-alpine-x64 \
    | cut -d '"' -f 4 \
    | xargs -n 1 wget -O - \
    | tar -xzC /opt/microsoft/powershell/7 \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    && pwsh -c 'Install-Module -Name PSScriptAnalyzer -Repository PSGallery -RequiredVersion ${PSSA_VERSION} -Force'

#####################
# Run Pip3 Installs #
#####################
RUN pip3 --no-cache-dir install --upgrade --no-cache-dir \
    yamllint pylint yq cfn-lint shyaml

####################
# Run NPM Installs #
####################
RUN npm config set package-lock false \
    && npm config set loglevel error \
    && npm -g --no-cache install \
      markdownlint-cli \
      jsonlint prettyjson \
      @coffeelint/cli \
      typescript eslint \
      standard \
      babel-eslint \
      @typescript-eslint/eslint-plugin \
      @typescript-eslint/parser \
      eslint-plugin-jest \
      stylelint \
      stylelint-config-standard \
      @stoplight/spectral \
      && npm --no-cache install \
      markdownlint-cli \
      jsonlint prettyjson \
      @coffeelint/cli \
      typescript eslint \
      standard \
      babel-eslint \
      prettier \
      eslint-config-prettier \
      @typescript-eslint/eslint-plugin \
      @typescript-eslint/parser \
      eslint-plugin-jest \
      stylelint \
      stylelint-config-standard

####################################
# Install dockerfilelint from repo #
####################################
RUN git clone https://github.com/replicatedhq/dockerfilelint.git && cd /dockerfilelint && npm install

 # I think we could fix this with path but not sure the language...
 # https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md

####################
# Run GEM installs #
####################
RUN gem install rubocop:0.74.0 rubocop-rails rubocop-github:0.13.0

# Need to fix the version as it installs 'rubocop:0.85.1' as a dep, and forces the default
# We then need to promote the correct version, uninstall, and fix deps
RUN sh -c 'INCORRECT_VERSION=$(gem list rhc -e rubocop | grep rubocop | awk "{print $2}" | cut -d"(" -f2 | cut -d"," -f1); \
  gem install --default rubocop:0.74.0; \
  yes | gem uninstall rubocop:$INCORRECT_VERSION -a -x -I; \
  gem install rubocop:0.74.0'

######################
# Install shellcheck #
######################
RUN wget -qO- "https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz" | tar -xJv \
    && mv "shellcheck-stable/shellcheck" /usr/bin/

#####################
# Install Go Linter #
#####################
ARG GO_VERSION='v1.27.0'
RUN wget -O- -nvq https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s "$GO_VERSION"

##################
# Install TFLint #
##################
RUN curl -Ls "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && rm tflint.zip \
    && mv "tflint" /usr/bin/

######################
# Install protolint #
######################
RUN curl -LsS "$(curl -Ls https://api.github.com/repos/yoheimuta/protolint/releases/latest | grep -o -E "https://.+?_Linux_x86_64.tar.gz")" -o protolint.tar.gz \
    && tar -xzf protolint.tar.gz \
    && rm protolint.tar.gz \
    && mv "protolint" /usr/bin/

#########################
# Install dotenv-linter #
#########################
RUN wget "https://github.com/dotenv-linter/dotenv-linter/releases/latest/download/dotenv-linter-alpine-x86_64.tar.gz" -O - -q | tar -xzf - \
    && mv "dotenv-linter" /usr/bin

#####################
# Install clj-kondo #
#####################
ARG CLJ_KONDO_VERSION='2020.06.12'
RUN curl -sLO https://github.com/borkdude/clj-kondo/releases/download/v${CLJ_KONDO_VERSION}/clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && unzip clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && rm clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && mv clj-kondo /usr/bin/

##################
# Install ktlint #
##################
RUN curl -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint && chmod a+x ktlint \
    && mv "ktlint" /usr/bin/

###########################################
# Load GitHub Env Vars for GitHub Actions #
###########################################
ENV GITHUB_SHA=${GITHUB_SHA} \
    GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH} \
    GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    DEFAULT_BRANCH=${DEFAULT_BRANCH} \
    VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} \
    LINTER_RULES_PATH=${LINTER_RULES_PATH} \
    VALIDATE_YAML=${VALIDATE_YAML} \
    VALIDATE_JSON=${VALIDATE_JSON} \
    VALIDATE_XML=${VALIDATE_XML} \
    VALIDATE_MD=${VALIDATE_MD} \
    VALIDATE_BASH=${VALIDATE_BASH} \
    VALIDATE_PERL=${VALIDATE_PERL} \
    VALIDATE_PHP=${VALIDATE_PHP} \
    VALIDATE_PYTHON=${VALIDATE_PYTHON} \
    VALIDATE_RUBY=${VALIDATE_RUBY} \
    VALIDATE_COFFEE=${VALIDATE_COFFEE} \
    VALIDATE_ANSIBLE=${VALIDATE_ANSIBLE} \
    VALIDATE_DOCKER=${VALIDATE_DOCKER} \
    VALIDATE_JAVASCRIPT_ES=${VALIDATE_JAVASCRIPT_ES} \
    VALIDATE_JAVASCRIPT_STANDARD=${VALIDATE_JAVASCRIPT_STANDARD} \
    VALIDATE_TYPESCRIPT_ES=${VALIDATE_TYPESCRIPT_ES} \
    VALIDATE_TYPESCRIPT_STANDARD=${VALIDATE_TYPESCRIPT_STANDARD} \
    VALIDATE_GO=${VALIDATE_GO} \
    VALIDATE_TERRAFORM=${VALIDATE_TERRAFORM} \
    VALIDATE_CSS=${VALIDATE_CSS} \
    VALIDATE_ENV=${VALIDATE_ENV} \
    VALIDATE_CLOJURE=${VALIDATE_CLOJURE} \
    VALIDATE_KOTLIN=${VALIDATE_KOTLIN} \
    VALIDATE_POWERSHELL=${VALIDATE_POWERSHELL} \
    VALIDATE_OPENAPI=${VALIDATE_OPENAPI} \
    VALIDATE_PROTOBUF=${VALIDATE_PROTOBUF} \
    ANSIBLE_DIRECTORY=${ANSIBLE_DIRECTORY} \
    RUN_LOCAL=${RUN_LOCAL} \
    TEST_CASE_RUN=${TEST_CASE_RUN} \
    ACTIONS_RUNNER_DEBUG=${ACTIONS_RUNNER_DEBUG} \
    DISABLE_ERRORS=${DISABLE_ERRORS}

#############################
# Copy scripts to container #
#############################
COPY lib /action/lib

##################################
# Copy linter rules to container #
##################################
COPY TEMPLATES /action/lib/.automation

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/linter.sh"]
