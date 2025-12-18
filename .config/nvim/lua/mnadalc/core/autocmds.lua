
-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Save all modifiable and modified buffers when Neovim loses focus
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
        and vim.api.nvim_buf_get_option(buf, "modifiable")
        and not vim.api.nvim_buf_get_option(buf, "readonly")
        and vim.api.nvim_buf_get_option(buf, "modified")
      then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end
    end
  end,
})

-- Restore cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[:%s/\s\+$//e]],
})

-- Highlight when yanking (copying) text
--  Try it with `yapseparator_style = "slant",` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Check if files have changed outside of Neovim and reload them
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime"
})

-- Disable line wrapping for certain file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    if not vim.tbl_contains({ "markdown", "text", "gitcommit" }, vim.bo.filetype) then
      vim.opt_local.wrap = false
    end
  end,
})

-- Highlight on search (but clear when done)
vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "/,\\?",
  callback = function()
    vim.cmd("set nohlsearch")
  end,
})

--[[
-- Relative and absolute numbers on the left.
-- ]]
-- Helper to decide if relativenumber should be toggled
local function should_toggle_relativenumber()
  -- local ignore_filetypes = { "neo-tree", "TelescopePrompt", "alpha", "help", "dashboard" }
  local ignore_filetypes = { "help", "dashboard" }
  return not vim.tbl_contains(ignore_filetypes, vim.bo.filetype)
end

-- Disable relative numbers in insert mode, unless excluded
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    if should_toggle_relativenumber() then
      vim.opt.relativenumber = false
    end
  end,
})

-- Enable relative numbers when leaving insert mode, unless excluded
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if should_toggle_relativenumber() then
      vim.opt.relativenumber = true
    end
  end,
})
