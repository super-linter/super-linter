# Super-Linter releases

The Process to create a super-linter release is as follows:

1. Merge the release pull request.

## Release workflows

Every push to the default branch triggers GitHub Actions workflows that:

- Build and deploy of super-linter container images:

  - `super-linter/super-linter:latest`
  - `super-linter/super-linter:slim-latest`

- Update to the release pull request.
