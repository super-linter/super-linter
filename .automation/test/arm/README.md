# ARM Test Cases

This folder holds the test cases for **Azure Resource Manager (ARM)**.

## Additional Docs

Note: apiVersions older than 2 years (730 days) are treated as errors by the ARM linter if there is a newer version available.

## Good Test Cases

The test cases denoted: `LANGUAGE_good_FILE.EXTENSION` are all valid, and should pass successfully when linted.

- **Note:** They are linted utilizing the default linter rules.

## Bad Test Cases

The test cases denoted: `LANGUAGE_bad_FILE.EXTENSION` are **NOT** valid, and should trigger errors when linted.

- **Note:** They are linted utilizing the default linter rules.
