import { defineConfig, globalIgnores } from "eslint/config";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import globals from "globals";
import tsParser from "@typescript-eslint/parser";
import jsonParser from "jsonc-eslint-parser";
import vueParser from "vue-eslint-parser";
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
      "@typescript-eslint": typescriptEslint,
    },

    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.jest,
        ...globals.node,
      },

      parser: tsParser,
    },
  },
  {
    files: ["**/*.json"],
    extends: compat.extends("plugin:jsonc/recommended-with-json"),

    languageOptions: {
      parser: jsonParser,
    },
  },
  {
    files: ["**/*.jsonc"],
    extends: compat.extends("plugin:jsonc/recommended-with-jsonc"),

    languageOptions: {
      parser: jsonParser,
    },
  },
  {
    files: ["**/*.json5"],
    extends: compat.extends("plugin:jsonc/recommended-with-json5"),

    languageOptions: {
      parser: jsonParser,
    },
  },
  {
    files: ["**/*.jsx", "**/*.tsx"],
    extends: compat.extends("plugin:react/recommended"),
  },
  {
    files: ["**/*.vue"],
    extends: compat.extends("plugin:vue/recommended"),

    languageOptions: {
      parser: vueParser,
    },
  },
]);
