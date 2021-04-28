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
control "super-linter-installed-binaries" do
  impact 1
  title "Super-Linter installed binaries check"
  desc "Check that binaries that Super-Linter needs are installed."

  packages = [
    "ansible-lint",
    "arm-ttk",
    "shellcheck",
    "bash-exec",
    "clj-kondo",
    "cfn-lint",
    "coffeelint",
    "dotnet-format",
    "stylelint",
    "dart",
    "dockerfilelint",
    "hadolint",
    "editorconfig-checker",
    "dotenv-linter",
    "gherkin-lint",
    "golangci-lint",
    "npm-groovy-lint",
    "htmlhint",
    "checkstyle",
    "jscpd",
    "jsonlint",
    "eslint",
    "ktlint",
    "kubeval",
    "chktex",
    "lua",
    "markdownlint",
    "spectral",
    "perl",
    "php",
    "phpcs",
    "phpstan",
    "psalm",
    "pwsh",
    "protolint",
    "black",
    "pylint",
    "flake8",
    "isort",
    "mypy",
    "R",
    "raku",
    "rubocop",
    "rustfmt",
    "clippy",
    "shfmt",
    "snakemake",
    "snakefmt",
    "asl-validator",
    "sql-lint",
    "tekton-lint",
    "tflint",
    "terrascan",
    "terragrunt",
    "standard",
    "xmllint",
    "yamllint"
  ]

  packages.each do |item|
    describe command("command -v #{item}") do
      its("exit_status") { should eq 0 }
    end
  end
end
