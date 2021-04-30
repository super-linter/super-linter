# frozen_string_literal: true

##################################################
# Check to see all system packages are installed #
##################################################
control "super-linter-installed-packages" do
  impact 1
  title "Super-Linter installed packages check"
  desc "Check that packages that Super-Linter needs are installed."

  packages = [
    "bash",
    "coreutils",
    "curl",
    "gcc",
    "git-lfs",
    "git",
    "glibc",
    "gnupg",
    "go",
    "icu-libs",
    "jq",
    "krb5-libs",
    "libc-dev",
    "libcurl",
    "libffi-dev",
    "libgcc",
    "libintl",
    "libssl1.1",
    "libstdc++",
    "libxml2-dev",
    "libxml2-utils",
    "linux-headers",
    "lttng-ust-dev",
    "make",
    "musl-dev",
    "npm",
    "nodejs-current",
    "openjdk8-jre",
    "openssl-dev",
    "perl-dev",
    "perl",
    "py3-setuptools",
    "python3-dev",
    "rakudo",
    "R-dev",
    "R-doc",
    "R",
    "readline-dev",
    "ruby-bundler",
    "ruby-dev",
    "ruby-rdoc",
    "ruby",
    "rustup",
    "zef",
    "zlib-dev",
    "zlib"
  ]

  packages.each do |item|
    describe package(item) do
      it { should be_installed }
    end
  end

end

###########################################
# Check to see all binaries are installed #
###########################################
control "super-linter-installed-commands" do
  impact 1
  title "Super-Linter installed commands check"
  desc "Check that commands that Super-Linter needs are installed."

  default_version_option = "--version"
  default_version_expected_exit_status = 0
  default_expected_stdout_regex = /(.*?)/s

  linters = [
    { linter_name: "ansible-lint"},
    { linter_name: "arm-ttk", version_command: "grep -iE 'version' '/usr/bin/arm-ttk' | xargs"},
    { linter_name: "asl-validator"},
    { linter_name: "bash-exec", expected_exit_status: 1}, # expect a return code = 1 because this linter doesn't support a "get linter version" command
    { linter_name: "black"},
    { linter_name: "cfn-lint"},
    { linter_name: "checkstyle", version_command: "java -jar /usr/bin/checkstyle --version"},
    { linter_name: "chktex"},
    { linter_name: "clippy", linter_command: "clippy", version_command: "cargo-clippy --version"},
    { linter_name: "clj-kondo"},
    { linter_name: "coffeelint"},
    { linter_name: "dart"},
    { linter_name: "dockerfilelint"},
    { linter_name: "dotnet-format"},
    { linter_name: "dotenv-linter"},
    { linter_name: "editorconfig-checker", version_option: "-version"},
    { linter_name: "eslint"},
    { linter_name: "flake8"},
    { linter_name: "gherkin-lint", expected_exit_status: 1}, # expect a return code = 1 because this linter doesn't support a "get linter version" command
    { linter_name: "golangci-lint"},
    { linter_name: "hadolint"},
    { linter_name: "htmlhint"},
    { linter_name: "isort"},
    { linter_name: "jscpd"},
    { linter_name: "jsonlint", expected_exit_status: 1, expected_stdout_regex: /\d+\.\d+\.\d+/},
    { linter_name: "ktlint"},
    { linter_name: "kubeval"},
    { linter_name: "lua", version_option: "-v"},
    { linter_name: "markdownlint"},
    { linter_name: "mypy"},
    { linter_name: "npm-groovy-lint"},
    { linter_name: "perl"},
    { linter_name: "php"},
    { linter_name: "phpcs"},
    { linter_name: "phpstan"},
    { linter_name: "protolint", version_option: "version"},
    { linter_name: "psalm"},
    { linter_name: "pwsh"},
    { linter_name: "pylint"},
    { linter_name: "R", version_command: "R --slave -e \"r_ver <- R.Version()\\$version.string; \
            lintr_ver <- packageVersion('lintr'); \
            glue::glue('lintr { lintr_ver } on { r_ver }')\""},
    { linter_name: "raku"},
    { linter_name: "rubocop"},
    { linter_name: "rustfmt"},
    { linter_name: "shellcheck"},
    { linter_name: "shfmt"},
    { linter_name: "snakefmt"},
    { linter_name: "snakemake"},
    { linter_name: "spectral"},
    { linter_name: "sql-lint"},
    { linter_name: "standard"},
    { linter_name: "stylelint"},
    { linter_name: "tekton-lint"},
    { linter_name: "terragrunt"},
    { linter_name: "terrascan", version_option: "version"},
    { linter_name: "tflint"},
    { linter_name: "xmllint"},
    { linter_name: "yamllint"},
  ]

  linters.each do |linter|
    # If we didn't specify a linter command, use the linter name as a linter
    # command because the vast majority of linters have name == command
    if(linter.key?(:linter_command))
      linter_command = linter[:linter_command]
    else
      linter_command = linter[:linter_name]
    end

    describe command("command -v #{linter_command}") do
      its("exit_status") { should eq 0 }
    end

    # A few linters have a command that it's different than linter_command
    if(linter.key?(:version_command))
      version_command = linter[:version_command]
    else
      # Check if the linter needs an option that is different from the one that
      # the vast majority of linters use to get the version
      if(linter.key?(:version_option))
        version_option = linter[:version_option]
      else
        version_option = default_version_option
      end

      version_command = "#{linter_command} #{version_option}"

      if(linter.key?(:expected_exit_status))
        expected_exit_status = linter[:expected_exit_status]
      else
        expected_exit_status = default_version_expected_exit_status
      end

      if(linter.key?(:expected_stdout_regex))
        expected_stdout_regex = linter[:expected_stdout_regex]
      else
        expected_stdout_regex = default_expected_stdout_regex
      end

      ##########################################################
      # Being able to run the command `linter --version` helps #
      # achieve that the linter is installed, ini PATH, and    #
      # has the libraries needed to be able to basically run   #
      ##########################################################
      describe command(version_command) do
        its("exit_status") { should eq expected_exit_status }
        its("stdout") { should match (expected_stdout_regex) }
      end
    end
  end
end

###################################
# Linters with no version command #
# protolint editorconfig-checker  #
# bash-exec gherkin-lint          #
###################################
