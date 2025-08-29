# Development

This document describes how to set up your development environment to contribute
to Super-linter.

## Prerequisites

You need the following tools to be installed on your system. The listed versions
are not a strict requirement, but they are known to be working as the project
has been tested with them:

- Git: version 2.51
- GNU Make: version 4.4.1
- Docker: version 28.3.3

### Visual Studio Code and devcontainers

We recommend using [Visual Studio Code](https://code.visualstudio.com/) with the
[Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
for a consistent and reproducible development environment. The repository
contains a `.devcontainer` configuration that sets up a container with all the
necessary dependencies and tools to work on Super-linter. The devcontainer also
includes extensions that run most linters and formatters as you save files.

To get started with the devcontainer, open the repository in Visual Studio Code,
and when prompted, select "Reopen in Container". This will build the container
image and start a development environment with all the tools you need.

## Using Make to run development tasks

This project uses `make` to automate common development tasks. Here are some of
the most important targets:

- `make help`: Displays a list of all available `make` targets with a short
  description of what they do. This is a good starting point to discover what
  tasks are automated.
- `make info`: Shows information about the runtime environment, such as the
  current user, directory, and details about the container image being used for
  testing.
- `make docker`: Builds the Super-linter container image. This is necessary
  before running tests that depend on the image.
- `make lint-codebase`: Runs a comprehensive set of linters against the entire
  codebase to check for style and formatting issues.
- `make fix-codebase`: Automatically fixes linting and formatting issues.
- `make test`: Runs the complete test suite. To run a specific subset of tests,
  you can use `make help` to find the relevant targets.

The implementation of the Make targets of this project that use Docker to run
tests in isolated environments assumes that you can
[run Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/).

## Recommended development flow

We recommend the following workflow for contributing to Super-linter:

1.  **Fork the repository:** Start by
    [forking the repository](https://github.com/super-linter/super-linter/fork)
    to your own GitHub account.

    > **Note for maintainers:** If you have push access to the Super-linter
    > repository, you can skip this step and clone the repository directly.

2.  **Clone your fork:** Clone your forked repository to your local machine:

    ```sh
    git clone https://github.com/<YOUR_USERNAME>/super-linter.git
    ```

3.  **Create a new branch:** Create a new branch for your changes:

    ```sh
    git checkout -b <BRANCH_NAME>
    ```

    Replace `<BRANCH_NAME>` with a descriptive name for your changes (e.g.,
    `add-linter-for-new-language`).

4.  **Make your changes:** Make the necessary changes to the codebase.
5.  **Run tests:** Before submitting your changes, make sure to run the test
    suite to ensure that everything is working as expected.

    ```sh
    make test
    ```

    You can also run more specific tests. Use `make help` to see the available
    targets.

6.  **Submit a pull request:** Once you are happy with your changes, push your
    branch to your fork and
    [submit a pull request](https://github.com/super-linter/super-linter/pulls)
    to the main repository.

If you are adding a new linter, please follow the instructions in the
[add a new linter guide](add-new-linter.md).

## Additional documentation

Here are some other documents that you might find useful:

- [Release Process](release-process.md): This document describes the process for
  creating a new release of Super-linter.
- [Add a new linter](add-new-linter.md): This guide explains how to add support
  for a new linter to Super-linter.
- [Upgrade Guide](upgrade-guide.md): This document provides instructions for
  upgrading Super-linter to a new major version.
