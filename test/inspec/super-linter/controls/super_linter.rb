# frozen_string_literal: true
name "super-linter"
title "super-linter"

control "super-linter-container-image" do
  impact 1
  title "Validate the super-linter container image"

  describe docker_image("super-linter:latest") do
    it { should exist }
    its("repo") { should eq "python" }
    its("tag") { should eq "3.9-alpine" }
  end
end

control "super-linter-installed-packages" do
  impact 1
  title "Check that packages needed by super-linter are installed"

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
