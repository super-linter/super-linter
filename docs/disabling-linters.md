# Disabling linters and Rules

Linters can often require additional configuration to ensure they work with your codebase and your team's coding style, to avoid flagging false-positives. The **GitHub Super-Linter** has set up some default configurations for each linter which should work reasonably well with common code bases, but many of the linters can be configured to disable certain rules or configure the rules to ignore certain pieces of codes.

To run with your own configuration for a linter, copy the relevant [`TEMPLATE` configuration file for the linter you are using from this repo](https://github.com/github/super-linter/tree/master/TEMPLATES) into the `.github/linters` folder in your own repository, and then edit it to modify, disable - or even add - rules and configuration to suit how you want your code checked.

How the changes are made differ for each linter, and also how much the **Github Super-Linter** has decided to change the linter's defaults. So, for some linters (e.g. [pylint for python](https://github.com/github/super-linter/blob/master/TEMPLATES/.python-lint)), there may be a large configuration file. For others (e.g. [stylelint for CSS](https://github.com/github/super-linter/blob/master/TEMPLATES/.stylelintrc.json)) the default configuration file may initially be nearly empty. And for some (e.g. StandardJS) it may not be possible to change configuration at all so there is no Template file.

Where a configuration file exists in your repo, it will be used in preference to the default one in the **GitHub Super-Linter** `TEMPLATES` directory (not in addition to it), and where one doesn't exist the `TEMPLATES` version will be used. So you should copy the complete configuration file you require to change from the `TEMPLATES` directory and not just the lines of config you want to change.

It is possible to have custom configurations for some linters, and continue to use the default from `TEMPLATES` directory for others, so if you use `Python` and `JavaScript` and only need to tweak the `Python` rules, then you only need to have a custom configuration for _pylint_ and continue to use the default `TEMPLATE` from the main repo for _ESLint_, for example.

For some linters it is also possible to override rules on a case by case level with directives in your code. Where this is possible we try to note how to do this in the specific linter sections below, but the official linter documentation will likely give more detail on this.

## Table of Linters

- [Disabling linters and Rules](#disabling-linters-and-rules)
  - [Table of Linters](#table-of-linters)
  - [Ansible](#ansible)
  - [AWS CloudFormation templates](#aws-cloudformation-templates)
  - [Clojure](#clojure)
  - [Coffeescript](#coffeescript)
  - [CSS](#css)
  - [Dart](#dart)
  - [Dockerfile](#dockerfile)
  - [Dockerfile](#dockerfile-hadolint)
  - [EDITORCONFIG-CHECKER](#editorconfig-checker)
  - [ENV](#env)
  - [Golang](#golang)
  - [Groovy](#groovy)
  - [HTML](#html)
  - [Java](#java)
  - [JavaScript eslint](#javascript-eslint)
  - [JavaScript standard](#javascript-standard)
  - [JSON](#json)
  - [Kubeval](#kubeval)
  - [Kotlin](#kotlin)
  - [LaTeX](#latex)
  - [Lua](#lua)
  - [Markdown](#markdown)
  - [OpenAPI](#openapi)
  - [Perl](#perl)
  - [PHP](#php)
  - [Protocol Buffers](#protocol-buffers)
  - [Python3 black](#python3-black)
  - [Python3 flake8](#python3-flake8)
  - [Python3 pylint](#python3-pylint)
  - [R](#r)
  - [Raku](#raku)
  - [Ruby](#ruby)
  - [Shell](#shell)
  - [Snakemake](#snakemake)
  - [SQL](#sql)
  - [Tekton](#tekton)
  - [Terraform](#terraform)
  - [Typescript eslint](#typescript-eslint)
  - [Typescript standard](#typescript-standard)
  - [XML](#xml)
  - [YAML](#yaml)

<!-- toc -->

---

## Ansible

- [ansible-lint](https://github.com/ansible/ansible-lint)

### Ansible-lint Config file

- `.github/linters/.ansible-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.ansible-lint.yml`

### Ansible-lint disable single line

```yml
- name: this would typically fire GitHasVersionRule 401 and BecomeUserWithoutBecomeRule 501
  become_user: alice # noqa 401 501
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

---

## AWS CloudFormation templates

- [cfn-lint](https://github.com/aws-cloudformation/cfn-python-lint/)

### cfn-lint Config file

- `.github/linters/.cfnlintrc.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.cfnlintrc.yml`

### cfn-lint disable single line

- There is currently **No** way to disable rules inline of the file(s)

### cfn-lint disable code block

You can disable both [template](https://github.com/aws-cloudformation/cfn-python-lint/#template-based-metadata) or [resource](https://github.com/aws-cloudformation/cfn-python-lint/#resource-based-metadata) via [metadata](https://github.com/aws-cloudformation/cfn-python-lint/#metadata):

```yaml
Resources:
  myInstance:
    Type: AWS::EC2::Instance
    Metadata:
      cfn-lint:
        config:
          ignore_checks:
            - E3030
    Properties:
      InstanceType: nt.x4superlarge
      ImageId: ami-abc1234
```

### cfn-lint disable entire file

If you need to ignore an entire file, you can update the `.github/linters/.cfnlintrc.yml` to ignore certain files and locations

```yaml
ignore_templates:
  - codebuild.yaml
```

---

## Clojure

- [clj-kondo](https://github.com/borkdude/clj-kondo)
- Since clj-kondo approaches static analysis in a very Clojure way, it is advised to read the [configuration docs](https://github.com/borkdude/clj-kondo/blob/master/doc/config.md)

### clj-kondo standard Config file

- `.github/linters/.clj-kondo/config.edn`

### clj-kondo disable single line

- There is currently **No** way to disable rules in a single line

### clj-kondo disable code block

- There is currently **No** way to disable rules in a code block

### clj-kondo disable entire file

```clojure
{:output {:exclude-files ["path/to/file"]}}
```

---

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

- You can encapsulate the entire file with the _code block format_ to disable an entire file from being parsed

---

## CSS

- [stylelint](https://stylelint.io/)

### stylelint standard Config file

- `.github/linters/.stylelintrc.json`

### stylelint disable single line

```css
#id {
  /* stylelint-disable-next-line declaration-no-important */
  color: pink !important;
}
```

### stylelint disable code block

```css
/* stylelint-disable */
a {
}
/* stylelint-enable */
```

### stylelint disable entire file

- You can disable entire files with the `ignoreFiles` property in `.stylelintrc.json`

```json
{
  "ignoreFiles": [
    "styles/ignored/wildcards/*.css",
    "styles/ignored/specific-file.css"
  ]
}
```

---

## Dart

- [dartanalyzer](https://dart.dev/tools/dartanalyzer)

### dartanalyzer standard Config file

- `.github/linters/analysis_options.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/analysis_options.yml`

### dartanalyzer disable single line

```dart
int x = ''; // ignore: invalid_assignment
```

### dartanalyzer disable code block

- You can make [rule exceptions](https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis) for the entire file.

```dart
// ignore_for_file: unused_import, unused_local_variable
```

### dartanalyzer disable entire file

- You can disable entire files with the `analyzer.exclude` property in `analysis_options.yml`

```dart
analyzer:
  exclude:
    - file
```

---

## Dockerfile

- [dockerfilelint](https://github.com/replicatedhq/dockerfilelint.git)

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

---

## Dockerfile-Hadolint

- [hadolint](https://github.com/hadolint/hadolint)

### Hadolint standard Config file

- `.github/linters/.hadolint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.hadolint.yml`

### Hadolint disable single line

```dockerfile
# hadolint ignore=DL3006
FROM ubuntu

# hadolint ignore=DL3003,SC1035
RUN cd /tmp && echo "hello!"
```

### Hadolint disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Hadolint disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## EDITORCONFIG-CHECKER
- [editorconfig-checker](https://github.com/editorconfig-checker/editorconfig-checker)

### editorconfig-checker Config file
- `.github/linters/.ecrc`
- This linter will also use the [`.editorconfig`](https://editorconfig.org/) of your project

### editorconfig-checker disable single line

```js
<LINE> // editorconfig-checker-disable-line
```

### editorconfig-checker disable code block

- There is currently **No** way to disable rules inline of the file(s)

### editorconfig-checker disable entire file

```js
// editorconfig-checker-disable-file
```

- You can disable entire files with the `Exclude` property in `.ecrc`

```json
{
  "Exclude": ["path/to/file", "^regular\\/expression\\.ext$"]
}
```

---

## ENV

- [dotenv-linter](https://github.com/dotenv-linter/dotenv-linter)

### dotenv-linter Config file

- There is no top level _configuration file_ available at this time

### dotenv-linter disable single line

```env
# Comment line will be ignored
```

### dotenv-linter disable code block

- There is currently **No** way to disable rules inline of the file(s)

### dotenv-linter disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

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

---

## Groovy
- [npm-groovy-lint](https://github.com/nvuillam/npm-groovy-lint)

### groovy-lint standard Config file
- `.github/linters/.groovylintrc.json`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.groovylintrc.json`

### groovy-lint disable single line
```groovy
def variable = 1; // groovylint-disable-line

// groovylint-disable-next-line
def variable = 1;

/* groovylint-disable-next-line */
def variable = 1;

def variable = 1; /* groovylint-disable-line */
```

### groovy-lint disable code block
```groovy
/* groovylint-disable */

def variable = 1;

/* groovylint-enable */
```

### groovy-lint disable entire file
- At the top line of the file add the line:
```groovy
/* groovylint-disable */
```

---

## HTML

- [htmlhint](https://htmlhint.com/)

### htmlhint standard Config file

- `.github/linters/.htmlhintrc`

### htmlhint disable single line

- There is currently **No** way to disable rules in a single line

### htmlhint disable code block

- There is currently **No** way to disable rules in a code block

### htmlhint disable entire file

- There is currently **No** way to disable rules in an entire file

---

## Java

- [checkstyle](https://github.com/checkstyle/checkstyle)

### Java Config file

- `.github/linters/sun_checks.xml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/sun_checks.xml`

### Java disable single line
- There is currently **No** way to disable rules inline of the file(s)

### Java disable code block
- There is currently **No** way to disable rules inline of the file(s)

### Java disable entire file
- There is currently **No** way to disable rules inline of the file(s)

---

## JavaScript eslint

- [eslint](https://eslint.org/)

### JavaScript eslint Config file

- `.github/linters/.eslintrc.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.eslintrc.yml`

### JavaScript eslint disable single line

```javascript
var thing = new Thing(); // eslint-disable-line no-use-before-define
thing.sayHello();

function Thing() {
  this.sayHello = function () {
    console.log("hello");
  };
}
```

### JavaScript eslint disable code block

```javascript
/*eslint-disable */

//suppress all warnings between comments
alert("foo");

/*eslint-enable */
```

### JavaScript eslint disable entire file

- Place at the top of the file:

```javascript
/* eslint-disable */
```

---

## JavaScript standard

- [standard js](https://standardjs.com/)

### JavaScript standard Config file

- There is no top level _configuration file_ available at this time

### JavaScript standard disable single line

- There is currently **No** way to disable rules inline of the file(s)

### JavaScript standard disable code block

- There is currently **No** way to disable rules inline of the file(s)

### JavaScript standard disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## JSON

- [jsonlint](https://github.com/zaach/jsonlint)

### JsonLint Config file

- There is no top level _configuration file_ available at this time

### JsonLint disable single line

- There is currently **No** way to disable rules inline of the file(s)

### JsonLint disable code block

- There is currently **No** way to disable rules inline of the file(s)

### JsonLint disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## Kotlin

- [ktlint](https://github.com/pinterest/ktlint)

### ktlint Config file

- There is no top level _configuration file_ available at this time

### ktlint disable single line

```kotlin
import package.* // ktlint-disable no-wildcard-imports
```

### ktlint disable code block

```kotlin
/* ktlint-disable no-wildcard-imports */
import package.a.*
import package.b.*
/* ktlint-enable no-wildcard-imports */
```

### ktlint disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## Kubernetes

- [kubeval](https://github.com/instrumenta/kubeval)

### Kubeval

- There is no top level _configuration file_ available at this time

---

## LaTeX

- [ChkTex](https://www.nongnu.org/chktex/)

### ChkTex Config file

- `.github/linters/.chktexrc`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.chktexrc`
- See [ChkTex](https://ctan.kako-dev.de/systems/doc/chktex/ChkTeX.pdf) docs for additional
  behaviors

### ChkTex disable single line

Disable warnings on each line:

```latex
$[0,\infty)$  % chktex 8 chktex 9
```
### ChkTex disable code block

Use the `ignore`-environment to ignore all warnings within it.
Make sure that "ignore" is contained in your chektexrc files "VerbEnvir" setting.

```latex
\newenvironment{ignore}{}{}

\begin{ignore}
$[0,\infty)$
\end{ignore}
```

### ChkTex disable entire file

Disable warning for the rest of the file:

```latex
% chktex-file 18
```

---

## Lua

- [luarocks](https://github.com/luarocks/luacheck)

### luacheck standard Config file
- `.github/linters/.luacheckrc`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.luacheckrc`
- See [luacheck](https://luacheck.readthedocs.io/en/stable/config.html) docs for additional
  behaviors

### luacheck disable single line
```lua
-- luacheck: globals g1 g2, ignore foo
local foo = g1(g2) -- No warnings emitted.
```

### luacheck disable code block
```lua
-- The following unused function is not reported.
local function f() -- luacheck: ignore
   -- luacheck: globals g3
   g3() -- No warning.
end
```

### luacheck include/exclude files (via .luacheckrc)
```lua
include_files = {"src", "spec/*.lua", "scripts/*.lua", "*.rockspec", "*.luacheckrc"}
exclude_files = {"src/luacheck/vendor"}
```

### luacheck push/pop
```lua
-- luacheck: push ignore foo
foo() -- No warning.
-- luacheck: pop
foo() -- Warning is emitted.
```

---

## Markdown

- [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli#readme)
- [markdownlint rule documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [markdownlint inline comment syntax](https://github.com/DavidAnson/markdownlint#configuration)

### markdownlint Config file

- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.markdown-lint.yml`

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

- You can encapsulate the entire file with the _code block format_ to disable an entire file from being parsed

---

## OpenAPI

- [spectral](https://github.com/stoplightio/spectral)

### OpenAPI Config file

- `.github/linters/.openapirc.yml`
- You can add, extend, and disable rules
- Documentation at [Spectral Custom Rulesets](https://stoplight.io/p/docs/gh/stoplightio/spectral/docs/guides/4-custom-rulesets.md)
- File should be located at: `.github/linters/.openapirc.yml`

### OpenAPI disable single line

- There is currently **No** way to disable rules inline of the file(s)

### OpenAPI disable code block

- There is currently **No** way to disable rules inline of the file(s)

### OpenAPI disable entire file

- There is currently **No** way to disable rules inline of the file(s)
- However, you can make [rule exceptions](https://stoplight.io/p/docs/gh/stoplightio/spectral/docs/guides/6-exceptions.md?srn=gh/stoplightio/spectral/docs/guides/6-exceptions.md) in the config for individual file(s).

---

## Perl

- `.github/linters/.perlcriticrc`

### Perl Config file

- There is no top level _configuration file_ available at this time

### Perl disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Perl disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Perl disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## PHP

- [PHP](https://www.php.net/)

### PHP Config file

- There is no top level _configuration file_ available at this time

### PHP disable single line

- There is currently **No** way to disable rules inline of the file(s)

### PHP disable code block

- There is currently **No** way to disable rules inline of the file(s)

### PHP disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## Protocol Buffers

- [protolint](https://github.com/yoheimuta/protolint)

### protolint Config file

- `.github/linters/.protolintrc.yml`
- You can add, extend, and disable rules
- Documentation at [Rules](https://github.com/yoheimuta/protolint#rules) and [Configuring](https://github.com/yoheimuta/protolint#configuring)

### protolint disable single line

```protobuf
enum Foo {
  // protolint:disable:next ENUM_FIELD_NAMES_UPPER_SNAKE_CASE
  firstValue = 0;
  second_value = 1;  // protolint:disable:this ENUM_FIELD_NAMES_UPPER_SNAKE_CASE
  THIRD_VALUE = 2;
}
```

### protolint disable code block

```protobuf
// protolint:disable ENUM_FIELD_NAMES_UPPER_SNAKE_CASE
enum Foo {
  firstValue = 0;
  second_value = 1;
  THIRD_VALUE = 2;
}
// protolint:enable ENUM_FIELD_NAMES_UPPER_SNAKE_CASE
```

### protolint disable entire file

- You can disable entire files with the `lint.files.exclude` property in `.protolintrc.yml`

```yaml
# Lint directives.
lint:
  # Linter files to walk.
  files:
    # The specific files to exclude.
    exclude:
      - path/to/file
```

---

## Python3 pylint

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
        print(self.baz) # pylint: disable=no-member
        # error
        print(self.baz)
```

### Pylint disable entire file

```python
#!/bin/python3
# pylint: skip-file

var = "terrible code down here..."
```

---

## Python3 flake8

- [flake8](https://flake8.pycqa.org/en/latest/)

### flake8 Config file

- `.github/linters/.flake8`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.flake8`

### flake8 disable single line

```python
example = lambda: 'example'  # noqa: E731
```

### flake8 disable entire file

```python
#!/bin/python3
# flake8: noqa

var = "terrible code down here..."
```

---

## Python3 black

- `https://black.readthedocs.io/en/stable/installation_and_usage.html#`

### Black Config file

- `.github/linters/.python-black`
  - You can pass multiple rules and overwrite default rules
- File should be located at: .github/linters/.python-black
- [Python Black compatible configurations](https://github.com/psf/black/blob/master/docs/compatible_configs.md)

### Black disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Black disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Black disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## R

- [lintr](https://github.com/jimhester/lintr)

### lintr Config file

- `.github/linters/.lintr`
- You can pass multiple rules and overwrite default rules
- You can use either one `.lintr` file in the root of your repository and/or additonal `.lintr` files in subdirectories. When linting a file lintr will look for config files from the file location upwards and will use the closest one.
- Absolute paths for exclusions will not work due to the code being linted within the docker environment. Use paths relative to the `.lintr` file in which youare adding them.  
- **Note:** The defaults adhere to the [tidyverse styleguide](https://style.tidyverse.org/)

### lintr disable single line

```r
1++1/3+2 # nolint
```

### lintr disable code block

```r
 # nolint start
 hotGarbage = 1++1/3+2
    #a very long comment line
 # nolint end
```
### lintr disable entire file

Add files to exclude into the config file as  a list of filenames to exclude from linting. You can use a named item to exclude only certain lines from a file. Use paths relative to the location of the `.lintr` file.

```r
exclusions: list("inst/doc/creating_linters.R" = 1, "inst/example/bad.R", "tests/testthat/exclusions-test")
```
---
## Raku

- [raku](https://raku.org)

### Raku Config file

- There is no top level _configuration file_ available at this time

### Raku disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Raku disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Raku disable entire file

- There is currently **No** way to disable rules inline of the file(s)


---

## Ruby

- [RuboCop](https://github.com/rubocop-hq/rubocop)

### RuboCop Config file

- `.github/linters/.ruby-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.ruby-lint.yml`
- **Note:** We use the Default **GitHub** Rule set from [RuboCop-GitHub](https://github.com/github/rubocop-github)

### RuboCop disable single line

```ruby
method(argument) # rubocop:disable SomeRule, SomeOtherRule
```

### RuboCop disable code block

```ruby
# rubocop:disable
This is a long line
var="this is some other stuff"
# rubocop:enable
```

### RuboCop disable entire file

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
    - "db/**/*"
    - "config/**/*"
    - "script/**/*"
    - "bin/{rails,rake}"
    - !ruby/regexp /old_and_unused\.rb$/
```

---

## Shell

- [Shellcheck](https://github.com/koalaman/shellcheck)
- [shfmt](https://github.com/mvdan/sh)

### Shellcheck Config file

- There is no top level _configuration file_ available at this time

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

### shfmt Config file

shfmt [supports EditorConfig files for configuration](https://github.com/mvdan/sh#shfmt), if available.

---

## Snakemake

- [snakemake --lint](https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html#best-practices)
- [snakefmt](https://github.com/snakemake/snakefmt/)

### snakemake's configuration

- Check the repository's README

### snakefmt configuration

- Check the repository's README

---

## SQL

- [SQL](https://www.npmjs.com/package/sql-lint)

### SQL Config file

- `.github/linters/.sql-config.json`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.sql-json`

### SQL disable single line

- There is currently **No** way to disable rules inline of the file(s)

### SQL disable code block

- There is currently **No** way to disable rules inline of the file(s)

### SQL disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## Tekton

- [Tekton](https://github.com/IBM/tekton-lint)

### Tekton Config file

- There is currently **No** Tekton format config rules file

### Tekton disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Tekton disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Tekton disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

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

---

## Terragrunt

- [terragrunt](https://github.com/gruntwork-io/terragrunt)

### Terragrunt standard Config file

- There is currently **No** Terragrunt format config rules file

### Terragrunt disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Terragrunt disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Terragrunt disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

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
  this.sayHello = function () {
    console.log("hello");
  };
}
```

### Typescript eslint disable code block

```typescript
/*eslint-disable */

//suppress all warnings between comments
alert("foo");

/*eslint-enable */
```

### Typescript eslint disable entire file

```typescript
/* eslint-disable */
```

---

## Typescript standard

- [standardjs](https://standardjs.com/)

### Typescript standard Config file

- There is no top level _configuration file_ available at this time

### Typescript standard disable single line

- There is currently **No** way to disable rules inline of the file(s)

### Typescript standard disable code block

- There is currently **No** way to disable rules inline of the file(s)

### Typescript standard disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## XML

- [XML](http://xmlsoft.org/)

### LibXML Config file

- There is no top level _configuration file_ available at this time

### LibXML disable single line

- There is currently **No** way to disable rules inline of the file(s)

### LibXML disable code block

- There is currently **No** way to disable rules inline of the file(s)

### LibXML disable entire file

- There is currently **No** way to disable rules inline of the file(s)

---

## YAML

- [YamlLint](https://github.com/adrienverge/yamllint)

### Yamllint Config file

- `.github/linters/.yaml-lint.yml`
- You can pass multiple rules and overwrite default rules
- File should be located at: `.github/linters/.yaml-lint.yml`

### Yamllint disable single line

```yml
This line is waaaaaaaaaay too long # yamllint disable-line
```

### Yamllint disable code block

```yml
# yamllint disable rule:colons
- Key: value
  dolor: sit,
  foo: bar
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
