-- Adds a bufferline to the top of the screen

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    -- options = {
    --   mode = "tabs",
    --   separator_style = "slant",
    -- },
    options = {
      separator_style = "slant",
      mode = "buffers",                  -- show buffers, not Neovim tabs
      close_command = "bdelete %d",       -- close buffer with :bdelete
      right_mouse_command = "bdelete %d",
      diagnostics = "nvim_lsp",           -- show LSP errors/warnings
      always_show_bufferline = false,     -- hide when only one buffer
      offsets = {
        { filetype = "snacks_explorer", text = "Explorer", separator = true },
      },
    },
  },
}