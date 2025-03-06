return {
  -- Plugin del esquema de colores
  {
    "catppuccin/nvim",
    priority = 1000,
    config = function()
      -- Habilitar soporte para colores verdaderos
      vim.opt.termguicolors = true
      -- Aplicar el esquema de colores
      vim.cmd("colorscheme catppuccin")
    end,
  },
}

