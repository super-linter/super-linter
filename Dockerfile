###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

#########################################
# Get dependency images as build stages #
#########################################
FROM borkdude/clj-kondo:2020.06.21 as clj-kondo
FROM dotenvlinter/dotenv-linter:2.1.0 as dotenv-linter
FROM mstruebing/editorconfig-checker:2.1.0 as editorconfig-checker
FROM golangci/golangci-lint:v1.29.0 as golangci-lint
FROM yoheimuta/protolint:v0.26.0 as protolint
FROM koalaman/shellcheck:v0.7.1 as shellcheck
FROM wata727/tflint:0.18.0 as tflint

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
    curl \
    gcc \
    git git-lfs\
    go \
    icu-libs \
    jq \
    libxml2-utils \
    make \
    musl-dev \
    npm nodejs-current \
    openjdk8-jre \
    perl \
    php7 \
    py3-setuptools \
    ruby ruby-dev ruby-bundler ruby-rdoc

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

##################
# Install ktlint #
##################
RUN curl -sSLO https://github.com/pinterest/ktlint/releases/latest/download/ktlint && chmod a+x ktlint \
    && mv "ktlint" /usr/bin/

####################
# Install dart-sdk #
####################
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN apk add --no-cache glibc-${GLIBC_VERSION}.apk && rm glibc-${GLIBC_VERSION}.apk
RUN wget https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip -O - -q | unzip -q - \
    && chmod +x dart-sdk/bin/dart* \
    && mv dart-sdk/bin/* /usr/bin/ && mv dart-sdk/lib/* /usr/lib/ && mv dart-sdk/include/* /usr/include/ \
    && rm -r dart-sdk/

################
# Install Raku #
################
# Basic setup, programs and init
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories \
    && apk add --update --no-cache rakudo zef

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
    VALIDATE_DOCKER=${VALIDATE_DOCKER} \
    VALIDATE_EDITORCONFIG=${VALIDATE_EDITORCONFIG} \
    VALIDATE_ENV=${VALIDATE_ENV} \
    VALIDATE_GO=${VALIDATE_GO} \
    VALIDATE_HTML=${VALIDATE_HTML} \
    VALIDATE_JAVASCRIPT_ES=${VALIDATE_JAVASCRIPT_ES} \
    VALIDATE_JAVASCRIPT_STANDARD=${VALIDATE_JAVASCRIPT_STANDARD} \
    VALIDATE_JSON=${VALIDATE_JSON} \
    VALIDATE_KOTLIN=${VALIDATE_KOTLIN} \
    VALIDATE_MD=${VALIDATE_MD} \
    VALIDATE_OPENAPI=${VALIDATE_OPENAPI} \
    VALIDATE_PERL=${VALIDATE_PERL} \
    VALIDATE_PHP=${VALIDATE_PHP} \
    VALIDATE_POWERSHELL=${VALIDATE_POWERSHELL} \
    VALIDATE_PROTOBUF=${VALIDATE_PROTOBUF} \
    VALIDATE_PYTHON=${VALIDATE_PYTHON} \
    VALIDATE_RAKU=${VALIDATE_RAKU} \
    VALIDATE_RUBY=${VALIDATE_RUBY} \
    VALIDATE_STATES=${VALIDATE_STATES} \
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
