# Parallel / Batched Workers

Running linters in parallel, and if possible in batch to speed up the linting process.

This is an experimental feature, and is not enabled by default, but it is really fast if you enable it and have the linter support implemented.

Since it is a parallel version, it might not be possible to reproduce a line-by-line match of serial output.

In order to maximize compatibility to programs using output of super-linter, the following are guarenteed:
- Every linter error reported in serial version is reported by parallel version [^linter-error];
- Super-linter log-level WARN and above that appears in serial version should appear in this version;
- Super-linter log-level INFO and above do not interleave between linter output;
- Failed file count logged at the end of super-linter matches serial version;

[^linter-error]: Statistics are almost impossible to reproduce, e.g. was always `1 file linted, K errors` but now `M files linted, K errors`, I guess it is fine as the stat for linting 1 file produced by linter is not very useful.

## Motivation

Some linter might have a high startup cost, e.g.
- `eslint` with some popular frontend framework plugins requires reading thousands of js files to init
- `cfn-lint` which requires reading the whole cloudformation spec to run

A lot of linter supports linting multiple files per invocation, i.e. `<linter-name> file1 file2 file3 ...`, which can be leveraged to reduce the startup overhead.

Modern CI/CD might be on a multi-core machine, so running multiple linters in parallel can also speed up linting process, shorten the time taken from push to deploy.

Shift-left paradigm encourages running linters in the IDE, for example in `.githooks/pre-commit`, linting need to be fast for good Developer experience.

## Supported linters

| Linter   | Batch | Parallel | Notes                       |
| -------- | ----- | -------- | --------------------------- |
| cfn-lint | o     | o        |                             |
| ESLint   | o     | o        |                             |
| gitleaks |       | o        | Batch unsupported by linter |

## Architecture

By setting `EXPERIMENTAL_BATCH_WORKER=true`, the following code path will be enabled:

```bash
# ../worker.sh
LintCodebase
  # ./${LinterName}.sh
  # TASK: Modify linter command for batch, parallelization and batching parameters suitable for the linter
  ParallelLintCodebase${LinterName}
    # ./base.sh
    # gnu parallel run
    ParallelLintCodebaseImpl
      # ./${LinterName}.sh
      # TASK: see ./base.sh
      LintCodebase${LinterName}StdoutParser
      # ./${LinterName}.sh
      # TASK: see ./base.sh
      LintCodebase${LinterName}StderrParser
      # ./base.sh if the default works for you
      LintCodebaseBaseStderrParser
```
