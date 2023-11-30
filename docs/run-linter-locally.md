# Run Super-Linter locally to test your branch of code

If you want to test locally against the **Super-Linter** to test your branch of
code or to reproduce an issue, do the following:

- Clone your testing source code to your local environment
- Install Docker to your local environment
- Pull the container
- Run the container locally

If you're contributing to Super-Linter, you also need to do following:

- Run the test suite locally

## Install Docker to your local machine

You can follow the link below on how to install and configure **Docker** on your local machine

- [Docker Install Documentation](https://docs.docker.com/install/)

## Download the latest Super-Linter Docker container

- Pull the latest **Docker** container image from the registry
  - `docker pull ghcr.io/super-linter/super-linter:latest`
    Once the container has been downloaded to your local environment, you can then begin the process, or running the container against your codebase.

## Run the container Locally

You can run the container locally with the following flags to run your code:

```bash
docker run \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e RUN_LOCAL=true \
  -v /path/to/local/codebase:/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```

This example uses the `latest` container image version. If you're trying to reproduce
an issue, **refer to a specific version instead**.

Notes:

- To run against a single file you can use: `docker run -e RUN_LOCAL=true -e USE_FIND_ALGORITHM=true -v /path/to/local/codebase/file:/tmp/lint/file ghcr.io/super-linter/super-linter`
- You need to pass the `RUN_LOCAL` flag to bypass some of the GitHub Actions checks, as well as the mapping of your local codebase to `/tmp/lint`.
- If you want to override the `/tmp/lint` folder, you can set the `DEFAULT_WORKSPACE` environment variable to point to the folder you'd prefer to scan.
- The flag:`RUN_LOCAL` will set: `VALIDATE_ALL_CODEBASE` to true. This means it will scan **all** the files in the directory you have mapped. If you want to only validate a subset of your codebase, map a folder with only the files you wish to have linted.
- Add the `--rm` docker flag to automatically removes the container after execution.
- You can add as many flags as needed. Flags are documented in the [README](../README.md#Environment-variables).

## Sharing Environment variables between Local and CI

If you run both locally and on CI it's very helpful to only have to define your env variables once.
This is one setup using Github's [STRTA](https://github.com/github/scripts-to-rule-them-all) style to do so.

### .github/super-linter.env

This is the shared location for the super-linter variables. Example:

```bash
VALIDATE_ALL_CODEBASE=true
VALIDATE_DOCKERFILE_HADOLINT=false
VALIDATE_EDITORCONFIG=false
VALIDATE_GITLEAKS=false
```

### scripts/lint

This always runs the local docker based linting.

```bash
docker run --rm \
    -e RUN_LOCAL=true \
    --env-file ".github/super-linter.env" \
    -v "$PWD":/tmp/lint ghcr.io/super-linter/super-linter:latest
```

### scripts/test

This runs the local lint when not on CI.

```bash
if [ "$(whoami)" == "runner" ]; then
  echo "We are on GitHub, so don't run lint manually"
else
  echo "Running locally because we don't think we are on GitHub"
  lint_ci
fi
```

### .github/workflows/ci.yml

This loads the environment variables before running the GitHub Actions job.

```yaml
name: CI

on:
  pull_request:

jobs:
  lint:
    # Run GH Super-Linter against code base
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cat .github/super-linter.env >> "$GITHUB_ENV"
      - name: Lint Code Base
        uses: super-linter/super-linter@v5
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          DEFAULT_BRANCH: main
```

## Build the container image and run the test suite locally

You can run the test suite locally with the following command:

```shell
make
```

The test suite will build the container image and run the test suite against a
a container that is an instance of that container image.

### Run the test suite against an arbitrary super-linter container image

You can run the test suite against an arbitrary super-linter container image.

Here is an example that runs the test suite against the `standard` flavor of the
`v5.4.3` image.

```shell
CONTAINER_IMAGE_ID="ghcr.io/super-linter/super-linter:v5.4.3" \
CONTAINER_IMAGE_TARGET="standard" \
BUILD_REVISION=b0d1acee1f8050d1684a28ddbf8315f81d084fe9 \
BUILD_VERSION=b0d1acee1f8050d1684a28ddbf8315f81d084fe9 \
make docker-pull test
```

## Troubleshooting

### Run container and gain access to the command-line

If you need to run the container locally and gain access to its command-line, you can run the following command:

- `docker run -it --entrypoint /bin/bash ghcr.io/super-linter/super-linter`
- This will drop you in the command-line of the docker container for any testing or troubleshooting that may be needed.

### Found issues

If you find a _bug_ or _issue_, please open a **GitHub** issue at: [super-linter/super-linter/issues](https://github.com/super-linter/super-linter/issues)
