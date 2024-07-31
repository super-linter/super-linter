# How to add support for a new tool to super-linter

If you want to propose a *Pull Request* to add **new** language support or a
new tool, it should include:

- Update documentation:
  - `README.md`
- Provide test cases:

  1. Create the `test/linters/<LANGUGAGE>` directory.
  2. Provide at least one test case with a file that is supposed to pass validation: `test/linters/<LANGUAGE>/<name-of-tool>-good`
  3. Provide at least one test case with a file that is supposed to fail validation: `test/linters/<LANGUAGE>/<name-of-tool>-bad`

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

  - `lib/linter.sh`
  - `globals/languages.sh`
  - `lib/functions/linterCommands.sh`
  - Provide the logic to populate the list of files or directories to examine: `lib/buildFileList.sh`
  - If necessary, provide elaborate logic to detect if the tool should examine a file or a directory: `lib/detectFiles.sh`
  - If the tool needs to take into account special cases:

    - Provide new runtime validation checks in `lib/validation.sh`.
    - Customize the logic to get the installed version of the tool: `scripts/linterVersions.sh`
    - Provide custom logic to load configuration files: `lib/linterRules.sh`
    - Provide custom logic for test cases and to run the tool: `lib/worker.sh`
