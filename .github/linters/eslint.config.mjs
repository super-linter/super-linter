// Import the Super-linter ESLint default config
import baseConfig from "/action/lib/.automation/eslint.config.mjs";

const newVueRules = {
  // In Vue tests, we have a file that triggers vue/html-indent.
  // vue/html-indent is auto-fixable, and it's considered a warning in the
  // default eslint-plugin-vue configuration. Raise the severity to error
  // because warnings don't make ESLint exit with an error by default.
  "vue/html-indent": ["error", 2],
};

const newJsoncRules = {
  // Enable a fixable rule when linting JSONC files
  "jsonc/sort-array-values": [
    "error",
    {
      pathPattern: "^BAD$",
      order: { type: "asc" },
    },
  ],
};

const finalConfig = baseConfig.map((config) => {
  const isJsoncConfig = config.files?.includes("**/*.jsonc");
  const isJsonConfig = config.files?.includes("**/*.json");
  const isVueConfig = config.files?.includes("**/*.vue");

  if (isVueConfig) {
    return {
      ...config,
      rules: {
        ...config.rules,
        ...newVueRules,
      },
    };
  } else if (isJsoncConfig || isJsonConfig) {
    return {
      ...config,
      rules: {
        ...config.rules,
        ...newJsoncRules,
      },
    };
  }
  return config;
});

export default finalConfig;
