import eslintPluginPrettierRecommended from "eslint-plugin-prettier/recommended";
import globals from "globals";
import pluginJs from "@eslint/js";
import solid from "eslint-plugin-solid/configs/typescript";
import storybook from "eslint-plugin-storybook";
import tseslint from "typescript-eslint";

/** @type {import('eslint').Linter.Config[]} */
export default [
  pluginJs.configs.recommended,
  ...tseslint.configs.strict,
  ...tseslint.configs.stylistic,

  eslintPluginPrettierRecommended,

  ...storybook.configs["flat/recommended"],
  {
    files: ["**/*.{js,mjs,cjs,ts,jsx,tsx}"],
    ...solid,
    languageOptions: { globals: globals.browser },
    rules: {
      "dot-notation": "warn",
      eqeqeq: "warn",
      "id-length": "warn",
      "require-unicode-regexp": "error",
      "sort-imports": "error",
      "sort-keys": "error",
    },
    settings: {},
  },
  {
    ignores: ["**/pb/*"],
  },
];

// "eslintConfig": {
//   "extends": [
//     "plugin:storybook/recommended",
//     "plugin:storybook/recommended"
//   ]
// },
