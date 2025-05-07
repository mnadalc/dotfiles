-- Set line number colors

-- Absolute line numbers → custom light gray
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cccccc" })

-- Current line number → brighter white + bold
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })

-- Relative numbers (above/below) → use colorscheme defaults
vim.api.nvim_set_hl(0, "LineNrAbove", {})
vim.api.nvim_set_hl(0, "LineNrBelow", {})