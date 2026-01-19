// Import the Super-linter ESLint default config
import baseConfig from "/action/lib/.automation/eslint.config.mjs";

export default [
  ...baseConfig,
  {
    files: ["**/*.vue"],
    rules: {
      // In Vue tests, we have a file that triggers vue/html-indent.
      // vue/html-indent is auto-fixable, and it's considered a warning in the
      // default eslint-plugin-vue configuration. Raise the severity to error
      // because warnings don't make ESLint exit with an error by default.
      "vue/html-indent": ["error", 2],
    },
  },
  {
    files: ["**/*.json", "**/*.jsonc"],
    rules: {
      // Enable a fixable rule when linting JSONC files
      "jsonc/sort-array-values": [
        "error",
        {
          pathPattern: "^BAD$",
          order: { type: "asc" },
        },
      ],
    },
  },
];
