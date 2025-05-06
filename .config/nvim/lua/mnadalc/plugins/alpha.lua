-- Dashboard (Alpha nvim)

return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'

    -- Set header
    dashboard.section.header.val = {
      '███    ██ ███████  ██████  ██    ██ ██ ███    ███',
      '████   ██ ██      ██    ██ ██    ██ ██ ████  ████',
      '██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██',
      '██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██',
      '██   ████ ███████  ██████    ████   ██ ██      ██',
    }

    -- Set menu
    dashboard.section.buttons.val = {
      dashboard.button('e', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('SPC ee', '  > [E]xplorer', '<cmd>NvimTreeToggle<CR>'),
      dashboard.button('SPC sf', '󰱼  > [S]earch [F]iles', '<cmd>Telescope find_files<CR>'),
      dashboard.button('SPC sg', '  > [S]earch by [G]rep (Search word)', '<cmd>Telescope live_grep<CR>'),
      dashboard.button('SPC wr', '󰁯  > Restore Session For Current Directory', '<cmd>SessionRestore<CR>'),
      dashboard.button('q', '  > [Q]uit', '<cmd>qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}