# Creating GitHub Super-Linter Release

The Process to create a `Release` of the **GitHub/Super-Linter** is as follows:

- Every push to `master/main` triggers a build and deploy of the **GitHub/Super-linter**
- This creates the following images:
  - `github/super-linter:latest`
  - `github/super-linter:slim-latest`
- This also causes the `Release drafter` action to update a new draft Release

When an *Admin* wants to create a Release, the process is as follows:
- The *Admin* pushes an update to `master/main` and updates the `action.yml` to point to the next **Release** version
  - Example: `image: 'docker://ghcr.io/github/super-linter:v4.6.2'` becomes: `image: 'docker://ghcr.io/github/super-linter:v4.6.3'`
- Then the *admin* can go to the Release page and update the current `draft Release`
- The *Admin* will set the correct version strings, and update any additional information in the current `draft Release`
- Once the *Admin* is ready, they will select **Publish Release**
- This triggers the **GitHub Actions** to take the current codebase, and build the containers, and deploy to their locations
- This creates the following images:
  - `github/super-linter:latest`
  - `github/super-linter:v4`
  - `github/super-linter:v4.6.3`
  - `github/super-linter:slim-latest`
  - `github/super-linter:slim-v4`
  - `github/super-linter:slim-v4.6.3`
- At this point, the Release is complete and images are available for general consumption

## Pitfalls and Issues

If the *Admin* Does not update the `action.yml` to the new version before the Release is published, then the Release will point back to the old version, and any Images will also be sent back to the previous version.
This is very much a chicken and the egg issue, but seems to be easily resolved by following the correct path.
