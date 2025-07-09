import { defineConfig, globalIgnores } from "eslint/config";
import n from "eslint-plugin-n";
import prettier from "eslint-plugin-prettier";
import globals from "globals";
import jsoncParser from "jsonc-eslint-parser";
import typescriptEslint from "@typescript-eslint/eslint-plugin";
import tsParser from "@typescript-eslint/parser";
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
  {
    files: ["**/*.json"],
    extends: compat.extends("plugin:jsonc/recommended-with-json"),

    languageOptions: {
      parser: jsoncParser,
      ecmaVersion: "latest",
      sourceType: "script",

      parserOptions: {
        jsonSyntax: "JSON",
      },
    },
  },
  {
    files: ["**/*.jsonc"],
    extends: compat.extends("plugin:jsonc/recommended-with-jsonc"),

    languageOptions: {
      parser: jsoncParser,
      ecmaVersion: "latest",
      sourceType: "script",

      parserOptions: {
        jsonSyntax: "JSONC",
      },
    },
  },
  {
    files: ["**/*.json5"],
    extends: compat.extends("plugin:jsonc/recommended-with-json5"),

    languageOptions: {
      parser: jsoncParser,
      ecmaVersion: "latest",
      sourceType: "script",

      parserOptions: {
        jsonSyntax: "JSON5",
      },
    },
  },
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
  {
    files: ["**/*.vue"],
    extends: compat.extends("plugin:vue/recommended"),

    languageOptions: {
      parser: vueParser,
      ecmaVersion: "latest",
      sourceType: "module",

      parserOptions: {
        ecmaFeatures: {
          modules: true,
        },
      },
    },
  },
]);
