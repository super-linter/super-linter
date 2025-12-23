# How to add support for a new tool to super-linter

If you want to propose a _Pull Request_ to add **new** language support or a new
tool, do the following.

## Update documentation

Update the `README.md` to include:

- `VALIDATE_<LANGUAGE_NAME>` and `FIX_<LANGUAGE_NAME>` variables.
- If the new tool lints the entire workspace (`GITHUB_WORKSPACE`), explain that
  the tool ignores the following variables:
  - `FILTER_REGEX_EXCLUDE`
  - `FILTER_REGEX_INCLUDE`
  - `IGNORE_GENERATED_FILES`
  - `IGNORE_GITIGNORED_FILES`
- The table of supported linters and formatters.
- If the new tool supports its own configuration file search mechanism.

## Provide test cases

1. Create the `test/linters/<LANGUAGE_NAME>` directory.
2. Provide at least one test case with a file that is supposed to pass
   validation, with the right file extension if needed:
   `test/linters/<LANGUAGE_NAME>/<name-of-tool>-good`
3. Provide at least one test case with a file that is supposed to fail
   validation, with the right file extension if needed:
   `test/linters/<LANGUAGE_NAME>/<name-of-tool>-bad`. If the tool supports fix
   mode, the test case supposed to fail validation should only contain
   violations that the fix mode can automatically fix. Avoid test cases that
   fail only because of syntax errors, when possible.
4. Update all the expected summary reports in `test/data/super-linter-summary`.
5. If the tool supports check-only mode or fix mode, add the `<LANGUAGE>` to the
   `LANGUAGES_WITH_FIX_MODE` array in `test/testUtils.sh`

## Update the test suite

Update the test suite to check for installed packages, the commands that your
new tool needs in the `PATH`, the expected version command, and for the
existence of any configuration file you added:

- `test/inspec/super-linter/controls/super_linter.rb`

## Install the tool

1. Install the latest version of the tool by pointing to specific package or
   container image versions:
   - If there are PyPi packages:
     1. Create a text file named `dependencies/python/<name-of-tool>.txt` and
        list the packages there.
     1. Add the new virtual environment `bin` directory to the `PATH` in the
        Super-linter `Dockerfile`, in the `Configure Environment` section.
        Example:

     ```dockerfile
     ENV PATH="${PATH}:/venvs/<name-of-tool>/bin"
     ```

     1. Add the new dependencies to the `pip` group in the DependaBot
        configuration file (`.github/dependabot.yaml`).

   - If there are npm packages:
     1. Update `dependencies/package.json` and `dependencies/package-lock.json`.
        by adding the new packages.
     1. Add the new npm packages to the `npm` group in the DependaBot
        configuration file (`.github/dependabot.yaml`).

   - If there are Ruby Gems, update `dependencies/Gemfile` and
     `dependencies/Gemfile.lock`
   - If there are Maven or Java packages:
     1. Create a directory named `dependencies/<name-of-tool>`.
     1. Create a `dependencies/<name-of-tool>/build.gradle` file with the
        following contents:

     ```gradle
     repositories {
       mavenLocal()
       mavenCentral()
     }

     // Hold this dependency here so we can get automated updates using DependaBot
     dependencies {
       implementation 'your:dependency-here:version'
     }

     group 'com.github.super-linter'
     version '1.0.0-SNAPSHOT'
     ```

     3. Update the `dependencies` section in
        `dependencies/<name-of-tool>/build.gradle` to install your dependencies.

     4. Add the following content to the `Dockerfile`:

     ```dockerfile
     COPY scripts/install-<name-of-tool>.sh /
     RUN --mount=type=secret,id=GITHUB_TOKEN /<name-of-tool>.sh && rm -rf /<name-of-tool>.sh
     ```

     5. Create `scripts/install-<name-of-tool>.sh`, and implement the logic to
        install your tool. You get the version of a dependency from
        `build.gradle`. Example:

     ```sh
     GOOGLE_JAVA_FORMAT_VERSION="$(
       set -euo pipefail
       awk -F "[:']" '/google-java-format/ {print $4}' "google-java-format/build.gradle"
     )"
     ```

     6. Add the new tool dependencies to the DependaBot configuration in the
        `directories` list and in the `java-gradle` group of the `gradle`
        package ecosystem.

   - If there is a container (Docker) image:
     1. Add a new build stage to get the image:

     ```dockerfile
     FROM your/image:version as <name-of-tool>
     ```

     1. Copy the necessary binaries and libraries to the relevant locations.
        Example:

     ```sh
     COPY --from=<name-of-tool> /usr/local/bin/<name-of-command> /usr/bin/
     ```

     1. Add the new dependency to the `docker` group in the DependaBot
        configuration file.

## Run the new tool

To get the commands and command options to use to run the new tool, refer to the
command-line interface documentation of the new tool. If it's not available on
the tool's site, run the new tool with the option to print help text (often:
`--help` or `-h`).

- Update the orchestration scripts to run the new tool:
  - `lib/globals/languages.sh`: add a new item to `LANGUAGES_ARRAY` array. Use
    the "name" of the language, then a `_`, and finally the name of the tool. To
    allow for future additions, use a language name and a tool name for the new
    item. Example: `PYTHON_RUFF`. In the context of this document, to avoid
    repetitions we reference this new item as `<LANGUAGE_NAME>`.

  - Define the command to invoke the new tool:
    - `lib/functions/linterCommands.sh`: add the command to invoke the tool.
      Define a new variable: `LINTER_COMMANDS_ARRAY_<LANGUAGE_NAME>`. Example:
      `LINTER_COMMANDS_ARRAY_GO_MODULES=(golangci-lint run --allow-parallel-runners)`
      - If there are arguments that you can only pass using the command line,
        and you think users might want to customize them, define a new variable
        using `<LANGUAGE_NAME>_COMMAND_ARGS` and add it to the command if the
        configuration provides it. Example:

        ```bash
        <LANGUAGE_NAME>_COMMAND_ARGS="${<LANGUAGE_NAME>_COMMAND_ARGS:-""}"
        if [ -n "${<LANGUAGE_NAME>_COMMAND_ARGS:-}" ]; then
          export <LANGUAGE_NAME>_COMMAND_ARGS
          AddOptionsToCommand "LINTER_COMMANDS_ARRAY_<LANGUAGE_NAME>" "${<LANGUAGE_NAME>_COMMAND_ARGS}"
        fi
        ```

    - `lib/globals/linterCommandsOptions.sh`: add "check only mode" and "fix
      linting and formatting issues mode" options if the tool supports it.
      Super-linter will automatically add them to the command to run the tool.
      - If the tool runs in "fix linting and formatting issues mode" by default,
        define a new variable with the options to add to the tool command to
        enable "check only mode":
        `<LANGUAGE_NAME>_CHECK_ONLY_MODE_OPTIONS=(....)`. Example:
        `PYTHON_BLACK_CHECK_ONLY_MODE_OPTIONS=(--diff --check)`

      - If the tool runs in "check only mode" by default, define a new variable
        with the options to add to the tool command to enable "fix linting and
        formatting issues mode": `<LANGUAGE_NAME>_FIX_MODE_OPTIONS=(...)`.
        Example: `ANSIBLE_FIX_MODE_OPTIONS=(--fix)`

      - If the tool needs option for both the "check only mode" and the fix
        mode, define both variables as described in the previous points.

## Configure the new tool

To check if the new tool supports a configuration file search mechanism (also
called _configuration file resolution_), refer to the configuration
documentation of the new tool.

- If the new tool doesn't support a configuration file search mechanism, update
  the command to run the new tool to set the path to the configuration file:
  1. Define a new variable in `lib/globals/linterRules.sh`:
     `<LANGUAGE_NAME>_FILE_NAME="${<LANGUAGE_NAME>_CONFIG_FILE:-"default-config-file-name.conf"}"`
     where `default-config-file-name.conf` is the name of the new configuration
     file for the new tool. Use one of the default recommended configurationfile
     names for the new tool. Example:
     `PYTHON_RUFF_FILE_NAME="${PYTHON_RUFF_CONFIG_FILE:-.ruff.toml}"`.
     Super-linter automatically initializes the path to the configuration file
     in the `<LANGUAGE_NAME>_LINTER_RULES` variable using the
     `<LANGUAGE_NAME>_FILE_NAME`. Example: `PYTHON_RUFF_LINTER_RULES`

  1. Create a new minimal configuration file in the `TEMPLATES` directory.
     Example: `TEMPLATES/default-config-file-name.conf`.

  1. Update `lib/functions/linterCommands.sh` to set the path to the
     configuration file path. Example:
     `htmlhint --config "${HTML_LINTER_RULES}"`

- If the new tool supports a configuration file search mechanism:
  1. Update the _Configure linters_ section in the `README.md` by adding the new
     tool to the list of tools that don't load configuration files from
     `LINTER_RULES_PATH`. Keep the list alphabetically ordered.

### Potential conflicts

1. If the the new tool can potentially conflict with other tools, update the
   `ValidateConflictingTools` function in `lib/functions/validation.sh` to warn
   the user if the tools that might conflict with each other are enabled at the
   same time.

### Configure the new tool for the Super-linter repository

If the default configuration of the new tool is unsuitable for the Super-linter
repository, create a new configuration file for the new tool using the default
filename:

- If the new tool supports a configuration file search mechanism, create the
  configuration file in a location where the new tool will find it.

- If the new tool doesn't support a configuration file search mechanism and you
  updated the new tool command to set the configuration file path, create the
  configuration file in the `.github/linters` directory using its default
  filename.

## Populate the file list

Provide the logic to populate the list of files or directories to examine in
`lib/functions/buildFileList.sh`:

- _File extension or name check_: If the new tool supports only specific files
  and you can select the files by looking at their extension or their name:
  1. Add an `elif` clause in the `BuildFileArrays` function to select files by
     extension. To build the new check, you can use the following variables:
     - `FILE_TYPE`: file extension
     - `BASE_FILE`: name of the file
     - `FILE_DIR_NAME`: path to the directory containing the file

     Example:

     ```bash
     elif [ "${FILE_TYPE}" == "ext" ]; then
       echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-<LANGUAGE_NAME>"
     ```

- _File contents check_: If the tool supports only specific files and you need
  to examine the file contents to check if the new tool supports them:
  1. Implement a function in `lib/functions/detectFiles.sh` to detect if the
     file is one of those that the new tool supports.
  1. Add an `elif` clause in the `BuildFileArrays` function to select files by
     extension. Example:

     ```bash
     elif DetectCloudFormationFile "${FILE}"; then
       echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-CLOUDFORMATION"
     ```

- _Entire workspace check_: If the tool supports its own file detection logic,
  and supports customizing that logic using a configuration file, do the
  following:
  1. Add the logic to handle the "entire workspace" test case for the new tool
     in the `BuildFileList` function.
  1. In the `BuildFileArrays` function:
     1. Add `FILE` to
        `"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-<LANGUAGE_NAME>"` when
        `"${FILE}" == "${GITHUB_WORKSPACE}"`
     1. Add the logic to handle test cases for the new tool that lints the
        entire workspace.
  1. Update the readme by adding the new tool to the list of tools that always
     check the entire workspace.

To avoid a performance penalties, you can combine the _file extension check_ and
the _file contents check_ approaches to run the detection logic only on certain
files. For example, you might run the _Kubernetes files detection_ logic only to
YAML files (so files with the `.yml` and `.yaml` extensions).

### Fallback

The `CheckFileType` function in `lib/functions/buildFileList.sh` attempts to get
the file type in case no other case matched by using the GNU `file` utility. If
you need this fallback, do the following:

1. Create a new function in `lib/functions/buildFileList.sh` named
   `AddTo<Language name>FileArrays` and move the logic to add files to the file
   array for the new language there, where `<Language name>` is the lowercase
   `<LANGUAGE_NAME>`. Example:

   ```bash
   AddToPythonFileArrays() {
     local FILE="${1}"

     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_BLACK"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_FLAKE8"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_ISORT"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_PYLINT"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_MYPY"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF"
     echo "${FILE}" >>"${FILE_ARRAYS_DIRECTORY_PATH}/file-array-PYTHON_RUFF_FORMAT"
   }
   ```

1. Export the new `AddTo<Language name>FileArrays` function by adding an
   `export -f` command at the bottom of the `lib/functions/buildFileList.sh`
   file. Example:

   ```bash
   export -f AddToPythonFileArrays
   ```

1. Refactor the file extension or name check to use the mew
   `AddTo<Language name>FileArrays` instead of adding files to the file arrays
   directly. Example:

   ```bash
   elif [ "${FILE_TYPE}" == "py" ]; then
     AddToPythonFileArrays "${FILE}"
   ```

1. Extend the `CheckFileType` function to match the output of the `file` command
   for your file type. Example:

   ```bash
   *"Python script"*)
     FILE_TYPE_MESSAGE="Found Python script without extension: ${FILE}"
     AddToPythonFileArrays "${FILE}"
     ;;
   ```

1. Update the `CheckFileTypeTest` test function function in
   `test/lib/buildFileListTest.sh` to cover the new case.

## Get the tool version

1. Provide the logic to populate the versions file: `scripts/linterVersions.sh`
1. Ensure that the version command emits only the version string (example:
   `v1.0.0`). You can use `awk` to select only the version string.

## Special cases

If the tool needs to take into account special cases, reach out to the
maintainers by creating a draft pull request and ask relevant questions there.
For example, you might need to provide new logic or customize the existing one
to:

- Validate the runtime environment: `lib/functions/validation.sh`.
- Get the installed version of the tool: `scripts/linterVersions.sh`
- Load configuration files: `lib/functions/linterRules.sh`
- Run the tool: `lib/functions/worker.sh`
- Compose the tool command: `lib/functions/linterCommands.sh`
- Modify the core Super-linter logic: `lib/linter.sh`
