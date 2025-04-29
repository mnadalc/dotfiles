--[[
https://github.com/stevearc/conform.nvim
╭────────────────────────────────────────────────────────────────────────────╮
│ 🎨 Conform.nvim - Auto Formatter Plugin                                    │
├────────────────────────────────────────────────────────────────────────────┤
│ This plugin handles code formatting via external formatters like:          │
│   - prettierd / prettier (JS, TS, HTML, CSS, etc.)                         │
│   - stylua (Lua)                                                           │
│   - shfmt, beautysh (Shell)                                                │
│                                                                            │
│ ✅ FORMAT ON SAVE                                                          │
│   This file configures Conform to format files automatically on `:w`,      │
│   depending on filetype and project configuration.                         │
│                                                                            │
│ 🔍 FORMATTER PRIORITY                                                      │
│   Conform will:                                                            │
│     1. Use the best-matching formatter per filetype                        │
│     2. Fallback to LSP formatting if no formatter is defined               │
│     3. Use timeout and project-aware settings                              │
│                                                                            │
│ 🔄 RELATION TO OTHER CONFIG FILES                                          │
│ - `options.lua`: Sets general Neovim editor behavior (tabs, spacing, etc.) │
│   → Does NOT control formatting behavior                                   │
│                                                                            │
│ - `.prettier config files`: Project-level Prettier config files            │
│   → Used by `prettierd` to determine style (tabs vs spaces, width, etc.)   │
│                                                                            │
│ - `.editorconfig`: Used to sync tab/spacing *visuals* in Neovim via        │
│   `editorconfig.nvim`, but does NOT control formatter behavior             │
│                                                                            │
│ 📁 MONOREPO SUPPORT (IMPORTANT)                                            │
│ We override `cwd` for `prettierd` to detect the correct project root.      │
│ This is essential in monorepos where Prettier plugins/configs are          │
│ defined at sub-project level.                                              │
│ See the `formatters = {}` block for details.                               │
╰────────────────────────────────────────────────────────────────────────────╯
]] 
--

local project_roots = {
  ".eslintrc.cjs",
  ".eslintrc.json",
  ".eslintrc.mjs",
  ".eslintrc",
  ".git",
  ".prettierrc.cjs",
  ".prettierrc.json",
  ".prettierrc.mjs",
  ".prettierrc",
  "config/application.rb",
  "elm.json",
  "Gemfile",
  "package.json",
  "eslint.config.js",
  "prettier.config.js",
  "tailwind.config.js",
  "tsconfig.json",
  "typescript.config.js",
}

return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = function()
    local util = require("conform.util")
    return {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 2000,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
        astro = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        graphql = { "prettierd", "prettier", stop_after_first = true },
        handlebars = { "prettierd", "prettier", stop_after_first = true },
        hbs = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        javascript = {
          "eslint_d",
          "eslint",
          "prettierd",
          "prettier",
        },
        javascriptreact = {
          "eslint_d",
          "eslint",
          "prettierd",
          "prettier",
        },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        less = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        mdx = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        toml = { "prettierd", "prettier", stop_after_first = true },
        twig = { "prettierd", "prettier", stop_after_first = true },
        typescript = {
          "eslint_d",
          "eslint",
          "prettierd",
          "prettier",
        },
        typescriptreact = {
          "eslint_d",
          "eslint",
          "prettierd",
          "prettier",
        },
        vue = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
      },
      formatters = {
        -- 🧠 Set the working directory (`cwd`) for prettierd to ensure it runs
        -- from the correct place in multi-project setups like monorepos.
        -- This is necessary because prettierd needs to find:
        -- - Prettier config files (like `prettier.config.js`)
        -- - Plugins (`node_modules`)
        -- - Tailwind config, etc.
        --
        -- If cwd is not set properly, you'll get errors like:
        -- "Cannot find module '@tailwindcss/typography'"
        --
        -- This tells Conform to start searching up the directory tree from the
        -- current file and stop at the first folder that has one of these files.
        -- That folder becomes the "project root" for Prettier to work correctly.
        prettierd = {
          cwd = util.root_file(project_roots),
        },
        eslint_d = {
          cwd = util.root_file(project_roots),
        },
        prettier = {
          cwd = util.root_file(project_roots),
        },
        eslint = {
          cwd = util.root_file(project_roots),
        },
      },
    }
  end,
}