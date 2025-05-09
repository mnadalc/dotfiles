return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "zapling/mason-conform.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    -- import mason-tool-installer
    local mason_tool_installer = require("mason-tool-installer")

    -- import mason-conform
    local mason_conform = require("mason-conform")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_conform.setup({
      ensure_installed = {
        "eslint",
        "eslint_d",
        "prettierd",
        "prettier",
        "stylua",
      },
      -- Optional: install only when needed
      auto_install = true,
    })

    mason_lspconfig.setup({
      ensure_installed = {}, -- explicitly set to an empty table (populates installs via mason-tool-installer)
      automatic_installation = false,
    })

    -- https://mason-registry.dev/registry/list
    mason_tool_installer.setup({
      ensure_installed = {
        "ast_grep",
        "astro-language-server",
        "bashls",
        "html",
        "ltex",
        "lua_ls",
        "mdx_analyzer",
        "vtsls",
        "yaml-language-server",
        "cssls",
        "rustywind", -- rustywind for tailwindcss
        "tailwindcss",
        "typos-lsp", -- code spell
      },
    })
  end,
}