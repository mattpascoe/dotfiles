return {
  -- Catppuccin Color scheme
  {
    'catppuccin/nvim',
    as = 'catppuccin',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.opt.termguicolors = true
      vim.cmd.colorscheme 'catppuccin'
      -- vim.opt.colorcolumn = '80'
      -- vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#06060F' }) -- Draw a highlight at the colorcolumn position
      -- Using virt-column now instead of the colorcolumn above
      vim.api.nvim_set_hl(0, 'VirtColumn', { fg = '#06060F' }) -- Draw a highlight at the virtcolumn position
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
          mason = true,
          notify = true,
          fidget = true,
          vimwiki = true,
          which_key = true,
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
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
