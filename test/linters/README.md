# Test Cases

This directory contains test cases that super-linter uses to validate if a
particular linter is working.

These test cases focus on how super-linter invokes each linter and their exit
codes. We deliberately avoid to verify if the output of a given linter matches
the expectations because it's the responsibility of each linter to do so.

## Test case format

Each **super-linter** language should have its own directory, named after the
language they refer to.

The name of each test case denotes its nature:

- Test cases that are expected to pass validation contain the `good` string in
  their filename, or path. Example: `markdown_good_5.md`
- Test cases that are expected to fail validation contain the `bad` string in
  their filename, or path. Example: `markdown_bad_5.md`

## Notes about specific tests

In this section, we explain the peculiarities of certain test cases.

### SQL Fluff test cases

From version 0.12.0 SQLFluff requires a dialect to be set, and no longer sets a
default. This can be provided as a command-line argument, or a `.sqlfluff`
config file (either in the usualy place for SQLFluff config files, or within the
folder containg the SQL).

For SQLFluff we have added a default `.sqlfluff` config file in its test
directory.

### OpenAPI test cases

The `_bad_` tests are valid `.yml`/`.json` but invalid OpenAPI specs.
The test extensions used are `.ymlopenapi`/`.jsonopenapi` instead of
`.yml`/`.json`. This is to prevent the `YAML` and `JSON` tests from picking them
up.

### ARM test cases

`apiVersions` older than 2 years (730 days) are treated as errors by the ARM linter if there is a newer version available.

### Ansible test cases

`roles/ghe-initialize` is a valid Ansible role
