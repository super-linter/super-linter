###########################################
###########################################
## Dockerfile to run GitHub Super-Linter ##
###########################################
###########################################

#########################################
# Get dependency images as build stages #
#########################################
FROM tenable/terrascan:1.18.1 as terrascan
FROM alpine/terragrunt:1.5.2 as terragrunt
FROM assignuser/chktex-alpine:v0.1.1 as chktex
FROM dotenvlinter/dotenv-linter:3.3.0 as dotenv-linter
FROM ghcr.io/awkbar-devops/clang-format:v1.0.2 as clang-format
FROM ghcr.io/terraform-linters/tflint-bundle:v0.47.0.0 as tflint
FROM ghcr.io/yannh/kubeconform:v0.6.2 as kubeconfrm
FROM golangci/golangci-lint:v1.53.3 as golangci-lint
FROM hadolint/hadolint:latest-alpine as dockerfile-lint
FROM hashicorp/terraform:1.5.5 as terraform
FROM koalaman/shellcheck:v0.9.0 as shellcheck
FROM mstruebing/editorconfig-checker:2.7.0 as editorconfig-checker
FROM mvdan/shfmt:v3.7.0 as shfmt
FROM rhysd/actionlint:1.6.25 as actionlint
FROM scalameta/scalafmt:v3.7.3 as scalafmt
FROM zricethezav/gitleaks:v8.17.0 as gitleaks
FROM yoheimuta/protolint:0.45.1 as protolint

##################
# Get base image #
##################
FROM python:3.11.4-alpine3.17 as base_image

################################
# Set ARG values used in Build #
################################
ARG CHECKSTYLE_VERSION='10.3.4'
ARG CLJ_KONDO_VERSION='2023.05.18'
# Dart Linter
## stable dart sdk: https://dart.dev/get-dart#release-channels
ARG DART_VERSION='2.8.4'
ARG GOOGLE_JAVA_FORMAT_VERSION='1.15.0'
## install alpine-pkg-glibc (glibc compatibility layer package for Alpine Linux)
ARG GLIBC_VERSION='2.34-r0'
ARG KTLINT_VERSION='0.47.1'
# PowerShell & PSScriptAnalyzer linter
ARG PSSA_VERSION='1.21.0'
ARG PWSH_DIRECTORY='/usr/lib/microsoft/powershell'
ARG PWSH_VERSION='v7.3.1'
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

####################
# Run APK installs #
####################
RUN apk add --no-cache \
    bash \
    ca-certificates \
    cargo \
    cmake \
    coreutils \
    curl \
    file \
    gcc \
    g++ \
    git git-lfs \
    go \
    gnupg \
    icu-libs \
    jpeg-dev \
    jq \
    krb5-libs \
    libc-dev libcurl libffi-dev libgcc \
    libintl libssl1.1 libstdc++ \
    libxml2-dev libxml2-utils \
    linux-headers \
    lttng-ust-dev \
    make \
    musl-dev \
    net-snmp-dev \
    npm nodejs-current \
    openjdk11-jre \
    openssh-client \
    openssl-dev \
    perl perl-dev \
    py3-setuptools python3-dev  \
    py3-pyflakes \
    R R-dev R-doc \
    readline-dev \
    ruby ruby-dev ruby-bundler ruby-rdoc \
    rustup \
    zlib zlib-dev

########################################
# Copy dependencies files to container #
########################################
COPY dependencies/* /

###################################################################
# Install Dependencies                                            #
# The chown fixes broken uid/gid in ast-types-flow dependency     #
# (see https://github.com/github/super-linter/issues/3901)        #
###################################################################
RUN npm install && chown -R "$(id -u)":"$(id -g)" node_modules && bundle install

##############################
# Installs Perl dependencies #
##############################
RUN curl --retry 5 --retry-delay 5 -sL https://cpanmin.us/ | perl - -nq --no-wget Perl::Critic Perl::Critic::Community

######################
# Install shellcheck #
######################
COPY --from=shellcheck /bin/shellcheck /usr/bin/

#####################
# Install Go Linter #
#####################
COPY --from=golangci-lint /usr/bin/golangci-lint /usr/bin/

#####################
# Install Terraform #
#####################
COPY --from=terraform /bin/terraform /usr/bin/

##################
# Install TFLint #
##################
COPY --from=tflint /usr/local/bin/tflint /usr/bin/
COPY --from=tflint /root/.tflint.d /root/.tflint.d

#####################
# Install Terrascan #
#####################
COPY --from=terrascan /go/bin/terrascan /usr/bin/

######################
# Install Terragrunt #
######################
COPY --from=terragrunt /usr/local/bin/terragrunt /usr/bin/

######################
# Install protolint #
######################
COPY --from=protolint /usr/local/bin/protolint /usr/bin/

################################
# Install editorconfig-checker #
################################
COPY --from=editorconfig-checker /usr/bin/ec /usr/bin/editorconfig-checker

###############################
# Install hadolint dockerfile #
###############################
COPY --from=dockerfile-lint /bin/hadolint /usr/bin/hadolint

##################
# Install chktex #
##################
COPY --from=chktex /usr/bin/chktex /usr/bin/

#################
# Install shfmt #
#################
COPY --from=shfmt /bin/shfmt /usr/bin/

########################
# Install clang-format #
########################
COPY --from=clang-format /usr/bin/clang-format /usr/bin/

####################
# Install GitLeaks #
####################
COPY --from=gitleaks /usr/bin/gitleaks /usr/bin/

####################
# Install scalafmt #
####################
COPY --from=scalafmt /bin/scalafmt /usr/bin/

######################
# Install actionlint #
######################
COPY --from=actionlint /usr/local/bin/actionlint /usr/bin/

######################
# Install kubeconform #
######################
COPY --from=kubeconfrm /kubeconform /usr/bin/

#################
# Install Lintr #
#################
COPY scripts/install-lintr.sh /
RUN /install-lintr.sh && rm -rf /install-lintr.sh

#####################
# Install clj-kondo #
#####################
COPY scripts/install-clj-kondo.sh /
RUN /install-clj-kondo.sh && rm -rf /install-clj-kondo.sh

# Source: https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
# Store the key here because the above host is sometimes down, and breaks our builds
COPY dependencies/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub

##################
# Install ktlint #
##################
COPY scripts/install-ktlint.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-ktlint.sh && rm -rf /install-ktlint.sh

####################
# Install dart-sdk #
####################
COPY scripts/install-dart-sdk.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-dart-sdk.sh && rm -rf /install-dart-sdk.sh

################################
# Install Bash-Exec #
################################
COPY --chmod=555 scripts/bash-exec.sh /usr/bin/bash-exec

#################################################
# Install Raku and additional Edge dependencies #
#################################################
RUN apk add --no-cache rakudo zef

######################
# Install CheckStyle #
######################
COPY scripts/install-checkstyle.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-checkstyle.sh && rm -rf /install-checkstyle.sh

##############################
# Install google-java-format #
##############################
COPY scripts/install-google-java-format.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-google-java-format.sh && rm -rf /install-google-java-format.sh

#################################
# Install luacheck and luarocks #
#################################
COPY scripts/install-lua.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-lua.sh && rm -rf /install-lua.sh

################################################################################
# Grab small clean image to build python packages ##############################
################################################################################
FROM python:3.11.4-alpine3.17 as python_builder
RUN apk add --no-cache bash g++ git libffi-dev
COPY dependencies/python/ /stage
WORKDIR /stage
RUN ./build-venvs.sh

################################################################################
# Grab small clean image to build slim ###################################
################################################################################
FROM alpine:3.18.2 as slim

############################
# Get the build arguements #
############################
ARG BUILD_DATE
ARG BUILD_REVISION
ARG BUILD_VERSION
## install alpine-pkg-glibc (glibc compatibility layer package for Alpine Linux)
ARG GLIBC_VERSION='2.34-r0'
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

#########################################
# Label the instance and set maintainer #
#########################################
LABEL com.github.actions.name="GitHub Super-Linter" \
    com.github.actions.description="Lint your code base with GitHub Actions" \
    com.github.actions.icon="code" \
    com.github.actions.color="red" \
    maintainer="GitHub DevOps <github_devops@github.com>" \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$BUILD_REVISION \
    org.opencontainers.image.version=$BUILD_VERSION \
    org.opencontainers.image.authors="GitHub DevOps <github_devops@github.com>" \
    org.opencontainers.image.url="https://github.com/github/super-linter" \
    org.opencontainers.image.source="https://github.com/github/super-linter" \
    org.opencontainers.image.documentation="https://github.com/github/super-linter" \
    org.opencontainers.image.vendor="GitHub" \
    org.opencontainers.image.description="Lint your code base with GitHub Actions"

#################################################
# Set ENV values used for debugging the version #
#################################################
ENV BUILD_DATE=$BUILD_DATE
ENV BUILD_REVISION=$BUILD_REVISION
ENV BUILD_VERSION=$BUILD_VERSION
ENV IMAGE="slim"

# Source: https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
# Store the key here because the above host is sometimes down, and breaks our builds
COPY dependencies/sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub

###############
# Install Git #
###############
RUN apk add --no-cache bash git git-lfs

##############################
# Install Phive dependencies #
##############################
COPY scripts/install-phive.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-phive.sh && rm -rf /install-phive.sh

####################################################
# Install Composer after all Libs have been copied #
####################################################
RUN sh -c 'curl --retry 5 --retry-delay 5 --show-error -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer'

#################################
# Copy the libraries into image #
#################################
COPY --from=base_image /usr/bin/ /usr/bin/
COPY --from=base_image /usr/local/bin/ /usr/local/bin/
COPY --from=base_image /usr/local/lib/ /usr/local/lib/
COPY --from=base_image /usr/local/share/ /usr/local/share/
COPY --from=base_image /usr/local/include/ /usr/local/include/
COPY --from=base_image /usr/lib/ /usr/lib/
COPY --from=base_image /usr/share/ /usr/share/
COPY --from=base_image /usr/include/ /usr/include/
COPY --from=base_image /lib/ /lib/
COPY --from=base_image /bin/ /bin/
COPY --from=base_image /node_modules/ /node_modules/
COPY --from=base_image /home/r-library /home/r-library
COPY --from=base_image /root/.tflint.d/ /root/.tflint.d/
COPY --from=python_builder /venvs/ /venvs/

##################################
# Configure TFLint plugin folder #
##################################
ENV TFLINT_PLUGIN_DIR="/root/.tflint.d/plugins"

########################################
# Add node packages to path and dotnet #
########################################
ENV PATH="${PATH}:/node_modules/.bin"

###############################
# Add python packages to path #
###############################
ENV PATH="${PATH}:/venvs/ansible-lint/bin"
ENV PATH="${PATH}:/venvs/black/bin"
ENV PATH="${PATH}:/venvs/cfn-lint/bin"
ENV PATH="${PATH}:/venvs/cpplint/bin"
ENV PATH="${PATH}:/venvs/flake8/bin"
ENV PATH="${PATH}:/venvs/isort/bin"
ENV PATH="${PATH}:/venvs/mypy/bin"
ENV PATH="${PATH}:/venvs/pylint/bin"
ENV PATH="${PATH}:/venvs/snakefmt/bin"
ENV PATH="${PATH}:/venvs/snakemake/bin"
ENV PATH="${PATH}:/venvs/sqlfluff/bin"
ENV PATH="${PATH}:/venvs/yamllint/bin"
ENV PATH="${PATH}:/venvs/yq/bin"

#############################
# Copy scripts to container #
#############################
COPY lib /action/lib

##################################
# Copy linter rules to container #
##################################
COPY TEMPLATES /action/lib/.automation

################
# Pull in libs #
################
COPY --from=base_image /usr/libexec/ /usr/libexec/

################################################
# Run to build version file and validate image #
################################################
RUN ACTIONS_RUNNER_DEBUG=true WRITE_LINTER_VERSIONS_FILE=true IMAGE="${IMAGE}" /action/lib/linter.sh

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/linter.sh"]

################################################################################
# Grab small clean image to build standard ###############################
################################################################################
FROM slim as standard

###############
# Set up args #
###############
ARG GITHUB_TOKEN
ARG PWSH_VERSION='latest'
ARG PWSH_DIRECTORY='/usr/lib/microsoft/powershell'
ARG PSSA_VERSION='1.21.0'
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
ARG TARGETARCH

################
# Set ENV vars #
################
ENV ARM_TTK_PSD1="/usr/lib/microsoft/arm-ttk/arm-ttk.psd1"
ENV IMAGE="standard"
ENV PATH="${PATH}:/var/cache/dotnet/tools:/usr/share/dotnet"

#########################
# Install dotenv-linter #
#########################
COPY --from=dotenv-linter /dotenv-linter /usr/bin/

###################################
# Install DotNet and Dependencies #
###################################
COPY scripts/install-dotnet.sh /
RUN /install-dotnet.sh && rm -rf /install-dotnet.sh

##############################
# Install rustfmt & clippy   #
##############################
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1
COPY scripts/install-rustfmt.sh /
RUN /install-rustfmt.sh && rm -rf /install-rustfmt.sh

#########################################
# Install Powershell + PSScriptAnalyzer #
#########################################
COPY scripts/install-pwsh.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-pwsh.sh && rm -rf /install-pwsh.sh

#############################################################
# Install Azure Resource Manager Template Toolkit (arm-ttk) #
#############################################################
COPY scripts/install-arm-ttk.sh /
RUN --mount=type=secret,id=GITHUB_TOKEN /install-arm-ttk.sh && rm -rf /install-arm-ttk.sh

########################################################################################
# Run to build version file and validate image again because we installed more linters #
########################################################################################
RUN ACTIONS_RUNNER_DEBUG=true WRITE_LINTER_VERSIONS_FILE=true IMAGE="${IMAGE}" /action/lib/linter.sh
