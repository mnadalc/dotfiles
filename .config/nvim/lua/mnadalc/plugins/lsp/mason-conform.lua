-- plugins/lsp/mason-conform.lua
return {
  "zapling/mason-conform.nvim",
  dependencies = { "williamboman/mason.nvim", "stevearc/conform.nvim" },
  config = function()
    require("mason-conform").setup({
      ensure_installed = {
        "beautysh",
        "eslint_d",
        "prettierd",
        "shfmt",
        "stylua",
        -- add more if you format other languages
      },
      -- Optional: install only when needed
      auto_install = true,
    })
  end,
}
