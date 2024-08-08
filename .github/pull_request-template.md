<!-- Start with an H2 because GitHub automatically adds the commit description before the template, -->
<!-- so contributors don't have to manually cut-paste the description after the H1. -->
<!-- markdownlint-disable-next-line MD041 -->
## Readiness checklist

In order to have this pull request merged, complete the following tasks.

### Pull request author tasks

- [ ] I checked that all workflows return a success.
- [ ] I included all the needed documentation for this change.
- [ ] I provided the necessary tests.
- [ ] I squashed all the commits into a single commit.
- [ ] I followed the [Conventional Commit v1.0.0 spec](https://www.conventionalcommits.org/en/v1.0.0/).
- [ ] I wrote the necessary upgrade instructions in the [upgrade guide](../docs/upgrade-guide.md).
- [ ] If this pull request is about and existing issue,
  I added the `Fix #ISSUE_NUMBER` or `Close #ISSUE_NUMBER` text to the description of the pull request.

### Super-linter maintainer tasks

- [ ] Label as `breaking` if this change breaks compatibility with the previous released version.
- [ ] Label as either: `automation`, `bug`, `documentation`, `enhancement`, `infrastructure`.
- [ ] Add the pull request to a milestone, eventually creating one, that matches
  with the version that release-please proposes in the `preview-release-notes` CI job.
