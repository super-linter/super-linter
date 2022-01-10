# TEMPLATES

The files in this folder are template rules for the linters that will run against your codebase. If you choose to copy these to your local repository in the `.github/linters/` directory, they will be used at runtime. If rule files are not present locally, the templates will be used by default.

The file(s) will be parsed at runtime on the local branch to load all rules needed to run the **Super-Linter** **GitHub** Action.
The **GitHub** Action will inform the user via the **Checks API** on the status and success of the process.
