# GitHub Super-Linter Slim Image Action

The **GitHub Super-Linter** maintains `two` major images:

- `github/super-linter:v4`
- `github/super-linter:slim-v4`

In order to help users pull this image more naturally, the `action.yml` in this directory can help users pull the `slim image`.

## Slim Image

The slim `github/super-linter:slim-v4` comes with all supported linters but removes the following:

- `rust` linters
- `dotenv` linters
- `armttk` linters
- `pwsh` linters
- `c#` linters

By removing these linters, we were able to bring the image size down by `2gb` and drastically speed up the build and download time.
The behavior will be the same for non-supported languages, and will skip languages at run time.
Example usage:

```yml
################################
# Run Linter against code base #
################################
- name: Lint Code Base
  uses: github/super-linter/slim@v4
  env:
    VALIDATE_ALL_CODEBASE: false
    DEFAULT_BRANCH: master
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
