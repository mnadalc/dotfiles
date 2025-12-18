-- Add indentation guides even on blank lines, among other things
-- Smooth scrolling
-- https://github.com/folke/snacks.nvim

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        -- {
        --   pane = 2,
        --   section = "terminal",
        --   cmd = "colorscript -e square",
        --   height = 5,
        --   padding = 1,
        -- },
        { section = "keys", gap = 1, padding = 1 },
        { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
        { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git status --short --branch --renames",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        { section = "startup" },
      },
    },
    explorer = {
      enabled = true,
    },
    indent = {
      enabled = true,
      scope = {
        enabled = true, -- must be on for current indent highlight
        animate = {
          enabled = false,
        }
      },
    },
    input = { enabled = true },
    picker = {
      enabled = true,
      sources = {
        explorer = {
          hidden = true,
        },
      },
    },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader>sf", function() Snacks.picker.smart() end, desc = "[S]earch Smart Files" },
    { "<leader>sb", function() Snacks.picker.buffers() end, desc = "[S]earch [B]uffers" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "[S]earch [G]rep" },
    { "<leader>sc", function() Snacks.picker.command_history() end, desc = "[S]earch [C]ommand History" },
    { "<leader>sn", function() Snacks.picker.notifications() end, desc = "[S]earch [N]otification History" },
    -- Explorer
    { "<leader>ee", function() Snacks.explorer() end, desc = "[E]xplorer" },
    -- { "<leader>ef", function() Snacks.explorer_current_file() end, desc = "[E]xplorer [F]ile" },
  },
  init = function()
    -- This VimEnter event fires and automatically opens the Snacks file explorer.
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --   callback = function()
    --     Snacks.explorer({ focus = false }) -- abre sin tomar foco
    --     vim.cmd("wincmd p") -- vuelve a la ventana previa (el editor)
    --   end,
    -- })

    -- vim.api.nvim_create_autocmd("ColorScheme", {
    --   callback = function()
    --     vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ffffff" })
    --   end,
    -- })
    -- set it now in case the colorscheme is already applied
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ffffff" })
  end,
}