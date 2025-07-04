# Super-linter upgrade guide

This document helps you upgrade from a super-linter version to newer ones:

- [Upgrade from v7.4.0 to v8.0.0](#upgrade-from-v740-to-v8)
- [Upgrade from v7.3.0 to v7.4.0](#upgrade-from-v730-to-v740)
- [Upgrade from v6 to v7](#upgrade-from-v6-to-v7)
- [Upgrade from v6.7.0 to v6.8.0](#upgrade-from-v670-to-v680)
- [Upgrade from v5 to v6](#upgrade-from-v5-to-v6)

## Upgrade from v7.4.0 to v8

This section helps you upgrade from super-linter `v7.4.0` to `v8.0.0`.

### Removed unmaintained linters and formatters

Super-linter `v8.0.0` doesn't include the following linters anymore because they
are unmaintained:

- gherkin-lint
- Kubeconform
- JavaScript Standard
- Pyink
- Raku compiler
- tekton-lint
- TypeScript Standard

You can remove the following variables from your Super-linter configuration:

- `FIX_JAVASCRIPT_STANDARD`
- `FIX_PYTHON_PYINK`
- `FIX_TYPESCRIPT_STANDARD`
- `KUBERNETES_KUBECONFORM_OPTIONS`
- `PYTHON_PYINK_CONFIG_FILE`
- `TYPESCRIPT_STANDARD_TSCONFIG_FILE`
- `VALIDATE_GHERKIN`
- `VALIDATE_JAVASCRIPT_STANDARD`
- `VALIDATE_KUBERNETES_KUBECONFORM`
- `VALIDATE_PYTHON_PYINK`
- `VALIDATE_RAKU`
- `VALIDATE_TEKTON`
- `VALIDATE_TYPESCRIPT_STANDARD`

### Removed ESLint plugins and configurations

Super-linter `v8.0.0` doesn't include the following ESLint configurations and
plugins anymore because they are blocking the upgrade to ESLint v9:

- `eslint-config-airbnb`: latest release dates back to 2021, and it's blocking
  the upgrade to ESLint v9.
- `@react-native/eslint-config`: it's blocking the upgrade to ESLint v9.

### Removed unmaintained dependencies

Super-linter `v8.0.0` doesn't include the following node dependencies anymore
because they unmaintained:

- `postcss-less`
- `prettyjson`
- `pug`

### Update ESLint default configuration and filenames

Updated the default ESLint configuration file to the
[supported configuration format](https://eslint.org/docs/latest/use/configure/configuration-files).

Changed the default values for ESLint configuration filenames:

- `JAVASCRIPT_ES_CONFIG_FILE` is now set to `eslint.config.mjs`
- `TYPESCRIPT_ES_CONFIG_FILE` is now set to `eslint.config.mjs`

## Upgrade from v7.3.0 to v7.4.0

This section helps you upgrade from super-linter `v7.3.0` to `v7.4.0`.

### editorconfig-checker default configuration filename

[editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker?tab=readme-ov-file#configuration)
changed the default configuration filename from `.ecrc` to
`.editorconfig-checker.json`. Super-linter `v7.4.0` changed the default value of
the `EDITORCONFIG_FILE_NAME` configuration variable to reflect that. If you are
using an `.ecrc` file, rename it to `.editorconfig-checker.json`.

## Upgrade from v6 to v7

This section helps you upgrade from super-linter `v6` to `v7`.

### sql-lint, VALIDATE_SQL and SQL_CONFIG_FILE

[sql-lint](https://github.com/joereynolds/sql-lint) appears to be unmaintained,
and its dependencies are affected by known security vulnerabilities. For this
reason, Super-linter `v7` doesn't include sql-lint anymore. If you are using
sql-lint to check your SQL files, we recommend that you evaluate
[sqlfluff](https://sqlfluff.com/), included in Super-linter since `v4.6.0`.

You can remove the `VALIDATE_SQL` and `SQL_CONFIG_FILE` because they have no
effect.

## Upgrade from v6.7.0 to v6.8.0

This section helps you upgrade from super-linter `v6.7.0` to `v6.8.0`.

### JAVASCRIPT_DEFAULT_STYLE and TYPESCRIPT_DEFAULT_STYLE

- The `JAVASCRIPT_DEFAULT_STYLE` and `TYPESCRIPT_DEFAULT_STYLE` have been
  deprecated because they made the `VALIDATE_JAVASCRIPT_PRETTIER`,
  `VALIDATE_JAVASCRIPT_STANDARD`, `VALIDATE_TYPESCRIPT_PRETTIER`, and
  `VALIDATE_TYPESCRIPT_STANDARD` configuration variables break the documented
  behavior of how
  [`VALIDATE_xxx` variables work](https://github.com/super-linter/super-linter?tab=readme-ov-file#configure-super-linter).
  Unfortunately, a transparent configuration update is not feasible without
  complicating the codebase to address all possible cases. If you only want to
  run only one between Prettier and Standard, a possible migration strategy
  could be:

  - If you're explicitly enabling linters and formatters that you want
    Super-linter to run by setting `VALIDATE_xxxx` variables to `true`:

    - If you set `JAVASCRIPT_DEFAULT_STYLE=standard`, set
      `VALIDATE_JAVASCRIPT_STANDARD=true`
    - If you set `TYPESCRIPT_DEFAULT_STYLE=standard`, set
      `VALIDATE_TYPESCRIPT_STANDARD=true`
    - If you set `JAVASCRIPT_DEFAULT_STYLE=prettier`, set
      `VALIDATE_JAVASCRIPT_PRETTIER=true`
    - If you set `TYPESCRIPT_DEFAULT_STYLE=prettier`, set
      `VALIDATE_TYPESCRIPT_PRETTIER=true`

  - If you're explicitly disabling linters and formatters that you don't want
    Super-linter to run by setting `VALIDATE_xxxx` variables to `false`:

    - If you set `JAVASCRIPT_DEFAULT_STYLE=standard`, set
      `VALIDATE_JAVASCRIPT_PRETTIER=false`
    - If you set `TYPESCRIPT_DEFAULT_STYLE=standard`, set
      `VALIDATE_TYPESCRIPT_PRETTIER=false`
    - If you set `JAVASCRIPT_DEFAULT_STYLE=prettier`, set
      `VALIDATE_JAVASCRIPT_STANDARD=false`
    - If you set `TYPESCRIPT_DEFAULT_STYLE=prettier`, set
      `VALIDATE_TYPESCRIPT_STANDARD=false`

  Finally, remove both `JAVASCRIPT_DEFAULT_STYLE` and `TYPESCRIPT_DEFAULT_STYLE`
  from your Super-linter configuration.

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
  `IGNORE_GENERATED_FILES` variables. For more information about how to ignore
  files with Jscpd, see
  [the Jscpd documentation](https://github.com/kucherenko/jscpd/tree/master/apps/jscpd).

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
  super-linter doesn't need to account for this special case anymore. If you set
  `VALIDATE_KOTLIN_ANDROID` in your configuration, change it to
  `VALIDATE_KOTLIN` and configure ktlint to lint Android files.
