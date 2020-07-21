# Test Cases

This folder holds `test cases` that are used to validate the sanity of the **Super-Linter**.
The format:

- Each **Super-Linter** language should have its own folder
  - Folder(s) containing test cases for each language supported
  - Passing test case(s) per language denoted in naming scheme
    - **FORMAT:** `LANGUAGE_(TYPE)_FILE.EXTENSION`
    - **Example:** `markdown_good_5.md`
    - **Note:** This allows the process to understand if linting of the file should pass or fail\
    - **Note:** (good=Standard linting should be successful bad=standard linting should fail )
  - Failing test case(s) per language denoted in naming scheme
    - **FORMAT:** `LANGUAGE_(TYPE)_FILE.EXTENSION`
    - **Example:** `markdown_bad_5.md`
    - **Note:** (good=Standard linting should be successful bad=standard linting should fail )
- Script to run test cases and validate the sanity of **Super-Linter**
