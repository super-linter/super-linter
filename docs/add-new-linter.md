# How to add support for a new tool to super-linter

If you want to propose a _Pull Request_ to add **new** language support or a new
tool, do the following.

## Update documentation

- `README.md`

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
4. Update expected summary reports: `test/data/super-linter-summary`.
5. If the tool supports check-only mode or fix mode, add the `<LANGUAGE>` to the
   `LANGUAGES_WITH_FIX_MODE` array in `test/testUtils.sh`

## Update the test suite

Update the test suite to check for installed packages, the commands that your
new tool needs in the `PATH`, and the expected version command:

- `test/inspec/super-linter/controls/super_linter.rb`

## Install the tool

- Install the tool by pointing to specific package or container image versions:
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

  - If there are npm packages, update `dependencies/package.json` and
    `dependencies/package-lock.json`. by adding the new packages.
  - If there are Ruby Gems, update `dependencies/Gemfile` and
    `dependencies/Gemfile.lock`
  - If there are Maven or Java packages:
    1. Create a directory named `dependencies/<name-of-tool>`.
    2. Create a `dependencies/<name-of-tool>/build.gradle` file with the
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
       `directories` list and in the `java-gradle` group of the `gradle` package
       ecosystem.

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

If the new tool doesn't support a configuration file search mechanism, update
the command to run the new tool to set the path to the configuration file:

1. Define a new variable in `lib/globals/linterRules.sh`:
   `<LANGUAGE_NAME>_FILE_NAME="${<LANGUAGE_NAME>_CONFIG_FILE:-"default-config-file-name.conf"}"`
   where `default-config-file-name.conf` is the name of the new configuration
   file for the new tool. Use one of the default recommended configurationfile
   names for the new tool. Example:
   `PYTHON_RUFF_FILE_NAME="${PYTHON_RUFF_CONFIG_FILE:-.ruff.toml}"`.
   Super-linter automatically initializes the path to the configuration file in
   the `<LANGUAGE_NAME>_LINTER_RULES` variable using the
   `<LANGUAGE_NAME>_FILE_NAME`. Example: `PYTHON_RUFF_LINTER_RULES`

1. Create a new minimal configuration file in the `TEMPLATES` directory.
   Example: `TEMPLATES/default-config-file-name.conf`.

1. Update `lib/functions/linterCommands.sh` to set the path to the configuration
   file path. Example: `htmlhint --config "${HTML_LINTER_RULES}"`

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

Provide the logic to populate the list of files or directories to examine:
`lib/functions/buildFileList.sh`

## Get the tool version

Provide the logic to populate the versions file: `scripts/linterVersions.sh`

## Detection logic

If necessary, provide elaborate logic to detect if the tool should examine a
file or a directory: `lib/functions/detectFiles.sh`

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
