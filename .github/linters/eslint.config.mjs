// Import the Super-linter ESLint default config
import baseConfig from "/action/lib/.automation/eslint.config.mjs";

const newVueRules = {
  // In Vue tests, we have a file that triggers vue/html-indent.
  // vue/html-indent is auto-fixable, and it's considered a warning in the
  // default eslint-plugin-vue configuration. Raise the severity to error
  // because warnings don't make ESLint exit with an error by default.
  "vue/html-indent": ["error", 2],
};

const finalConfig = baseConfig.map((config) => {
  const isVueConfig = config.files?.includes("**/*.vue");
  if (isVueConfig) {
    return {
      ...config,
      rules: {
        ...config.rules,
        ...newVueRules,
      },
    };
  }
  return config;
});

export default finalConfig;
