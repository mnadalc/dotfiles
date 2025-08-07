return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  config = function()

    require("claude-code").setup()

    -- set keymaps
    local keymap = vim.keymap -- for conciseness
		keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "[C]laude [C]ode" })
  end
}