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
# Raku Linter
ARG RAKU_VER="2020.06"
ARG RAKU_INSTALL_PATH=/usr
ARG RAKUBREW_HOME=/tmp/rakubrew

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    ansible-lint \
    bash \
    curl \
    gcc \
    go \
    icu-libs \
    jq \
    libxml2-utils \
    make \
    musl-dev \
    npm \
    nodejs \
    openjdk8-jre \
    perl \
    php7 \
    py3-setuptools \
    ruby \
    ruby-dev \
    ruby-bundler \
    ruby-rdoc

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

#########################################
# Install Powershell + PSScriptAnalyzer #
#########################################
# Reference: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7
# Slightly modified to always retrieve latest stable Powershell version
# If changing PWSH_VERSION='latest' to a specific version, use format PWSH_VERSION='tags/v7.0.2'
RUN mkdir -p ${PWSH_DIRECTORY} \
    && curl -s https://api.github.com/repos/powershell/powershell/releases/${PWSH_VERSION} \
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
RUN curl -sLO "${ARM_TTK_URI}" \
    && unzip "${ARM_TTK_NAME}" -d "${ARM_TTK_DIRECTORY}" \
    && rm "${ARM_TTK_NAME}" \
    && ln -sTf "$ARM_TTK_PSD1" /usr/bin/arm-ttk

######################
# Install shellcheck #
######################
COPY --from=koalaman/shellcheck:v0.7.1 /bin/shellcheck /usr/bin/

#####################
# Install Go Linter #
#####################
COPY --from=golangci/golangci-lint:v1.27.0 /usr/bin/golangci-lint /usr/bin/

##################
# Install TFLint #
##################
COPY --from=wata727/tflint:0.16.2 /usr/local/bin/tflint /usr/bin/

######################
# Install protolint #
######################
COPY --from=yoheimuta/protolint:v0.25.1 /usr/local/bin/protolint /usr/bin/

#########################
# Install dotenv-linter #
#########################
COPY --from=dotenvlinter/dotenv-linter:2.0.0 /dotenv-linter /usr/bin/

#####################
# Install clj-kondo #
#####################
COPY --from=borkdude/clj-kondo:2020.06.21 /usr/local/bin/clj-kondo /usr/bin/

##################
# Install ktlint #
##################
RUN curl -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint && chmod a+x ktlint \
    && mv "ktlint" /usr/bin/

################
# Install Raku #
################
# Environment
ENV PATH="$RAKU_INSTALL_PATH/share/perl6/site/bin:${PATH}"
# Basic setup, programs and init
RUN mkdir -p $RAKUBREW_HOME/bin \
    && curl -sSLo $RAKUBREW_HOME/bin/rakubrew https://rakubrew.org/perl/rakubrew \
    && chmod 755 $RAKUBREW_HOME/bin/rakubrew \
    && eval "$($RAKUBREW_HOME/bin/rakubrew init Sh)"\
    && rakubrew build moar $RAKU_VER --configure-opts='--prefix=$RAKU_INSTALL_PATH' \
    && rm -rf $RAKUBREW_HOME/versions/moar-$RAKU_VER \
    && rakubrew build-zef \
    && rm -rf $RAKUBREW_HOME

################################
# Install editorconfig-checker #
################################
COPY --from=mstruebing/editorconfig-checker:2.1.0 /usr/bin/ec /usr/bin/editorconfig-checker

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
    VALIDATE_RAKU=${VALIDATE_RAKU} \
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
    VALIDATE_ARM=${VALIDATE_ARM} \
    VALIDATE_OPENAPI=${VALIDATE_OPENAPI} \
    VALIDATE_PROTOBUF=${VALIDATE_PROTOBUF} \
    VALIDATE_EDITORCONFIG=${VALIDATE_EDITORCONFIG} \
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
