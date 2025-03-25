-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  branch = "v3.x",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>ee', ':Neotree toggle<CR>', desc = 'Toggle [E]xplorer', silent = true },
    { '<leader>eg', ':Neotree float git_status<CR>', desc = 'Toggle [E]xplorer [G]it Status', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          -- You can add other window-specific mappings here if needed
        },
      },
    },
  },
}
