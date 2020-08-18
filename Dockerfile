###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

#########################################
# Get dependency images as build stages #
#########################################
FROM borkdude/clj-kondo:2020.07.29 as clj-kondo
FROM dotenvlinter/dotenv-linter:2.1.0 as dotenv-linter
FROM mstruebing/editorconfig-checker:2.1.0 as editorconfig-checker
FROM golangci/golangci-lint:v1.30.0 as golangci-lint
FROM yoheimuta/protolint:v0.26.0 as protolint
FROM koalaman/shellcheck:v0.7.1 as shellcheck
FROM wata727/tflint:0.19.0 as tflint
FROM hadolint/hadolint:latest-alpine as dockerfile-lint

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

################################
# Set ARG values used in Build #
################################
# PowerShell & PSScriptAnalyzer
ARG PWSH_VERSION='latest'
ARG PWSH_DIRECTORY='/opt/microsoft/powershell'
ARG PSSA_VERSION='latest'
# arm-ttk
ARG ARM_TTK_NAME='master.zip'
ARG ARM_TTK_URI='https://github.com/Azure/arm-ttk/archive/master.zip'
ARG ARM_TTK_DIRECTORY='/opt/microsoft'
# Dart Linter
## stable dart sdk: https://dart.dev/get-dart#release-channels
ARG DART_VERSION='2.8.4'
## install alpine-pkg-glibc (glibc compatibility layer package for Alpine Linux)
ARG GLIBC_VERSION='2.31-r0'

####################
# Run APK installs #
####################
RUN apk add --update --no-cache \
    ansible-lint \
    bash \
    coreutils \
    curl \
    gcc \
    git git-lfs\
    go \
    icu-libs \
    jq \
    libc-dev libxml2-utils \
    make \
    musl-dev \
    npm nodejs-current \
    openjdk8-jre \
    perl perl-dev \
    php7 php7-phar php7-json php7-mbstring php-xmlwriter \
    php7-tokenizer php7-ctype php7-curl php7-dom php7-simplexml \
    py3-setuptools \
    readline-dev \
    ruby ruby-dev ruby-bundler ruby-rdoc \
    gnupg

########################################
# Copy dependencies files to container #
########################################
COPY dependencies/* /

################################
# Installs python dependencies #
################################
RUN pip3 install --no-cache-dir pipenv
RUN pipenv install --system

####################
# Run NPM Installs #
####################
RUN npm config set package-lock false \
    && npm config set loglevel error \
    && npm --no-cache install

#############################
# Add node packages to path #
#############################
ENV PATH="/node_modules/.bin:${PATH}"

##############################
# Installs ruby dependencies #
##############################
RUN bundle install

##############################
# Installs Perl dependencies #
##############################
RUN curl --retry 5 --retry-delay 5 -sL https://cpanmin.us/ | perl - -nq --no-wget Perl::Critic

##############################
# Install Phive dependencies #
##############################
RUN wget --tries=5 -O phive.phar https://phar.io/releases/phive.phar \
    && wget --tries=5 -O phive.phar.asc https://phar.io/releases/phive.phar.asc \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys 0x9D8A98B29B2D5D79 \
    && gpg --verify phive.phar.asc phive.phar \
    && chmod +x phive.phar \
    && mv phive.phar /usr/local/bin/phive \
    && rm phive.phar.asc \
    && phive install --trust-gpg-keys 31C7E470E2138192,CF1A108D0E7AE720,8A03EA3B385DBAA1
# Trusted GPG keys for PHP linters:   phpcs,           phpstan,         psalm

#########################################
# Install Powershell + PSScriptAnalyzer #
#########################################
# Reference: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7
# Slightly modified to always retrieve latest stable Powershell version
# If changing PWSH_VERSION='latest' to a specific version, use format PWSH_VERSION='tags/v7.0.2'
RUN mkdir -p ${PWSH_DIRECTORY} \
    && curl --retry 5 --retry-delay 5 -s https://api.github.com/repos/powershell/powershell/releases/${PWSH_VERSION} \
    | grep browser_download_url \
    | grep linux-alpine-x64 \
    | cut -d '"' -f 4 \
    | xargs -n 1 wget -O - \
    | tar -xzC ${PWSH_DIRECTORY} \
    && ln -sf ${PWSH_DIRECTORY}/pwsh /usr/bin/pwsh \
    && pwsh -c 'Install-Module -Name PSScriptAnalyzer -RequiredVersion ${PSSA_VERSION} -Scope AllUsers -Force'

#############################################################
# Install Azure Resource Manager Template Toolkit (arm-ttk) #
#############################################################
# Depends on PowerShell
# Reference https://github.com/Azure/arm-ttk
# Reference https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/test-toolkit
ENV ARM_TTK_PSD1="${ARM_TTK_DIRECTORY}/arm-ttk-master/arm-ttk/arm-ttk.psd1"
RUN curl --retry 5 --retry-delay 5 -sLO "${ARM_TTK_URI}" \
    && unzip "${ARM_TTK_NAME}" -d "${ARM_TTK_DIRECTORY}" \
    && rm "${ARM_TTK_NAME}" \
    && ln -sTf "${ARM_TTK_PSD1}" /usr/bin/arm-ttk

######################
# Install shellcheck #
######################
COPY --from=shellcheck /bin/shellcheck /usr/bin/

#####################
# Install Go Linter #
#####################
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/bin/

##################
# Install TFLint #
##################
COPY --from=tflint /usr/local/bin/tflint /usr/bin/

######################
# Install protolint #
######################
COPY --from=protolint /usr/local/bin/protolint /usr/bin/

#########################
# Install dotenv-linter #
#########################
COPY --from=dotenv-linter /dotenv-linter /usr/bin/

#####################
# Install clj-kondo #
#####################
COPY --from=clj-kondo /usr/local/bin/clj-kondo /usr/bin/

################################
# Install editorconfig-checker #
################################
COPY --from=editorconfig-checker /usr/bin/ec /usr/bin/editorconfig-checker

###############################
# Install hadolint dockerfile #
###############################
COPY --from=dockerfile-lint /bin/hadolint /usr/bin/hadolint

##################
# Install ktlint #
##################
RUN curl --retry 5 --retry-delay 5 -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint && chmod a+x ktlint \
    && mv "ktlint" /usr/bin/

####################
# Install dart-sdk #
####################
RUN wget --tries=5 -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget --tries=5 https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN apk add --no-cache glibc-${GLIBC_VERSION}.apk && rm glibc-${GLIBC_VERSION}.apk
RUN wget --tries=5 https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -O - -q | unzip -q - \
    && chmod +x dart-sdk/bin/dart* \
    && mv dart-sdk/bin/* /usr/bin/ && mv dart-sdk/lib/* /usr/lib/ && mv dart-sdk/include/* /usr/include/ \
    && rm -r dart-sdk/

################
# Install Raku #
################
# Basic setup, programs and init
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk add --update --no-cache rakudo zef

######################
# Install CheckStyle #
######################

RUN CHECKSTYLE_LATEST=$(curl -s https://api.github.com/repos/checkstyle/checkstyle/releases/latest \
    | grep browser_download_url \
    | grep ".jar" \
    | cut -d '"' -f 4) \
    && curl --retry 5 --retry-delay 5 -sSL $CHECKSTYLE_LATEST \
    --output /usr/bin/checkstyle

####################
# Install luacheck #
####################
RUN wget --tries=5 https://www.lua.org/ftp/lua-5.3.5.tar.gz -O - -q | tar -xzf - \
    && cd lua-5.3.5 \
    && make linux \
    && make install \
    && cd .. && rm -r lua-5.3.5/

RUN wget --tries=5 https://github.com/cvega/luarocks/archive/v3.3.1-super-linter.tar.gz -O - -q | tar -xzf - \
    && cd luarocks-3.3.1-super-linter \
    && ./configure --with-lua-include=/usr/local/include \
    && make \
    && make -b install \
    && cd .. && rm -r luarocks-3.3.1-super-linter/

RUN luarocks install luacheck

###########################################
# Load GitHub Env Vars for GitHub Actions #
###########################################
ENV ACTIONS_RUNNER_DEBUG=${ACTIONS_RUNNER_DEBUG} \
    ANSIBLE_DIRECTORY=${ANSIBLE_DIRECTORY} \
    DEFAULT_BRANCH=${DEFAULT_BRANCH} \
    DISABLE_ERRORS=${DISABLE_ERRORS} \
    GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH} \
    GITHUB_SHA=${GITHUB_SHA} \
    GITHUB_TOKEN=${GITHUB_TOKEN} \
    GITHUB_WORKSPACE=${GITHUB_WORKSPACE} \
    LINTER_RULES_PATH=${LINTER_RULES_PATH} \
    LOG_FILE=${LOG_FILE} \
    LOG_LEVEL=${LOG_LEVEL} \
    MULTI_STATUS=${MULTI_STATUS} \
    OUTPUT_DETAILS=${OUTPUT_DETAILS} \
    OUTPUT_FOLDER=${OUTPUT_FOLDER} \
    OUTPUT_FORMAT=${OUTPUT_FORMAT} \
    RUN_LOCAL=${RUN_LOCAL} \
    TEST_CASE_RUN=${TEST_CASE_RUN} \
    VALIDATE_ALL_CODEBASE=${VALIDATE_ALL_CODEBASE} \
    VALIDATE_ANSIBLE=${VALIDATE_ANSIBLE} \
    VALIDATE_ARM=${VALIDATE_ARM} \
    VALIDATE_BASH=${VALIDATE_BASH} \
    VALIDATE_CLOJURE=${VALIDATE_CLOJURE} \
    VALIDATE_CLOUDFORMATION=${VALIDATE_CLOUDFORMATION} \
    VALIDATE_COFFEE=${VALIDATE_COFFEE} \
    VALIDATE_CSS=${VALIDATE_CSS} \
    VALIDATE_DART=${VALIDATE_DART} \
    VALIDATE_DOCKERFILE=${VALIDATE_DOCKERFILE} \
    VALIDATE_DOCKERFILE_HADOLINT=${VALIDATE_DOCKERFILE_HADOLINT} \
    VALIDATE_EDITORCONFIG=${VALIDATE_EDITORCONFIG} \
    VALIDATE_ENV=${VALIDATE_ENV} \
    VALIDATE_GO=${VALIDATE_GO} \
    VALIDATE_HTML=${VALIDATE_HTML} \
    VALIDATE_JAVA=${VALIDATE_JAVA} \
    VALIDATE_JAVASCRIPT_ES=${VALIDATE_JAVASCRIPT_ES} \
    VALIDATE_JAVASCRIPT_STANDARD=${VALIDATE_JAVASCRIPT_STANDARD} \
    VALIDATE_JSON=${VALIDATE_JSON} \
    VALIDATE_KOTLIN=${VALIDATE_KOTLIN} \
    VALIDATE_LUA=${VALIDATE_LUA} \
    VALIDATE_MD=${VALIDATE_MD} \
    VALIDATE_OPENAPI=${VALIDATE_OPENAPI} \
    VALIDATE_PERL=${VALIDATE_PERL} \
    VALIDATE_PHP=${VALIDATE_PHP} \
    VALIDATE_PHP_BUILTIN=${VALIDATE_PHP_BUILTIN} \
    VALIDATE_PHP_PHPCS=${VALIDATE_PHP_PHPCS} \
    VALIDATE_PHP_PHPSTAN=${VALIDATE_PHP_PHPSTAN} \
    VALIDATE_PHP_PSALM=${VALIDATE_PHP_PSALM} \
    VALIDATE_POWERSHELL=${VALIDATE_POWERSHELL} \
    VALIDATE_PROTOBUF=${VALIDATE_PROTOBUF} \
    VALIDATE_PYTHON=${VALIDATE_PYTHON} \
    VALIDATE_PYTHON_PYLINT=${VALIDATE_PYTHON_PYLINT} \
    VALIDATE_PYTHON_FLAKE8=${VALIDATE_PYTHON_FLAKE8} \
    VALIDATE_RAKU=${VALIDATE_RAKU} \
    VALIDATE_RUBY=${VALIDATE_RUBY} \
    VALIDATE_STATES=${VALIDATE_STATES} \
    VALIDATE_SQL=${VALIDATE_SQL} \
    VALIDATE_TERRAFORM=${VALIDATE_TERRAFORM} \
    VALIDATE_TERRAFORM_TERRASCAN=${VALIDATE_TERRAFORM_TERRASCAN} \
    VALIDATE_TYPESCRIPT_ES=${VALIDATE_TYPESCRIPT_ES} \
    VALIDATE_TYPESCRIPT_STANDARD=${VALIDATE_TYPESCRIPT_STANDARD} \
    VALIDATE_XML=${VALIDATE_XML} \
    VALIDATE_YAML=${VALIDATE_YAML}

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
