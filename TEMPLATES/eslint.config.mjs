import { defineConfig, globalIgnores } from "eslint/config";
import n from "eslint-plugin-n";
import prettier from "eslint-plugin-prettier";
import globals from "globals";
import eslintPluginJsonc from "eslint-plugin-jsonc";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
import pluginVue from "eslint-plugin-vue";
import path from "node:path";
import { fileURLToPath } from "node:url";
import js from "@eslint/js";
import { FlatCompat } from "@eslint/eslintrc";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
  allConfig: js.configs.all,
});

export default defineConfig([
  globalIgnores(["!**/.*", "**/node_modules/.*"]),
  {
    extends: compat.extends("eslint:recommended"),

    plugins: {
      n,
      prettier,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jest,
        ...globals.node,
      },
    },
  },
  ...eslintPluginJsonc.configs["recommended-with-json"].map((config) => ({
    ...config,
    files: ["**/*.json"],
  })),
  ...eslintPluginJsonc.configs["recommended-with-jsonc"].map((config) => ({
    ...config,
    files: ["**/*.jsonc"],
  })),
  ...eslintPluginJsonc.configs["recommended-with-json5"].map((config) => ({
    ...config,
    files: ["**/*.json5"],
  })),
  {
    files: ["**/*.js", "**/*.mjs", "**/*.cjs", "**/*.jsx"],
    extends: compat.extends("plugin:react/recommended"),

    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",

      parserOptions: {
        ecmaFeatures: {
          jsx: true,
          modules: true,
        },
      },
    },
  },
  {
    files: ["**/*.ts", "**/*.cts", "**/*.mts", "**/*.tsx"],

    extends: compat.extends(
      "plugin:@typescript-eslint/recommended",
      "plugin:n/recommended",
      "plugin:react/recommended",
      "prettier",
    ),

    plugins: {
      "@typescript-eslint": typescriptEslint,
    },

    languageOptions: {
      parser: tsParser,
      ecmaVersion: "latest",
      sourceType: "module",
    },
  },
  ...pluginVue.configs["flat/recommended"],
]);
