# Cache downloaded packages

Super-linter installs several linters and formatters at runtime using package
managers and execution tools such as `npx`. The `standard` variant of
Super-linter installs these tools at build time in the container image, while
the `slim` variant installs these tools at runtime.

To speed up your Super-linter runs when using the `slim` variant by preventing
Super-linter from re-downloading these tools on each run, you can cache the
directories where Super-linter downloads these tools. Caching these directories
when running the `standard` variant will not yield any performance improvement.

When running Super-linter as a GitHub Action, the GitHub Actions runner
automatically mounts `${{ runner.temp }}/_github_home` from the runner host
machine to `/github/home` inside the container. You can use the `actions/cache`
action to preserve directories across workflow executions.

## GitHub Actions

To cache `npx` packages across workflow runs when using the `slim` image, cache
the `${{ runner.temp }}/_github_home/.npm` directory:

```yaml
jobs:
  super-linter:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Cache npm dependencies
        uses: actions/cache@v4
        with:
          path: ${{ runner.temp }}/_github_home/.npm
          # Update <path-to-super-linter> to
          # the path of the workflow running the Super-linter action (example: .github/workflows/lint.yaml),
          # or to the path of the environment file containing the Super-linter configuration
          # (see https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md#share-environment-variables-between-environments)
          key: >
            ${{ runner.os }}-super-linter-${{
            hashFiles('<path-to-super-linter>') }}
          restore-keys: |
            ${{ runner.os }}-super-linter-npm-

      - name: Run Super-linter
        uses: super-linter/super-linter/slim@latest
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Docker

When running Super-linter locally or outside GitHub Actions using Docker, mount
persistent local cache directories inside the container using volume mounts
(`-v`).

```bash
docker run \
  -e RUN_LOCAL=true \
  .... other options ....
  -v /path/to/local/codebase:/tmp/lint \
  -v /path/to/local/npm-cache:/github/home/.npm \
  --rm \
  ghcr.io/super-linter/super-linter:slim-latest
```
