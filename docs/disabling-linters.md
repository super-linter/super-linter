# Disabling linters and rules
If you find you need to ignore certain errors and warnings, you will need to know the format to disable the linter rules.  
Below is examples and documentation for each language and the various methods to disable.

--------------------------------------------------------------------------------

## Ruby
- [Rubocop](https://github.com/rubocop-hq/rubocop)

### Rubocop Config file
- `.github/linters/.ruby-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.ruby-lint.yml`
- **Note:** We use the Default **GitHub** Rule set from [Rubocop-GitHub](https://github.com/github/rubocop-github)

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
If you need to ignore an entire file, you can update the `.github/linters/.ruby-lint.yml` to ignore certain files and locations

```yml
inherit_from:
  - .rubocop_todo.yml
  - .rubocop_app_overrides.yml

inherit_mode:
  merge:
    - Exclude

Rails:
  Enabled: true

AllCops:
  TargetRubyVersion: 2.5.1
  EnabledByDefault: true
  Exclude:
    - 'db/**/*'
    - 'config/**/*'
    - 'script/**/*'
    - 'bin/{rails,rake}'
    - !ruby/regexp /old_and_unused\.rb$/
```

--------------------------------------------------------------------------------

## Shell
- [Shellcheck](https://github.com/koalaman/shellcheck)

### Shellcheck Config file
- There is no top level *configuration file* available at this time

### Shellcheck disable single line
```bash
echo "Terrible stuff" # shellcheck disable=SC2059,SC2086
```

### Shellcheck disable code block
```bash
# shellcheck disable=SC2059,SC2086
echo "some hot garbage"
echo "More garbage code"
```

### Shellcheck disable entire file
- **Note:** The disable must be on the second line of the code right after the shebang
```bash
#!/bin/sh
# shellcheck disable=SC2059,SC1084

echo "stuff"
moreThings()
```

--------------------------------------------------------------------------------

## Ansible
### Ansible-lint Config file
### Ansible-lint disable single line
### Ansible-lint disable code block
### Ansible-lint disable entire file

--------------------------------------------------------------------------------

## YAML
- [YamlLint](https://github.com/adrienverge/yamllint)

### Yamllint Config file
- `.github/linters/.yaml-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.yaml-lint.yml`

### Yamllint disable single line
```yml
This line is waaaaaaaaaay too long  # yamllint disable-line
```

### Yamllint disable code block
```yml
# yamllint disable rule:colons
- Lorem       : ipsum
  dolor       : sit amet,
  consectetur : adipiscing elit
# yamllint enable
```

### Yamllint disable entire file
If you need to ignore an entire file, you can update the `.github/linters/.yaml-lint.yml` to ignore certain files and locations
```yml
# For all rules
ignore: |
  *.dont-lint-me.yaml
  /bin/
  !/bin/*.lint-me-anyway.yaml

rules:
  key-duplicates:
    ignore: |
      generated
      *.template.yaml
  trailing-spaces:
    ignore: |
      *.ignore-trailing-spaces.yaml
      /ascii-art/*
```

--------------------------------------------------------------------------------

## Python3
### Pylint Config file
### Pylint disable single line
### Pylint disable code block
### Pylint disable entire file

--------------------------------------------------------------------------------

## JSON
- [jsonlint](https://github.com/zaach/jsonlint)

### JsonLint Config file
- There is no top level *configuration file* available at this time

### JsonLint disable single line
- There is currently **No** way to disable rules inline of the file(s)

### JsonLint disable code block
- There is currently **No** way to disable rules inline of the file(s)

### JsonLint disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------

## Markdown
- [Markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli#readme)
- [Markdownlint rules](https://awesomeopensource.com/project/DavidAnson/markdownlint)

### Markdownlint Config file
- `.github/linters/.markdown-lint.yml`
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
- [XML](http://xmlsoft.org/)

### LibXML Config file
- There is no top level *configuration file* available at this time

### LibXML disable single line
- There is currently **No** way to disable rules inline of the file(s)

### LibXML disable code block
- There is currently **No** way to disable rules inline of the file(s)

### LibXML disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------

## Coffeescript
- [coffeelint](http://www.coffeelint.org/)

### coffeelint Config file
- `.github/linters/.coffee-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.coffee.yml`

### coffeelint disable single line
```Coffeescript
# coffeelint: disable=max_line_length
foo = "some/huge/line/string/with/embed/#{values}.that/surpasses/the/max/column/width"
# coffeelint: enable=max_line_length
```

### coffeelint disable code block
```Coffeescript
# coffeelint: disable
foo = "some/huge/line/string/with/embed/#{values}.that/surpasses/the/max/column/width"
bar = "some/huge/line/string/with/embed/#{values}.that/surpasses/the/max/column/width"
baz = "some/huge/line/string/with/embed/#{values}.that/surpasses/the/max/column/width"
taz = "some/huge/line/string/with/embed/#{values}.that/surpasses/the/max/column/width"
# coffeelint: enable
```

### coffeelint disable entire file
- You can encapsulate the entire file with the *code block format* to disable an entire file from being parsed

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
- [golangci-lint](https://github.com/golangci/golangci-lint)

### golangci-lint standard Config file
- `.github/linters/.golangci.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.golangci.yml`

### golangci-lint disable single line
- There is currently **No** way to disable rules inline of the file(s)

### golangci-lint disable code block
- There is currently **No** way to disable rules inline of the file(s)

### golangci-lint disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------

## Dockerfile
-[dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git)

### Dockerfilelint standard Config file
- `.github/linters/.dockerfilelintrc`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.dockerfilelintrc`

### Dockerfilelint disable single line
- There is currently **No** way to disable rules inline of the file(s)

### Dockerfilelint disable code block
- There is currently **No** way to disable rules inline of the file(s)

### Dockerfilelint disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------

## Terraform
- [tflint](https://github.com/terraform-linters/tflint)

### tflint standard Config file
- `.github/linters/.tflint.hcl`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.tflint.hcl`

### tflint disable single line
- There is currently **No** way to disable rules inline of the file(s)

### tflint disable code block
- There is currently **No** way to disable rules inline of the file(s)

### tflint disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------
