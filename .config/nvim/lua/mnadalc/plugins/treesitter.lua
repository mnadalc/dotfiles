-- Highlight, edit, and navigate code (Treesitter)

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/playground', -- 🔥 required for TSPlaygroundToggle
  },
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'css',
      'diff',
      'html',
      'javascript',
      'lua',
      'luadoc',
      'markdown_inline',
      'markdown',
      'query',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
    autotag = { enable = true },

    playground = {
      enable = true,
    },

    -- ⬇️ Block for textobjects
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to the nearest textobject
        keymaps = {
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["at"] = "@tag.outer",
          ["it"] = "@tag.inner",
        },
      },
    },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}