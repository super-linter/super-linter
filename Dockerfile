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
      com.github.actions.description="Lint your codebase with Github Actions" \
      com.github.actions.icon="code" \
      com.github.actions.color="red" \
      maintainer="GitHub DevOps <github_devops@github.com>"

##################
# Run the Update #
##################
RUN apk add --no-cache \
    bash git musl-dev jq \
    npm nodejs bash git musl-dev jq gcc curl

RUN pip install --upgrade --no-cache-dir \
    awscli aws-sam-cli yq

####################################
# Setup AWS CLI Command Completion #
####################################
RUN echo complete -C '/usr/local/bin/aws_completer' aws >> ~/.bashrc

###########################################
# Load GitHub Env Vars for Github Actions #
###########################################
ENV GITHUB_SHA=${GITHUB_SHA}
ENV GITHUB_EVENT_PATH=${GITHUB_EVENT_PATH}
ENV GITHUB_WORKSPACE=${GITHUB_WORKSPACE}

###########################
# Copy files to container #
###########################
COPY lib /action/lib

######################
# Set the entrypoint #
######################
ENTRYPOINT ["/action/lib/entrypoint.sh"]
