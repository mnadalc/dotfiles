-- Harpoon

return {
  -- "ThePrimeagen/harpoon",
  -- branch = "harpoon2",
  -- event = { "BufReadPre", "BufNewFile" },
  -- dependencies = {
  --   "nvim-lua/plenary.nvim",
  -- },
  -- opts = {
  --   settings = {
  --     save_on_toggle = true,
  --   },
  -- },
  -- keys = function()
  --   local keys = {
  --     {
  --       "<leader>hh",
  --       function()
  --         require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
  --       end,
  --       desc = "Toggle menu",
  --     },
  --     {
  --       "<leader>ha",
  --       function()
  --         require("harpoon"):list():add()
  --       end,
  --       desc = "Add File",
  --     },
  --     {
  --       "<leader>hc",
  --       function()
  --         require("harpoon"):list():clear()
  --       end,
  --       desc = "Clear All",
  --     },
  --     {
  --       "<leader>hn",
  --       function()
  --         require("harpoon"):list():next()
  --       end,
  --       desc = "Next File",
  --     },
  --     {
  --       "<leader>hp",
  --       function()
  --         require("harpoon"):list():prev()
  --       end,
  --       desc = "Previous File",
  --     },
  --   }
  --   for i = 1, 5 do
  --     table.insert(keys, {
  --       "<leader>" .. i,
  --       function()
  --         require("harpoon"):list():select(i)
  --       end,
  --       desc = "Go To Mark " .. i,
  --     })
  --   end
  --   return keys
  -- end,
  "ThePrimeagen/harpoon",
  lazy = false,
  branch = "harpoon2",
  init = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end, { desc = "Add File" })
    vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle menu" })

    vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end, { desc = "Go To Mark 1" })
    vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end, { desc = "Go To Mark 2" })
    vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end, { desc = "Go To Mark 3" })
    vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end, { desc = "Go To Mark 4" })
    vim.keymap.set("n", "<leader>h5", function() harpoon:list():select(5) end, { desc = "Go To Mark 5" })
    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader>hp", function() harpoon:list():prev() end, { desc = "Previous File" })
    vim.keymap.set("n", "<leader>hn", function() harpoon:list():next() end, { desc = "Next File" })

    -- Clear all stored buffers within Harpoon list
    vim.keymap.set("n", "<leader>hc", function() harpoon:list():clear() end, { desc = "Clear All" })
  end,
  dependencies = { "nvim-lua/plenary.nvim" },
}