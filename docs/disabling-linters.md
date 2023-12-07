# Disabling linters and rules

Linters can often require additional configuration to ensure they work with your
codebase and your coding style to avoid flagging false-positives.

The **Super-Linter** has some default configurations for each linter that should
work reasonably well with common code bases, but many of the linters can be
configured to disable certain rules or configure the rules to ignore certain
pieces of codes.

To run with your own configuration for a linter, copy the relevant
[`TEMPLATE` configuration file for the linter you are using from this repository](https://github.com/super-linter/super-linter/tree/main/TEMPLATES)
into the `.github/linters/` folder in your own repository if super-linter
provides one, or create a new configuration file according to the linter
documentation. Finally, edit the configuration file to to suit your use case.

View each linters source and web page from the
[Supported Linters README](https://github.com/super-linter/super-linter#supported-linters)
to see additional information on how to configure, disable, or tune additional
rules.
