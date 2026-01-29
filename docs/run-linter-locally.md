# Run super-linter outside GitHub Actions

If you want to run super-linter outside GitHub Actions, you need a container
runtime engine to run the super-linter container image.

## Run super-linter Locally

You can run the container locally with the following configuration options to
run your code:

```bash
docker run \
  -e LOG_LEVEL=DEBUG \
  -e RUN_LOCAL=true \
  -v /path/to/local/codebase:/tmp/lint \
  --rm \
  ghcr.io/super-linter/super-linter:latest
```

This example uses the `latest` container image version. If you're trying to
reproduce an issue, or running super-linter as part of your CI pipeline, we
recommend that you **refer to a specific version instead**.

Notes:

- To run against a single file you can use:
  `docker run -e RUN_LOCAL=true -e USE_FIND_ALGORITHM=true -v /path/to/local/codebase/file:/tmp/lint/file ghcr.io/super-linter/super-linter`
- You need to pass the `RUN_LOCAL` option to bypass some of the GitHub Actions
  checks, as well as the mapping of your local codebase to `/tmp/lint`.
- If you want to override the `/tmp/lint` folder, you can set the
  `DEFAULT_WORKSPACE` environment variable to point to the folder you'd prefer
  to scan.
- If the default branch for your repository doesn't match the default, you can
  use the `DEFAULT_BRANCH` variable to set the default branch. For more
  information about the default value of the `DEFAULT_BRANCH` variable, see the
  [Readme](../README.md).
- You can add as many configuration options as needed. Configuration options are
  documented in the [readme](../README.md#configure-super-linter).

### Working with Git Worktrees

Git worktrees allow you to have multiple working directories associated with a
single Git repository, which is useful for working on different branches
simultaneously without switching contexts.

When running super-linter in a Git worktree, you must mount both the worktree
directory and the main Git repository directory into the container. This is
because worktrees store only the working files, while Git metadata remains in
the main repository's `.git` directory.

#### Example Docker Command for Git Worktrees

```bash
docker run \
  -e LOG_LEVEL=DEBUG \
  -e RUN_LOCAL=true \
  -v /path/to/your/worktree:/tmp/lint \
  -v /path/to/main/repo/.git:/path/to/main/repo/.git \
  --rm \
  ghcr.io/super-linter/super-linter:latest
```

#### Finding Your Git Common Directory

To find the main Git directory that needs to be mounted, use the following Git
command from within your worktree:

```bash
git rev-parse --path-format=absolute --git-common-dir
```

This will output the absolute path to the main Git directory, for example:

```bash
/path/to/main/repo/.git
```

Use this output as the source path for your Docker volume mount.

#### Helpful Error Messages

If you forget to mount the main Git directory, super-linter will detect this and
provide a helpful error message indicating exactly which directory needs to be
mounted:

```text
/path/to/main/repo/.git/worktrees/my-worktree doesn't exist.
Ensure to mount it as a volume when running the Super-linter container.
See https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md
```

### GitLab

To run Super-linter in your GitLab CI/CD pipeline, You can use the following
snippet:

```yaml
super-linter:
  stage: lint
  image:
    name: ghcr.io/super-linter/super-linter:latest # set a stable version tag and the sha checksum in production for reproducible runs
    entrypoint: [""]
  script:
    - git fetch origin $CI_DEFAULT_BRANCH # clone the default branch from this repository
    - /action/lib/linter.sh
  variables:
    # More info at https://github.com/super-linter/super-linter?tab=readme-ov-file#configure-super-linter
    GIT_DEPTH: 0 # clone the whole history of the required branches
    RUN_LOCAL: "true"
    DEFAULT_WORKSPACE: $CI_PROJECT_DIR
    DEFAULT_BRANCH: $CI_DEFAULT_BRANCH
```

Note that this is a high-level example that you should customize for your needs.

### Run on Codespaces and Visual Studio Code

This repository provides a DevContainer for
[remote development](https://code.visualstudio.com/docs/remote/containers).

## Share Environment variables between environments

To avoid duplication if you run super-linter both locally and in other
environments, such as CI, you can define configuration options once, and load
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
     # Use grep inverse matching to exclude eventual comments in the .env file
     # because the GitHub Actions command to set environment variables doesn't
     # support comments.
     # Ref: https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#setting-an-environment-variable
     run: grep -v '^#' .github/super-linter.env >> "$GITHUB_ENV"
   ```
