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
    "npm nodejs-current",
    "openjdk8-jre",
    "openssl-dev",
    "perl-dev",
    "perl",
    "php-xmlwriter",
    "php7-ctype",
    "php7-curl",
    "php7-dom",
    "php7-json",
    "php7-mbstring",
    "php7-phar",
    "php7-simplexml",
    "php7-tokenizer",
    "php7",
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

  commands = [
    "ansible-lint",
    "arm-ttk",
    "asl-validator",
    "bash-exec",
    "black",
    "cfn-lint",
    "checkstyle",
    "chktex",
    "clippy",
    "clj-kondo",
    "coffeelint",
    "dart",
    "dockerfilelint",
    "dotnet-format",
    "dotenv-linter",
    "editorconfig-checker",
    "eslint",
    "flake8",
    "gherkin-lint",
    "golangci-lint",
    "hadolint",
    "htmlhint",
    "isort",
    "jscpd",
    "jsonlint",
    "ktlint",
    "kubeval",
    "lua",
    "markdownlint",
    "mypy",
    "npm-groovy-lint",
    "perl",
    "php",
    "phpcs",
    "phpstan",
    "protolint",
    "psalm",
    "pwsh",
    "pylint",
    "R",
    "raku",
    "rubocop",
    "rustfmt",
    "shellcheck",
    "shfmt",
    "snakefmt",
    "snakemake",
    "spectral",
    "sql-lint",
    "standard",
    "stylelint",
    "tekton-lint",
    "terragrunt",
    "terrascan",
    "tflint",
    "xmllint",
    "yamllint"
  ]

  commands.each do |item|
    describe command("command -v #{item}") do
      its("exit_status") { should eq 0 }
    end
  end
end
