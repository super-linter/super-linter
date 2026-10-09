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

## Architecture & Directory Structure

Super-linter is packaged as a multi-stage Docker image running on Alpine Linux:

- **Core Runtime**: Bash.
- **Packaging**: Multi-stage Docker builds ([`Dockerfile`](../Dockerfile)).
- **Orchestration**: GNU Make ([`Makefile`](../Makefile)).
- **Package Managers**: npm (Node), pip (Python), bundler (Ruby), composer
  (PHP).

### Core Directory Structure

- **`lib/`**: Contains the core logic scripts.
  - [`lib/linter.sh`](../lib/linter.sh): The main entry point. Orchestrates the
    initialization, file discovery, worker allocation, and execution of all
    linters.
  - **`lib/functions/`**: Utility modules handling specific operational phases.
    - [`buildFileList.sh`](../lib/functions/buildFileList.sh): Discovers,
      filters, and maps files to correspond to each linter.
    - [`detectFiles.sh`](../lib/functions/detectFiles.sh): Contains helper
      utilities for file identification.
    - [`linterCommands.sh`](../lib/functions/linterCommands.sh): Constructs the
      command strings to invoke each linter binary.
    - [`validation.sh`](../lib/functions/validation.sh): Validates environment
      configuration and manages execution flags.
    - [`worker.sh`](../lib/functions/worker.sh): Manages parallel orchestration
      and task worker threads.
  - **`lib/globals/`**: Static configuration and variable definitions.
    - [`languages.sh`](../lib/globals/languages.sh): Maps programming languages,
      extensions, and linter association names.
    - [`linterCommandsOptions.sh`](../lib/globals/linterCommandsOptions.sh):
      Configuration flags for invoking each linter.
    - [`linterRules.sh`](../lib/globals/linterRules.sh): Maps configuration rule
      filenames for each linter.
- **`dependencies/`**: Subdirectories mapping and pinning package manager
  dependencies (npm packages, Python requirements, Ruby gems, PHP packages,
  etc.).
- **`scripts/`**: Script tools used primarily during container builds or
  development testing (e.g., installer helpers).
- **`TEMPLATES/`**: Default configuration templates for the individual linters.
- **`test/`**: Contains integration and unit test suites.
- **Outputs**: Super-linter generates several outputs, described in the
  [Super-linter outputs section in the readme](../README.md#super-linter-outputs).

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
  before running tests that depend on the image. Defaults to building the
  `standard` image. To build the `slim` image, set the `CONTAINER_IMAGE_TARGET`
  environment variable to `slim` before running `make`:

  ```bash
  CONTAINER_IMAGE_TARGET="slim" make docker
  ```

- `make lint-codebase`: Runs a comprehensive set of linters against the entire
  codebase to check for style and formatting issues.
- `make lint-commit`: Runs `commitlint` to validate commit messages between
  `main` and `HEAD`. You can customize the arguments by passing the
  `COMMITLINT_ARGS` variable:

  ```bash
  make lint-commit COMMITLINT_ARGS="--last"
  ```

- `make audit`: Runs all security audit targets (`composer-audit`, `npm-audit`,
  `pip-audit`, `trivy`) to check for known vulnerabilities in downstream
  dependencies and container filesystems. You can also execute each target in
  isolation (e.g., `make npm-audit`).
- `make fix-codebase`: Automatically fixes linting and formatting issues.
- `make format-codebase`: Runs all formatter targets (such as Prettier and
  `shfmt`) to format files in the repository.
- `make format-prettier`: Runs Prettier to format the codebase. You can format
  specific files or directories in isolation by passing the `FILES_TO_FORMAT`
  variable:

  ```bash
  make format-prettier FILES_TO_FORMAT="test/linters/html/html_good_01.html"
  ```

- `make format-shfmt`: Runs `shfmt` to format shell scripts in the codebase. You
  can format specific files or directories in isolation by passing the
  `FILES_TO_FORMAT` variable:

  ```bash
  make format-shfmt FILES_TO_FORMAT="scripts/manage-vulnerability-issues.sh"
  ```

  > [!NOTE]
  >
  > Do not run formatters or linters on files inside `test/linters/` containing
  > `"bad"` in their filename or path (e.g., `html_bad_01.html`). These files
  > are intentionally syntactically malformed to test linter failure coverage.
  > Always respect `.prettierignore` and other configuration-specific ignore
  > files.

- `make test-lib`: Runs the unit test suites for Super-linter's core library
  functions and globals (`test-log`, `test-validation`, `test-build-file-list`,
  etc.). Each sub-target can also be run individually.
- `make inspec`: Runs the InSpec profile test suite to verify installed
  packages, binaries, and versions inside the built container image.
- `make test`: Runs the complete test suite. The full test suite runs complex
  container actions and is resource-intensive. To run a specific subset of
  tests, you can use `make help` to find the relevant targets.
- `make open-shell-super-linter-container`: Opens an interactive shell in the
  Super-linter container.
- `make run-command-super-linter-container CMD="your command"`: Runs a one-off
  command inside the Super-linter container. Example:
  `make run-command-super-linter-container CMD="ls -alh"`.

  > [!NOTE]
  >
  > Inside container actions launched via `make`, the repository root is mounted
  > at `/tmp/lint` (not `/app` or `.`). Always reference `/tmp/lint` when
  > specifying absolute container paths.

The implementation of the Make targets of this project that use Docker to run
tests in isolated environments assumes that you can
[run Docker as a non-root user](https://docs.docker.com/engine/install/linux-postinstall/).

## Managing Dependencies & Lockfiles

When updating dependencies or fixing security audit issues:

- **Run package manager commands inside the container**: Do not run `npm`,
  `pip`, `bundler`, or `composer` directly on the host. Always run them inside
  the Super-linter container (or the corresponding stage image) to guarantee
  matching runtime and tool versions.
- **Mount parent directories, not individual files**: When mounting files into a
  container to write updates back to the host, mount the parent directory (e.g.,
  `-v "$(CURDIR)/dependencies":/app`) rather than individual files (e.g.,
  `-v package.json:/package.json`). Mounting individual files can break Docker
  bind-mount inodes when tools perform atomic writes (creating a temporary file
  and renaming it).
- **Use lockfile-only updates**:
  - **npm**: Use `npm install --package-lock-only` or
    `npm update --package-lock-only` to update `package-lock.json` without
    creating `node_modules` on the host.
  - **Composer**: Use `composer update --no-install` to update `composer.lock`
    without creating `vendor` on the host.

Example for updating npm dependencies:

```bash
docker run -t \
  --entrypoint /bin/bash \
  --rm \
  --user "$(id -u):$(id -g)" \
  -v "$(CURDIR)/dependencies":/app \
  --workdir /app \
  ghcr.io/super-linter/super-linter:latest \
  -c "npm update --package-lock-only"
```

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

## Build the container image and run the test suite locally

To run the build and test process locally, in the top-level super-linter
directory, do the following:

1. [Create a fine-grained GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).
   The token only needs to have public/read-only access.

1. Store the generated personal access token in a file in the top-level
   directory (This file is ignored by Git).

   ```bash
   echo "github_pat_XXXXXX_XXXXXX" > .github-personal-access-token
   ```

1. Run the build process:

   ```bash
   . ./scripts/build-metadata.sh && make
   ```

### Run the test suite against an arbitrary Super-linter container image

You can run the test suite against an arbitrary super-linter container image.

Here is an example that runs the test suite against the `v8.2.1` container image
version.

```shell
CONTAINER_IMAGE_ID="ghcr.io/super-linter/super-linter:v8.2.1" \
make docker-pull test
```

### Get the list of available build targets

To get the list of the available `Make` targets, run the following command:

```shell
make help
```

### Automatically fix formatting and linting issues

To automatically fix linting and formatting issues when supported, run the
following command:

```shell
make fix-codebase
```

## Additional documentation

Here are some other documents that you might find useful:

- [Release Process](release-process.md): This document describes the process for
  creating a new release of Super-linter.
- [Add a new linter](add-new-linter.md): This guide explains how to add support
  for a new linter to Super-linter.
- [Upgrade Guide](upgrade-guide.md): This document provides instructions for
  upgrading Super-linter to a new major version.
