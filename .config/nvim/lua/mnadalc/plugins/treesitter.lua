-- Highlight, edit, and navigate code (Treesitter)

return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/playground', -- 🔥 required for TSPlaygroundToggle
    'yioneko/nvim-yati', -- tree-sitter indent plugin
  },
  opts = {
    -- https://github.com/nvim-treesitter/nvim-treesitter/?tab=readme-ov-file#supported-languages
    ensure_installed = {
      'astro',
      'bash',
      'comment',
      'css',
      'diff',
      'gitcommit',
      'gitignore',
      'html',
      'javascript',
      'json',
      'latex',
      'lua',
      'luadoc',
      'markdown_inline',
      'markdown',
      'php',
      'query',
      'regex',
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
    indent = { enable = false }, -- disable builtin indent module in favour of yati
    autotag = { enable = true },
    playground = {
      enable = true,
    },
    -- yati
    yati = {
      enable = true,
      disable = { 'python' },
      default_lazy = true,
      default_fallback = "auto",
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