return {
  -- Catppuccin Color scheme
  {
    'catppuccin/nvim',
    as = 'catppuccin',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'catppuccin'
      vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#030307' }) -- Draw a highlight at the colorcolumn position also liked #06060F
    end,
    config = function()
      require('catppuccin').setup {
        flavor = 'mocha',
        no_italic = true,
        -- TODO more playing with colors yet to be done
        color_overrides = {
          mocha = {
            base = '#000000', -- Make the primary background black
            -- mantle = '#242424',
            -- crust = '#474747',
          },
        },
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      }
    end,
  },
}
