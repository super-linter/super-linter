# How to add support for a new tool to super-linter

If you want to propose a _Pull Request_ to add **new** language support or a
new tool, it should include:

- Update documentation:
  - `README.md`
- Provide test cases:

  1. Create the `test/linters/<LANGUAGE_NAME>` directory.
  2. Provide at least one test case with a file that is supposed to pass validation,
     with the right file extension if needed: `test/linters/<LANGUAGE_NAME>/<name-of-tool>-good`
  3. Provide at least one test case with a file that is supposed to fail validation,
     with the right file extension if needed: `test/linters/<LANGUAGE_NAME>/<name-of-tool>-bad`.
     If the linter supports fix mode, the test case supposed to fail validation
     should only contain violations that the fix mode can automatically fix.
     Avoid test cases that fail only because of syntax errors, when possible.
  4. Update expected summary reports: `test/data/super-linter-summary`.
  5. If the linter supports check-only mode or fix mode, add the `<LANGUGAGE>`
     to the `LANGUAGES_WITH_FIX_MODE` array in `test/testUtils.sh`

- Update the test suite to check for installed packages, the commands that your new tool needs in the `PATH`, and the expected version command:

  - `test/inspec/super-linter/controls/super_linter.rb`

- Install the tool by pointing to specific package or container image versions:

  - If there are PyPi packages, create a text file named `dependencies/python/<name-of-tool>.txt`
    and list the packages there.
  - If there are npm packages, update `dependencies/package.json` and `dependencies/package-lock.json`.
    by adding the new packages.
  - If there are Ruby Gems, update `dependencies/Gemfile` and `dependencies/Gemfile.lock`
  - If there are Maven or Java packages:

    1. Create a directory named `dependencies/<name-of-tool>`.
    2. Create a `dependencies/<name-of-tool>/build.gradle` file with the following contents:

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

    3. Update the `dependencies` section in `dependencies/<name-of-tool>/build.gradle` to
       install your dependencies.
    4. Add the following content to the `Dockerfile`:

       ```dockerfile
       COPY scripts/install-<name-of-tool>.sh /
       RUN --mount=type=secret,id=GITHUB_TOKEN /<name-of-tool>.sh && rm -rf /<name-of-tool>.sh
       ```

    5. Create `scripts/install-<name-of-tool>.sh`, and implement the logic to install your tool.
       You get the version of a dependency from `build.gradle`. Example:

       ```sh
       GOOGLE_JAVA_FORMAT_VERSION="$(grep <"google-java-format/build.gradle" "google-java-format" | awk -F ':' '{print $3}' | tr -d "'")"
       ```

    6. Add the new to DependaBot configuration:

       ```yaml
       - package-ecosystem: "gradle"
         directory: "/dependencies/<name-of-tool>"
         schedule:
           interval: "weekly"
         open-pull-requests-limit: 10
       ```

  - If there is a container (Docker) image:

    1. Add a new build stage to get the image:

       ```dockerfile
       FROM your/image:version as <name-of-tool>
       ```

    1. Copy the necessary binaries and libraries to the relevant locations. Example:

       ```sh
       COPY --from=<name-of-tool> /usr/local/bin/<name-of-command> /usr/bin/
       ```

- Configure the new tool:

  - Provide a default configuration file only if the tool cannot function without one: `TEMPLATES/<template file for language>`
  - Provide a configuration file for the new linter only if the default configuration is unsuitable for the super-linter repository: `.github/linters/.<lintrc>`

- Update the orchestration scripts to run the new tool:

  - `lib/globals/languages.sh`: add a new item to `LANGUAGES_ARRAY` array. Use the
    "name" of the language, then a `_`, and finally the name of the linter. Example: `PYTHON_RUFF`.
    In the context of this document, to avoid repetitions we reference this new
    item as `<LANGUAGE_NAME>`.

  - Linter configuration:

    - Create a new minimal configuration file in the `TEMPLATES` directory with the same name as the
      default configuration filename. Example: `TEMPLATES/.ruff.toml`.
    - `lib/globals/linterRules.sh`:

      - If the new linter accepts a configuration files from the command line,
        define a new variable:
        `<LANGUAGE_NAME>_FILE_NAME="${<LANGUAGE_NAME>_CONFIG_FILE:-"default-config-file-name.conf"}"`
        where `default-config-file-name.conf` is the name of the new,
        minimal configuration for the linter. Example:
        `PYTHON_RUFF_FILE_NAME="${PYTHON_RUFF_CONFIG_FILE:-.ruff.toml}"`.
      - If there are arguments that you can only pass using the command line, and you think users
        might want to customize them, define a new variable using
        `<LANGUAGE_NAME>_COMMAND_ARGS` and add it to the command if the
        configuration provides it. Example:

        ```bash
        <LANGUAGE_NAME>_COMMAND_ARGS="${<LANGUAGE_NAME>_COMMAND_ARGS:-""}"
        if [ -n "${<LANGUAGE_NAME>_COMMAND_ARGS:-}" ]; then
          export <LANGUAGE_NAME>_COMMAND_ARGS
          LINTER_COMMANDS_ARRAY_<LANGUAGE_NAME>+=("${<LANGUAGE_NAME>_COMMAND_ARGS}")
        fi
        ```

  - Define the command to invoke the new linter:

    - `lib/functions/linterCommands.sh`: add the command to invoke the linter.
      Define a new variable: `LINTER_COMMANDS_ARRAY_<LANGUAGE_NAME>`.
      Example:
      `LINTER_COMMANDS_ARRAY_GO_MODULES=(golangci-lint run --allow-parallel-runners -c "${GO_LINTER_RULES}")`

      If the linter needs to load a configuration file, add the relevant options
      and paths to the command you just defined. The path to the configuration
      file is automatically initialized by Super-linter using in the
      `<LANGUAGE_NAME>_LINTER_RULES` variable, as in the `GO_LINTER_RULES`
      example above for the `GO` language.

    - `lib/globals/linterCommandsOptions.sh`: add "check only mode" and "fix
      linting and formatting issues mode" options if the linter supports it.
      Super-linter will automatically add them to the command to run the linter.

      - If the linter runs in "fix linting and formatting issues mode" by
        default, define a new variable with the options to add to the linter
        command to enable "check only mode":
        `<LANGUAGE_NAME>_CHECK_ONLY_MODE_OPTIONS=(....)`.
        Example: `PYTHON_BLACK_CHECK_ONLY_MODE_OPTIONS=(--diff --check)`

      - If the linter runs in "check only mode" by
        default, define a new variable with the options to add to the linter
        command to enable "fix linting and formatting issues mode":
        `<LANGUAGE_NAME>_FIX_MODE_OPTIONS=(...)`.
        Example: `ANSIBLE_FIX_MODE_OPTIONS=(--fix)`

  - Provide the logic to populate the list of files or directories to examine: `lib/functions/buildFileList.sh`
  - Provide the logic to populate the versions file: `scripts/linterVersions.sh`
  - If necessary, provide elaborate logic to detect if the tool should examine a file or a directory: `lib/functions/detectFiles.sh`
  - If the tool needs to take into account special cases, reach out to the
    maintainers by creating a draft pull request and ask relevant questions
    there. For example, you might need to provide new logic or customize
    the existing one to:

    - Validate the runtime environment: `lib/functions/validation.sh`.
    - Get the installed version of the linter: `scripts/linterVersions.sh`
    - Load configuration files: `lib/functions/linterRules.sh`
    - Run the linter: `lib/functions/worker.sh`
    - Compose the linter command: `lib/functions/linterCommands.sh`
    - Modify the core Super-linter logic: `lib/linter.sh`
