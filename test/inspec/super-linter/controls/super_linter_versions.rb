# frozen_string_literal: true

##########################################################
# Being able to run the command `linter --version` helps #
# achieve that the linter is installed, pathed, and      #
# has the libraries needed to be able to basically run   #
##########################################################

#################################################################
# Check to see that version command works on installed commands #
#################################################################
control "super-linter-version-commands" do
  impact 1
  title "Super-Linter versions commands check"
  desc "Check that commands that Super-Linter needs can run version command."

  linters = [
    "ansible-lint",
    "asl-validator",
    "black",
    "cfn-lint",
    "chktex",
    "cargo-clippy",
    "clj-kondo",
    "coffeelint",
    "dart",
    "dockerfilelint",
    "dotnet-format",
    "dotenv-linter",
    "eslint",
    "flake8",
    "golangci-lint",
    "hadolint",
    "htmlhint",
    "isort",
    "jscpd",
    "jsonlint",
    "ktlint",
    "kubeval",
    "markdownlint",
    "mypy",
    "npm-groovy-lint",
    "perl",
    "php",
    "phpcs",
    "phpstan",
    "psalm",
    "pwsh",
    "pylint",
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
    "tflint",
    "xmllint",
    "yamllint"
  ]

  linters.each do |item|
    describe command("#{item} --version") do
      its("exit_status") { should eq 0 }
    end
  end
end

###################################
# Linters with no version command #
# protolint editorconfig-checker  #
# bash-exec gherkin-lint          #
###################################

########################
# jsonlint get version #
########################
# jsonlint exits with a 1, so need to check we get a version
describe command("jsonlint --version") do
  its("exit_status") { should eq 1 }
  its('stdout') { should match (/\d+\.\d+\.\d+/) }
end

#######################
# arm-ttk get version #
#######################
describe command("grep -iE 'version' '/usr/bin/arm-ttk' | xargs") do
  its("exit_status") { should eq 0 }
end

#########################
# lintr version command #
#########################
describe command("R --slave -e \"r_ver <- R.Version()\$version.string; \
                    lintr_ver <- packageVersion('lintr'); \
                    glue::glue('lintr { lintr_ver } on { r_ver }')\"") do
  its("exit_status") { should eq 0 }
end

#######################
# lua version command #
#######################
describe command("lua -v") do
  its("exit_status") { should eq 0 }
end

#############################
# terrascan verison command #
#############################
describe command("terrascan version") do
  its("exit_status") { should eq 0 }
end

##############################
# checkstyle version command #
##############################
describe command("java -jar /usr/bin/checkstyle --version") do
  its("exit_status") { should eq 0 }
end
