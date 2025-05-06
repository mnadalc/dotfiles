-- Maximize/minimize a split window

return {
  "szw/vim-maximizer",
  keys = {
    { "<leader>sz", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
  },
}