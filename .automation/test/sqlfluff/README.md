# SQL Fluff Test Cases

This folder holds the test cases for **SQL**.

## Additional Docs

From version 0.12.0 SQLFluff requires a dialect to be set, and no longer sets a default. This can be provided as a command line argument, or a `.sqlfluff` config file (either in the usualy place for SQLFluff config files, or within the folder containg the SQL).

For SQLFluff we have added a default `.sqlfluff` config file in this test directory.

## Good Test Cases

The test cases denoted: `LANGUAGE_good_FILE.EXTENSION` are all valid, and should pass successfully when linted.

- **Note:** They are linted utilizing the default linter rules.

## Bad Test Cases

The test cases denoted: `LANGUAGE_bad_FILE.EXTENSION` are **NOT** valid, and should trigger errors when linted.

- **Note:** They are linted utilizing the default linter rules.
