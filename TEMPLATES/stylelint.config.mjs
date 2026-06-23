import postcssScss from "postcss-scss";

export default {
  extends: ["stylelint-config-standard"],
  overrides: [
    {
      files: ["*.scss", "**/*.scss"],
      extends: ["stylelint-config-recommended-scss"],
      customSyntax: postcssScss,
    },
  ],
};
