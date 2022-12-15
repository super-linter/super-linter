# OpenAPI Test Cases

This folder holds the test cases for **OpenAPI**.

## Additional Docs

The `_bad_` tests are valid `.yml`/`.json` but invalid OpenAPI specs.
The test extensions used are `.ymlopenapi`/`.jsonopenapi` instead of `.yml`/`.json`. This is to prevent the [YAML] and [JSON] tests from picking them up.

## Good Test Cases

The test cases denoted: `LANGUAGE_good_FILE.EXTENSION` are all valid, and should pass successfully when linted.

- **Note:** They are linted utilizing the default linter rules.

## Bad Test Cases

The test cases denoted: `LANGUAGE_bad_FILE.EXTENSION` are **NOT** valid, and should trigger errors when linted.

- **Note:** They are linted utilizing the default linter rules.
