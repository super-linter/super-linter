# Disabling linters and Rules

Linters can often require additional configuration to ensure they work with your codebase and your team's coding style, to avoid flagging false-positives. The **GitHub Super-Linter** has set up some default configurations for each linter which should work reasonably well with common code bases, but many of the linters can be configured to disable certain rules or configure the rules to ignore certain pieces of codes.

To run with your own configuration for a linter, copy the relevant [`TEMPLATE` configuration file for the linter you are using from this repo](https://github.com/github/super-linter/tree/master/TEMPLATES) into the `.github/linters/` folder in your own repository, and then edit it to modify, disable - or even add - rules and configuration to suit how you want your code checked.

How the changes are made differ for each linter, and also how much the **Github Super-Linter** has decided to change the linter's defaults. So, for some linters (e.g. [pylint for python](https://github.com/github/super-linter/blob/master/TEMPLATES/.python-lint)), there may be a large configuration file. For others (e.g. [stylelint for CSS](https://github.com/github/super-linter/blob/master/TEMPLATES/.stylelintrc.json)) the default configuration file may initially be nearly empty. And for some (e.g. StandardJS) it may not be possible to change configuration at all so there is no Template file.

Where a configuration file exists in your repo, it will be used in preference to the default one in the **GitHub Super-Linter** `TEMPLATES` directory (not in addition to it), and where one doesn't exist the `TEMPLATES` version will be used. So you should copy the complete configuration file you require to change from the `TEMPLATES` directory and not just the lines of config you want to change.

It is possible to have custom configurations for some linters, and continue to use the default from `TEMPLATES` directory for others, so if you use `Python` and `JavaScript` and only need to tweak the `Python` rules, then you only need to have a custom configuration for _pylint_ and continue to use the default `TEMPLATE` from the main repo for _ESLint_, for example.

For some linters it is also possible to override rules on a case by case level with directives in your code. Where this is possible we try to note how to do this in the specific linter sections below, but the official linter documentation will likely give more detail on this.

**NOTE: Please view each linters source and webpage from the [Supported Linters README](https://github.com/github/super-linter#supported-linters) to see additional information on how to configure, disable, or tune additional rules.**
