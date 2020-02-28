# Run Super-Linter locally to test your branch of code
If you want to test locally against the **Super-Linter** to test your branch of code, you will need to complete the following:
- Clone your testing source code to your local environment
- Install Docker to your local environment
- Pull the container down
- Run the container
- Debug/Troubleshoot

## Install Docker to your local machine
You can follow the link below on how to install and configure **Docker** on your local machine
- [Docker Install Documentation](https://docs.docker.com/install/)

## Download the latest Super-Linter Docker container
- Pull the latest **Docker** container down from **DockerHub**
  - `docker pull admiralawkbar/super-linter:latest`
Once the container has been downloaded to your local environment, you can then begin the process, or running the container against your codebase.

## Run the container Locally
- You can run the container locally with the following **Base** flags to run your code:
  - `docker run -e RUN_LOCAL=true -v /path/to/local/codebase:/tmp/lint admiralawkbar/super-linter`
    - To run against a single file you can use: `docker run -e RUN_LOCAL=true -v /path/to/local/codebase/file:/tmp/lint/file admiralawkbar/super-linter`
  - **NOTE:** You need to pass the `RUN_LOCAL` flag to bypass some of the GitHub Actions checks, as well as the mapping of your local codebase to `/tmp/lint` so that the linter can pick up the code
  - **NOTE:** The flag:`RUN_LOCAL` will set: `VALIDATE_ALL_CODEBASE` to true. This means it will scan **all** the files in the directory you have mapped. If you want to only validate a subset of your codebase, map a folder with only the files you wish to have linted
- You can add as many **Additional** flags as needed:
  - **VALIDATE_YAML**
    - `-e VALIDATE_YAML=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_JSON**
    - `-e VALIDATE_JSON=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_XML**
    - `-e VALIDATE_XML=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_MD**
    - `-e VALIDATE_MD=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_BASH**
    - `-e VALIDATE_BASH=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_PERL**
    - `-e VALIDATE_PERL=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_PYTHON**
    - `-e VALIDATE_PYTHON=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_RUBY**
    - `-e VALIDATE_RUBY=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_COFFEE**
    - `-e VALIDATE_COFFEE=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_ANSIBLE**
    - `-e VALIDATE_ANSIBLE=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_JAVASCRIPT**
    - `-e VALIDATE_JAVASCRIPT=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_DOCKER**
    - `-e VALIDATE_DOCKER=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **VALIDATE_GO**
    - `-e VALIDATE_GO=<true|false>`
    - Default: `true`
    - Flag to enable or disable the linting process of the language
  - **ANSIBLE_DIRECTORY**
    - `-e ANSIBLE_DIRECTORY=</path/local/to/codebase/with/ansible>`
    - Default: `/ansible`
    - Flag to set the root directory for Ansible file location(s)

## Troubleshooting

### Run container and gain access to the command line
If you need to run the container locally and gain access to its command line, you can run the following command:
- `docker run -it --entrypoint /bin/bash admiralawkbar/super-linter`
- This will drop you in the command line of the docker container for any testing or troubleshooting that may be needed.

### Found issues
If you find a *bug* or *issue*, please open a **GitHub** issue at: `https://github.com/github/super-linter/issues`
