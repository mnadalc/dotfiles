-- You can easily change to a different colorscheme. (Catppuccin)
-- Change the name of the colorscheme plugin below, and then
-- change the command in the config to whatever the name of that colorscheme is.
--
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.

return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  opts = {
    integrations = {
      mason = true,
      semantic_tokens = true,
      symbols_outline = true,
      -- telescope = true,
      ts_rainbow = false,
      which_key = true,
    },
  },
  config = function()
    vim.cmd.colorscheme 'catppuccin'
  end,
}