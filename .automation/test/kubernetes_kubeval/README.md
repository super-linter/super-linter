# Kubeval Test Cases

This folder holds the test cases for **Kubeval**.

## Additional Docs

`kubeval_good_2.yaml` is a CRD and not part of the Kubernetes OpenAPI specification. It should be ignored by kubeval and therefore pass validation.

## Good Test Cases

The test cases denoted: `LANGUAGE_good_FILE.EXTENSION` are all valid, and should pass successfully when linted.

- **Note:** They are linted utilizing the default linter rules.

## Bad Test Cases

The test cases denoted: `LANGUAGE_bad_FILE.EXTENSION` are **NOT** valid, and should trigger errors when linted.

- **Note:** They are linted utilizing the default linter rules.
