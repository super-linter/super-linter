# Super-linter upgrade guide

This document helps you upgrade from a super-linter version to newer ones:

- [Upgrade from v5 to v6](#upgrade-from-v5-to-v6)

## Upgrade from v5 to v6

This section helps you migrate from super-linter `v5` to `v6`.

### Experimental batch workers

- Experimental batch support is deprecated. You can safely remove the
  `EXPERIMENTAL_BATCH_WORKER` variable from your configuration.

### Gitleaks

- If you defined secret patterns in `.gitleaks.toml`, Gitleaks may report errors
  about that file. If this happens, you can
  [configure Gitleaks to ignore that file](https://github.com/gitleaks/gitleaks/tree/master?tab=readme-ov-file#gitleaksignore).
- Gitleaks doesn't consider the `FILTER_REGEX_EXCLUDE`, `FILTER_REGEX_INCLUDE`,
  `IGNORE_GENERATED_FILES`, `IGNORE_GITIGNORED_FILES` variables. For more
  information about how to ignore files with Gitleaks, see
  [the Gitleaks documentation](https://github.com/gitleaks/gitleaks/tree/master?tab=readme-ov-file#gitleaksignore).

### Jscpd

- The `VALIDATE_JSCPD_ALL_CODEBASE` variable is deprecated. Jscpd now lints the
  entire workspace instead of linting files one by one. You can safely remove
  the `VALIDATE_JSCPD_ALL_CODEBASE` variable from your configuration.
- Jscpd doesn't consider the `FILTER_REGEX_EXCLUDE`, `FILTER_REGEX_INCLUDE`,
  `IGNORE_GENERATED_FILES`, `IGNORE_GITIGNORED_FILES` variables. For more
  information about how to ignore files with Jscpd, see
  [the Jscpd documentation](https://github.com/kucherenko/jscpd/tree/master/packages/jscpd).

### textlint

- textlint doesn't consider the `FILTER_REGEX_EXCLUDE`, `FILTER_REGEX_INCLUDE`,
  `IGNORE_GENERATED_FILES`, `IGNORE_GITIGNORED_FILES` variables. For more
  information about how to ignore files with textlint, see
  [the textlint documentation](https://textlint.github.io/docs/ignore.html).

### VALIDATE_KOTLIN_ANDROID

- The `VALIDATE_KOTLIN_ANDROID` variable has been deprecated. If you set it in
  your configuration, change it to `VALIDATE_KOTLIN`.
