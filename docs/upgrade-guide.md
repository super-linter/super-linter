# Super-linter upgrade guide

This document helps you upgrade from a super-linter version to newer ones:

- [Upgrade from v5 to v6](#upgrade-from-v5-to-v6)

## Upgrade from v5 to v6

This section helps you upgrade from super-linter `v5` to `v6`.

### eslint-config-airbnb-typescript

- eslint-config-airbnb-typescript (a library to add TypeScript support to
  Airbnb's ESLint config)
  [appears to be unmaintained](https://github.com/iamturns/eslint-config-airbnb-typescript/issues/314).
  We had to remove it from super-linter because it was blocking updates to other
  dependencies, such as ESLint.

### Checkstyle

- Checkstyle
  [embeds some configuration files](https://checkstyle.sourceforge.io/cmdline.html#Command_line_usage),
  such as `sun_checks.xml` and `google_checks.xml`. There is no need to provide
  your own checkstyle configuration files if it matches one of the embedded
  ones. You can safely remove your Checkstyle configuration file if it matches
  one of the embedded ones.

### Dart

- super-linter doesn't include a default configuration file for `dart analyzer`
  because the Dart SDK doesn't support running `dart analyzer` against an
  arbitrary configuration file anymore. For more information about how to
  customize static analysis of Dart files, see
  [Customizing static analysis](https://dart.dev/tools/analysis) in the Dart SDK
  documentation.

### ERROR_ON_MISSING_EXEC_BIT

- `ERROR_ON_MISSING_EXEC_BIT` has been deprecated to align the
  `VALIDATE_BASH_EXEC` check to the other linters, removing a surprising corner
  case. If `VALIDATE_BASH_EXEC` is set to `true` and a shell script is not
  marked as executable, the script will not pass validation. You can remove the
  `ERROR_ON_MISSING_EXEC_BIT` variable from your super-linter configuration.

### Experimental batch workers

- Experimental batch support is deprecated. You can safely remove the
  `EXPERIMENTAL_BATCH_WORKER` variable from your configuration.

### Gitleaks

- If you defined secret patterns in `.gitleaks.toml`, Gitleaks may report errors
  about that file. If this happens, you can
  [configure Gitleaks to ignore that file](https://github.com/gitleaks/gitleaks/tree/master?tab=readme-ov-file#gitleaksignore).

### Jscpd

- The `VALIDATE_JSCPD_ALL_CODEBASE` variable is deprecated. Jscpd now lints the
  entire workspace instead of linting files one by one. You can safely remove
  the `VALIDATE_JSCPD_ALL_CODEBASE` variable from your configuration.
- Jscpd doesn't consider the `FILTER_REGEX_EXCLUDE`, `FILTER_REGEX_INCLUDE`,
  `IGNORE_GENERATED_FILES`, `IGNORE_GITIGNORED_FILES` variables. For more
  information about how to ignore files with Jscpd, see
  [the Jscpd documentation](https://github.com/kucherenko/jscpd/tree/master/packages/jscpd).

### USE_FIND_ALGORITHM and VALIDATE_ALL_CODEBASE used together

- Setting `USE_FIND_ALGORITHM` to `true` and `VALIDATE_ALL_CODEBASE` to `false`
  is an unsupported configuration. super-linter `v5` and earlier silently
  ignored `VALIDATE_ALL_CODEBASE` when `USE_FIND_ALGORITHM` is set to `true`,
  leading to potentially confusing behavior for users. super-linter `v6`
  explicitly fail in this case. Remove one of the two from your configuration,
  depending on the desired behavior.

### VALIDATE_KOTLIN_ANDROID

- The `VALIDATE_KOTLIN_ANDROID` variable has been deprecated because ktlint
  handles linting Kotlin files for Android using a configuration option, so
  super-linter doesn't need to account for this special case anymore. If you
  set `VALIDATE_KOTLIN_ANDROID` in your configuration, change it to
  `VALIDATE_KOTLIN` and configure ktlint to lint Android files.
