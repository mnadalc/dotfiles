-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{ "<leader>ee", ":Neotree float toggle<CR>", desc = "Toggle [E]xplorer", silent = true },
		{ "<leader>eg", ":Neotree float git_status<CR>", desc = "Toggle [E]xplorer [G]it Status", silent = true },
	},
	lazy = false,
	opts = {
		filesystem = {
      hijack_netrw_behavior = "disabled", -- Or "open_default" to open the file in the default program
			filtered_items = {
				visible = true,
				show_hidden_count = true,
				hide_dotfiles = false,
				hide_gitignored = true,
				hide_by_name = {
					".git",
					".DS_Store",
					"thumbs.db",
				},
				never_show = {},
			},
		},
	},
  config = function(_, opts)
    require("neo-tree").setup(opts)
    vim.keymap.set('n', '<C-b>', '<CMD>Neotree toggle<CR>', { silent = true })
  end,
}
