-- Set line number colors

-- Almost white for normal line numbers
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cccccc" })  -- Light gray/white-ish

-- Pure white or brighter for the current line number
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true })

-- Optional: if using Neovim 0.10+, set relative line number colors above/below
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#cccccc" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#cccccc" })
