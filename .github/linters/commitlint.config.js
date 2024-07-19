module.exports = {
  extends: ["@commitlint/config-conventional"],
  helpUrl: "https://www.conventionalcommits.org/",
  // We need this until https://github.com/dependabot/dependabot-core/issues/2445
  // is resolved.
  ignores: [(msg) => /Signed-off-by: dependabot\[bot]/m.test(msg)],
};
