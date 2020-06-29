# Contributing
:wave: Hi there!
We're thrilled that you'd like to contribute to this project. Your help is essential for keeping it great.

## Submitting a pull request
[Pull Requests][pulls] are used for adding new playbooks, roles, and documents to the repository, or editing the existing ones.

**With write access**
1. Clone the repository (only if you have write access)
1. Create a new branch: `git checkout -b my-branch-name`
1. Make your change
1. Push and [submit a pull request][pr]
1. Pat yourself on the back and wait for your pull request to be reviewed and merged.

**Without write access**
1. [Fork][fork] and clone the repository
1. Create a new branch: `git checkout -b my-branch-name`
1. Make your change
1. Push to your fork and [submit a pull request][pr]
1. Pat your self on the back and wait for your pull request to be reviewed and merged.

Here are a few things you can do that will increase the likelihood of your pull request being accepted:

- Keep your change as focused as possible. If there are multiple changes you would like to make that are not dependent upon each other, consider submitting them as separate pull requests.
- Write [good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).

Draft pull requests are also welcome to get feedback early on, or if there is something blocking you.

- Create a branch with a name that identifies the user and nature of the changes (similar to `user/branch-purpose`)
- Open a pull request

## Releasing
If you are the current maintainer of this action:
1. If a major version number change: Update `README.md` and the wiki to reflect new version number in the example workflow file sections
2. Draft [Release](https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository) with a summarized changelog
3. Ensure you check the box for [publishing to the marketplace](https://help.github.com/en/actions/creating-actions/publishing-actions-in-github-marketplace#publishing-an-action)
4. A GitHub Action will Publish the Docker image to GitHub Package Registry once a Release is created
5. A GitHub Action will Publish the Docker image to Docker Hub once a Release is created
6. Look for approval from [CODEOWNERS](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners)

## Resources
- [How to Contribute to Open Source](https://opensource.guide/how-to-contribute/)
- [Using Pull Requests](https://help.github.com/articles/about-pull-requests/)
- [GitHub Help](https://help.github.com)

[pulls]: https://github.com/github/super-linter/pulls
[pr]: https://github.com/github/super-linter/compare
[fork]: https://github.com/github/super-linter/fork
