# TEMPLATES

The files in this folder are template rules for the linters that will run against your code base. If you choose to copy these to the root of your local repository, they will be used at runtime. If rule files are not present locally, the templates will be used by default.

The file(s) will be parsed at run time on the local branch to load all rules needed to run the **Super-Linter** **GitHub** Action.
The **GitHub** Action will inform the user via the **Checks API** on the status and success of the process.
