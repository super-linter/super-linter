# Using your own rules files

If your repository contains your own rules files that live outside of a ``.github/linters/`` directory, you will have to tell Super-Linter where your rules files are located in your repository, and what their filenames are.

You can tell Super-Linter where your rules files are located with the ``LINTER_RULES_PATH`` ENV VAR (this is relative to the ``DEFAULT_WORKSPACE``), and you can tell Super-Linter what their filenames are by using any of the filename ENV VARS listed in the [Environment variables table](/README.md#Environment-variables). You can determine which ENV VARS are filename ENV VARS by looking in the notes column for the term "filename."

## Here is an example

Below is an example of how to configure the ``env`` section of Super-Linter's ``linter.yml`` to lint JavaScript and CSS code using ``eslint`` and ``stylelint`` with your own ``.eslintrc.json`` and ``.stylelintrc.json`` rules files that are located in the root directory of your repository.

``` yaml
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: main
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

          LINTER_RULES_PATH: /
          CSS_FILE_NAME: .stylelintrc.json
          JAVASCRIPT_ES_CONFIG_FILE: .eslintrc.json
          VALIDATE_CSS: true
          VALIDATE_JAVASCRIPT_ES: true
```

The above example tells Super-Linter:

a) Your rules files are located in your repository's root directory using the ``LINTER_RULES_PATH: /`` ENV VAR.

b) Your ESLint and stylelint rules files are named ``.stylelintrc.json`` and ``.eslintrc.json`` using the ``CSS_FILE_NAME: .styelintrc.json`` and ``JAVASCRIPT_ES_CONFIG_FILE: .eslintrc.json`` ENV VARS.

c) To use ``stylelint`` and ``eslint`` to lint all CSS and JavaScript code using the ``VALIDATE_CSS: true`` and ``VALIDATE_JAVASCRIPT_ES: true`` ENV VARS.
