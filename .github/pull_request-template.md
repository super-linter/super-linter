<!-- Start with an H2 because GitHub automatically adds the commit description before the template, -->
<!-- so contributors don't have to manually cut-paste the description after the H1. -->
<!-- Also, include the header in a "prettier ignore" block because it adds a blank line -->
<!-- after the markdownlint-disable-next-line directive, making it useless. -->
<!-- Ref: https://github.com/prettier/prettier/issues/14350 -->
<!-- Ref: https://github.com/prettier/prettier/issues/10128 -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable-next-line MD041 -->
## Readiness checklist
<!-- prettier-ignore-end -->

In order to have this pull request merged, complete the following tasks.

### Pull request author tasks

- [ ] I checked that all workflows return a success.
- [ ] I included all the needed documentation for this change.
- [ ] I provided the necessary tests.
- [ ] I squashed all the commits into a single commit.
- [ ] I followed the
      [Conventional Commit v1.0.0 spec](https://www.conventionalcommits.org/en/v1.0.0/).
- [ ] I wrote the necessary upgrade instructions in the
      [upgrade guide](https://github.com/super-linter/super-linter/blob/main/docs/upgrade-guide.md).
- [ ] If this pull request is about and existing issue, I added the
      `Fix #ISSUE_NUMBER` or `Close #ISSUE_NUMBER` text to the description of
      the pull request.

### Super-linter maintainer tasks

- [ ] Label as `breaking` if this change breaks compatibility with the previous
      released version.
- [ ] Label as either: `automation`, `bug`, `documentation`, `enhancement`,
      `infrastructure`.
- [ ] Add the pull request to a milestone, eventually creating one, that matches
      with the version that release-please proposes in the
      `preview-release-notes` CI job.
