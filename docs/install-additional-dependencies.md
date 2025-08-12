# Install additional dependencies

Super-linter supports installing dependencies at runtime, on each Super-linter
run.

Super-linter supports installing the following dependencies at runtime:

- Operating system (OS) packages

## Install OS packages

To install OS packages, you do the following:

1. Create a JSON file that lists the OS packages to install in an array.
   Example:

   ```json
   ["package1", "package2", "package3"]
   ```

   The list of packages is passed as is to the OS package manager, as arguments
   to the `apk add` command. For more information about the OS package manager,
   see
   [Alpine Package Keeper](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper).

1. Save the JSON file in the `LINTERS_RULES_DIRECTORY` directory, naming it as
   `OS_PACKAGES_CONFIG_FILE_NAME`. Example, using the default values:
   `.github/linters/os-packages.json`
