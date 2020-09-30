#!/usr/bin/env python3
"""
Use clj-kondo to lint Clojure files
https://github.com/borkdude/clj-kondo
"""

from superlinter import LinterTemplate


class ClojureLinter(LinterTemplate):
    language = "CLOJURE"
    linter_name = "clj-kondo"
    linter_url = "https://github.com/borkdude/clj-kondo"
    config_file_name = ".clj-kondo/config.edn"
    file_extensions = ['.clj', '.cljs', '.cljc', '.edn']

    # Build the CLI command to call to lint a file
    def build_lint_command(self, file):
        cmd = ["clj-kondo"]
        if self.config_file is not None:
            cmd.extend(["--config", self.config_file])
        cmd.append('--lint')
        cmd.append(file)
        return cmd
