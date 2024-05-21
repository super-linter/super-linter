# Run super-linter outside GitHub Actions

If you want to run super-linter outside GitHub Actions, you need a container
runtime engine to run the super-linter container image.

## Run super-linter Locally

You can run the container locally with the following configuration options to run your code:

```bash
docker run \
  -e LOG_LEVEL=DEBUG \
  -e RUN_LOCAL=true \
  -v /path/to/local/codebase:/tmp/lint \
  --rm \
  ghcr.io/super-linter/super-linter:latest
```

This example uses the `latest` container image version. If you're trying to reproduce
an issue, or running super-linter as part of your CI pipeline, we recommend that
you **refer to a specific version instead**.

Notes:

- To run against a single file you can use: `docker run -e RUN_LOCAL=true -e USE_FIND_ALGORITHM=true -v /path/to/local/codebase/file:/tmp/lint/file ghcr.io/super-linter/super-linter`
- You need to pass the `RUN_LOCAL` option to bypass some of the GitHub Actions checks, as well as the mapping of your local codebase to `/tmp/lint`.
- If you want to override the `/tmp/lint` folder, you can set the `DEFAULT_WORKSPACE` environment variable to point to the folder you'd prefer to scan.
- You can add as many configuration options as needed. Configuration options are documented in the [README](../README.md#configure-super-linter).

### Azure

Check out this [article](https://blog.tyang.org/2020/06/27/use-github-super-linter-in-azure-pipelines/)

### GitLab

Check out this GitLab CI Component which only requires a single line of code: [GitLab CI Component for Super-Linter](https://gitlab.com/explore/catalog/guided-explorations/ci-components/super-linter)

### Run on Codespaces and Visual Studio Code

This repository provides a DevContainer for [remote development](https://code.visualstudio.com/docs/remote/containers).

## Share Environment variables between environments

To avoid duplication if you run super-linter both locally and in other
environements, such as CI, you can define configuration options once, and load
them accordingly:

1. Create a configuration file for super-linter `super-linter.env`. For example:

    ```bash
    VALIDATE_ALL_CODEBASE=true
    ```

1. Load the super-linter configuration file when running outside GitHub Actions:

    ```bash
    docker run --rm \
        -e RUN_LOCAL=true \
        --env-file ".github/super-linter.env" \
        -v "$(pwd)":/tmp/lint \
        ghcr.io/super-linter/super-linter:latest
    ```

1. Load the super-linter configuration file when running in GitHub Actions by
    adding the following step to the GitHub Actions workflow that runs
    super-linter, after checking out your repository and before running
    super-linter:

    ```yaml
    - name: Load super-linter configuration
      run: cat .github/super-linter.env >> "$GITHUB_ENV"
    ```

## Build the container image and run the test suite locally

To run the build and test process locally, do the following:

1. [Create a fine-grained GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).
1. Create a file to store the personal access token on your machine:

    ```bash
    touch .github-personal-access-token
    ```

    The file to store the personal access token is ignored by Git.

1. Run the build process:

    ```bash
    make
    ```

To avoid invalidating the build cache, and reuse it, you can set build metadata
to arbitrary values before running `make`:

```bash
BUILD_DATE=2023-12-12T09:32:05Z \
BUILD_REVISION=83c16f63caa9d432df4519efb4c58a56e2190bd6 \
BUILD_VERSION=83c16f63caa9d432df4519efb4c58a56e2190bd6 \
make
```

### Run the test suite against an arbitrary super-linter container image

You can run the test suite against an arbitrary super-linter container image.

Here is an example that runs the test suite against the `v5.4.3` container
image version.

```shell
CONTAINER_IMAGE_ID="ghcr.io/super-linter/super-linter:v5.4.3" \
BUILD_DATE="2023-10-17T17:00:53Z" \
BUILD_REVISION=b0d1acee1f8050d1684a28ddbf8315f81d084fe9 \
BUILD_VERSION=b0d1acee1f8050d1684a28ddbf8315f81d084fe9 \
make docker-pull test
```

Initialize the `BUILD_DATE`, `BUILD_REVISION`, and `BUILD_VERSION` variables
with the values for that specific container image version. You can get these
values from the build log for that version.

### Get the list of available build targets

To get the list of the available `Make` targets, run the following command:

```shell
make help
```
