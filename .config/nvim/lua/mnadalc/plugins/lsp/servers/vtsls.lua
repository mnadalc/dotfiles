-- ~/.config/nvim/lua/lsp/servers/vtsls.lua  (or wherever your LSP configs go)

return {
  -- This assumes you're using mason-lspconfig or similar to auto-setup servers
  settings = {
    typescript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true, -- Show enum member values (e.g., Status.Ready = 0 → shows ": 0")
        includeInlayFunctionLikeReturnTypeHints = true, -- Show function/method return type hints (e.g., (): string)
        includeInlayFunctionParameterTypeHints = true, -- Show the inferred type of parameters in functions
        includeInlayParameterNameHints = "all", -- Always show parameter names at call sites (e.g., doSomething(value: number))
        includeInlayParameterNameHintsWhenArgumentMatchesName = true, -- Still show the param name even if the variable name matches
        includeInlayPropertyDeclarationTypeHints = true, -- 🔥 Show type hints on properties & destructured variables (ex: [x: number, y: number] = useSomething())
        includeInlayVariableTypeHints = true, -- Show type hints for variable declarations (const x = ... → x: string)
        includeInlayVariableTypeHintsWhenTypeMatchesName = false, -- Don’t suppress hints even if type and name match (e.g., const count: number)
        includeInlayTupleElementTypeHints = true, -- Try to show type hints in tuple destructuring like useState
      },
    },
    javascript = {
      inlayHints = {
        includeInlayEnumMemberValueHints = true, -- Same as above but for JS files
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayTupleElementTypeHints = true, -- Try to show type hints in tuple destructuring like useState
      },
    },
  },
  on_attach = function(client, bufnr)
    -- Enable inlay hints if supported
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

      -- Create a toggle keymap for inlay hints
      vim.keymap.set("n", "<leader>th", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
      end, { desc = "Toggle Inlay Hints", buffer = bufnr })
    end
  end,
}
