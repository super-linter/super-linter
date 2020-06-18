# Disabling linters and Rules
If you find you need to ignore certain **errors** and **warnings**, you will need to know the *format* to disable the **Super-Linter** rules.  
Below is examples and documentation for each language and the various methods to disable.

## Table of Linters
- [Ruby](#ruby)
- [Shell](#shell)
- [Ansible](#ansible)
- [YAML](#yaml)
- [Python](#python3)
- [JSON](#json)
- [Markdown](#markdown)
- [Perl](#perl)
- [XML](#xml)
- [Coffeescript](#coffeescript)
- [Javascript Eslint](#javascript-eslint)
- [Javascript Standard](#javascript-standard)
- [Typescript Eslint](#typescript-eslint)
- [Typescript Standard](#typescript-standard)
- [Golang](#golang)
- [Dockerfile](#dockerfile)
- [Terraform](#terraform)

<!-- toc -->

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
- [ansible-lint](https://github.com/ansible/ansible-lint)

### Ansible-lint Config file
- `.github/linters/.ansible-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.ansible-lint.yml`

### Ansible-lint disable single line
```yml
- name: this would typically fire GitHasVersionRule 401 and BecomeUserWithoutBecomeRule 501
  become_user: alice  # noqa 401 501
  git: src=/path/to/git/repo dest=checkout
```
### Ansible-lint disable code block
```yml
- name: this would typically fire GitHasVersionRule 401
  git: src=/path/to/git/repo dest=checkout
  tags:
  - skip_ansible_lint
```

### Ansible-lint disable entire file
```yml
- name: this would typically fire GitHasVersionRule 401
  git: src=/path/to/git/repo dest=checkout
  tags:
  - skip_ansible_lint
```
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
- [pylint](https://www.pylint.org/)

### Pylint Config file
- `.github/linters/.python-lint`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.python-lint`

### Pylint disable single line
```python
global VAR # pylint: disable=global-statement
```

### Pylint disable code block
```python
"""pylint option block-disable"""

__revision__ = None

class Foo(object):
    """block-disable test"""

    def __init__(self):
        pass

    def meth1(self, arg):
        """this issues a message"""
        print(self)

    def meth2(self, arg):
        """and this one not"""
        # pylint: disable=unused-argument
        print(self\
              + "foo")

    def meth3(self):
        """test one line disabling"""
        # no error
        print(self.bla) # pylint: disable=no-member
        # error
        print(self.blop)
```

### Pylint disable entire file
```python
#!/bin/python3
# pylint: skip-file

var = "terrible code down here..."
```

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
- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli#readme)
- [markdownlint rule documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [markdownlint inline comment syntax](https://github.com/DavidAnson/markdownlint#configuration)

### markdownlint Config file
- `.github/linters/.markdown-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.markdownlint.yml`

### markdownlint disable single line
```markdown
## Here is some document
Here is some random data
<!-- markdownlint-disable -->
any violation you want
<!-- markdownlint-restore -->
Here is more data
```
### markdownlint disable code block
```markdown
## Here is some document
Here is some random data
<!-- markdownlint-disable -->
any violations you want
<!-- markdownlint-restore -->
Here is more data
```

### markdownlint disable entire file
- You can encapsulate the entire file with the *code block format* to disable an entire file from being parsed

--------------------------------------------------------------------------------

## Perl
- [perl](https://pkgs.alpinelinux.org/package/edge/main/x86/perl)

### Perl Config file
- There is no top level *configuration file* available at this time

### Perl disable single line
- There is currently **No** way to disable rules inline of the file(s)

### Perl disable code block
- There is currently **No** way to disable rules inline of the file(s)

### Perl disable entire file
- There is currently **No** way to disable rules inline of the file(s)

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
- [coffeelint](https://coffeelint.github.io/)

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

## Javascript eslint
- [eslint](https://eslint.org/)

### Javascript eslint Config file
- `.github/linters/.eslintrc.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.eslintrc.yml`

### Javascript eslint disable single line
```javascript
var thing = new Thing(); // eslint-disable-line no-use-before-define
thing.sayHello();

function Thing() {

     this.sayHello = function() { console.log("hello"); };

}
```

### Javascript eslint disable code block
```javascript
/*eslint-disable */

//suppress all warnings between comments
alert('foo')

/*eslint-enable */
```
### Javascript eslint disable entire file
- Place at the top of the file:
```javascript
/* eslint-disable */
```

--------------------------------------------------------------------------------

## Javascript standard
- [standard js](https://standardjs.com/)

### Javascript standard Config file
- There is no top level *configuration file* available at this time

### Javascript standard disable single line
- There is currently **No** way to disable rules inline of the file(s)

### Javascript standard disable code block
- There is currently **No** way to disable rules inline of the file(s)

### Javascript standard disable entire file
- There is currently **No** way to disable rules inline of the file(s)

--------------------------------------------------------------------------------

## Typescript eslint
- [eslint](https://eslint.org/)

### Typescript eslint Config file
- `.github/linters/.eslintrc.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.eslintrc.yml`

### Typescript eslint disable single line
```typescript
var thing = new Thing(); // eslint-disable-line no-use-before-define
thing.sayHello();

function Thing() {

     this.sayHello = function() { console.log("hello"); };

}
```

### Typescript eslint disable code block
```typescript
/*eslint-disable */

//suppress all warnings between comments
alert('foo')

/*eslint-enable */
```
### Typescript eslint disable entire file
```typescript
/* eslint-disable */
```

--------------------------------------------------------------------------------

## Typescript standard
- [standardjs](https://standardjs.com/)

### Typescript standard Config file
- There is no top level *configuration file* available at this time

### Typescript standard disable single line
- There is currently **No** way to disable rules inline of the file(s)

### Typescript standard disable code block
- There is currently **No** way to disable rules inline of the file(s)

### Typescript standard disable entire file
- There is currently **No** way to disable rules inline of the file(s)

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
