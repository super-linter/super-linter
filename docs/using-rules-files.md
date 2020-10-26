# Using your own rules files

If your repository contains your own rules files that live outside of a ``.github/linters/`` directory, you will have to tell Super-Linter where your rules files are located in your repository, and what their file names are.

You can tell Super-Linter where your rules files are located with the ``LINTER_RULES_PATH`` ENV VAR, and you can tell Super-Linter what their file names are by using any of the ENV VARS from the table below. 

| ENV VARS that can be used with LINTER_RULES_PATH |
| --------------------------------- |
| CSS_FILE_NAME                     |
| DOCKERFILE_HADOLINT_FILE_NAME     |
| EDITORCONFIG_FILE_NAME            |
| JAVASCRIPT_ES_CONFIG_FILE         |
| MARKDOWN_CONFIG_FILE              |
| PYTHON_PYLINT_CONFIG_FILE         |
| PYTHON_FLAKE8_CONFIG_FILE         |
| PYTHON_BLACK_CONFIG_FILE          |
| RUBY_CONFIG_FILE                  |
| SNAKEMAKE_SNAKEFMT_CONFIG_FILE    |
| TYPESCRIPT_ES_CONFIG_FILE         |
| JAVASCRIPT_ES_LINTER_RULES        |

### Here is an example

Below is an example of how to configure the ``env`` section of Super-Linter's ``linter.yml`` to lint JavaScript and CSS code using ``eslint`` and ``stylelint`` with your own ``.eslintrc.json`` and ``.stylelintrc.json`` rules files that are located in the root directory of your repository.  

``` yaml
        env:
          VALIDATE_ALL_CODEBASE: false
          DEFAULT_BRANCH: master
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

          LINTER_RULES_PATH: /
          CSS_FILE_NAME: .styelintrc.json
          JAVASCRIPT_ES_CONFIG_FILE: .eslintrc.json
          VALIDATE_CSS: true
          VALIDATE_JAVASCRIPT_ES: true
```

The above example tells Super-Linter:

a) Your rules files are located in your repository's root directory using the ``LINTER_RULES_PATH: /`` ENV VAR.

b) Your eslint and stylelint rules files are named ``.stylelintrc.json`` and ``.eslintrc.json`` using the ``CSS_FILE_NAME: .styelintrc.json`` and ``JAVASCRIPT_ES_CONFIG_FILE: .eslintrc.json`` ENV VARS.

c) To use ``stylelint`` and ``eslint`` to lint all CSS and JavaScript code using the ``VALIDATE_CSS: true`` and ``VALIDATE_JAVASCRIPT_ES: true`` ENV VARS.