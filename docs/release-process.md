# Super-Linter releases

The Process to create a super-linter release is as follows:

1. Merge the release pull request.

## Preview the release pull request

In order to have a preview of the next release before merging a pull
request that updates the configuration of the tooling that we use to create
releases, do the following:

1. Run:

    ```shell
    make release-please-dry-run
    ```

This command also runs as part of the [CI process](../.github/workflows/ci.yml).

## Release workflows

Every push to the default branch triggers GitHub Actions workflows that:

- Build and deploy of super-linter container images:

  - `super-linter/super-linter:latest`
  - `super-linter/super-linter:slim-latest`

- Update the next release pull request.

## Release automation tooling

In order to automate releases, we use
[release-please](https://github.com/googleapis/release-please).

We configure release-please using two files:

- [release-please configuration file](../.github/release-please/release-please-config.json):
  contains release-please configuration.
- [release-please manifest file](../.github/release-please/.release-please-manifest.json):
  contains information about the current release.
