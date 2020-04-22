# Disabling linters and rules
If you find you need to ignore certain errors and warnings, you will need to know the format to disable the linter rules.  
Below is examples and documentation for each language and the various methods to disable.

--------------------------------------------------------------------------------

## Ruby
- [Rubocop](https://github.com/rubocop-hq/rubocop)

### Rubocop Config file
- `.ruby-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.ruby-lint.yml`

### Rubocop disable single line
```ruby
method(argument) # rubocop:disable SomeRule, SomeOtherRule
```

### Rubocop disable code block
```ruby
# rubocop:disable
This is a long line
var="this is some other stuff"
# rubocop:enable
```

### Rubocop disable entire file
If you need to ignore an entire file, you can update the `.ruby-lint.yml`
--------------------------------------------------------------------------------

## Shell
### Shellcheck Config file
### Shellcheck disable single line
### Shellcheck disable code block
### Shellcheck disable entire file

--------------------------------------------------------------------------------

## Ansible
### Ansible-lint Config file
### Ansible-lint disable single line
### Ansible-lint disable code block
### Ansible-lint disable entire file

--------------------------------------------------------------------------------

## YAML
### Yamllint Config file
### Yamllint disable single line
### Yamllint disable code block
### Yamllint disable entire file

--------------------------------------------------------------------------------

## Python3
### Pylint Config file
### Pylint disable single line
### Pylint disable code block
### Pylint disable entire file

--------------------------------------------------------------------------------

## JSON
### JsonLint Config file
### JsonLint disable single line
### JsonLint disable code block
### JsonLint disable entire file

--------------------------------------------------------------------------------

## Markdown
- [Markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli#readme)
- [Markdownlint rules](https://awesomeopensource.com/project/DavidAnson/markdownlint)

### Markdownlint Config file
- `.markdown-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.markdownlint.yml`

### Markdownlint disable single line
```markdown
## Here is some document
Here is some random data
<!-- markdownlint-disable -->
any violation you want
<!-- markdownlint-restore -->
Here is more data
```
### Markdownlint disable code block
```markdown
## Here is some document
Here is some random data
<!-- markdownlint-disable -->
any violations you want
<!-- markdownlint-restore -->
Here is more data
```

### Markdownlint disable entire file
- You can encapsulate the entire file with the *code block format* to disable an entire file from being parsed

--------------------------------------------------------------------------------

## Perl
### Perl Config file
### Perl disable single line
### Perl disable code block
### Perl disable entire file

--------------------------------------------------------------------------------

## XML
### LibXML Config file
### LibXML disable single line
### LibXML disable code block
### LibXML disable entire file

--------------------------------------------------------------------------------

## Coffeescript
### coffeelint Config file
### coffeelint disable single line
### coffeelint disable code block
### coffeelint disable entire file

--------------------------------------------------------------------------------

## Javascript (eslint)
### Javascript eslint Config file
### Javascript eslint disable single line
### Javascript eslint disable code block
### Javascript eslint disable entire file

--------------------------------------------------------------------------------

## Javascript (standard)
### Javascript standard Config file
### Javascript standard disable single line
### Javascript standard disable code block
### Javascript standard disable entire file

--------------------------------------------------------------------------------

## Typescript (eslint)

### Typescript eslint disable single line
### Typescript eslint disable code block
### Typescript eslint disable entire file

--------------------------------------------------------------------------------

## Typescript (standard)
### Typescript standard Config file
### Typescript standard disable single line
### Typescript standard disable code block
### Typescript standard disable entire file

--------------------------------------------------------------------------------

## Golang
### golangci-lint standard Config file
### golangci-lint disable single line
### golangci-lint disable code block
### golangci-lint disable entire file

--------------------------------------------------------------------------------
## Dockerfile
### Dockerfilelint standard Config file
### Dockerfilelint disable single line
### Dockerfilelint disable code block
### Dockerfilelint disable entire file

--------------------------------------------------------------------------------

## Terraform
### tflint standard Config file
### tflint disable single line
### tflint disable code block
### tflint disable entire file

--------------------------------------------------------------------------------
