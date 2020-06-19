# TEMPLATES

The files in this folder are template rules for the linters that will run against your code base. If you chose to copy these to your local repository in the directory: `.github/` they will be used at runtime. If they are not present, they will be used by default in the linter run.  

The file(s) will be parsed at run time on the local branch to load all rules needed to run the **Super-Linter** **GitHub** Action.  
The **GitHub** Action will inform the user via the **Checks API** on the status and success of the process.
