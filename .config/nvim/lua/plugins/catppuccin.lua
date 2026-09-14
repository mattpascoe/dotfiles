return {
  -- Catppuccin Color scheme
  {
    'catppuccin/nvim',
    as = 'catppuccin',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.opt.termguicolors = true
    end,
    config = function()
      -- setup() must run before colorscheme or color_overrides are ignored
      require('catppuccin').setup {
        flavour = 'mocha',
        no_italic = true,
        -- TODO more playing with colors yet to be done
        color_overrides = {
          mocha = {
            base = '#000000', -- Make the primary background black
            -- mantle = '#242424',
            -- crust = '#474747',
          },
        },
        custom_highlights = {
          VirtColumn = { fg = '#06060F' },
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
      vim.cmd.colorscheme 'catppuccin'
    end,
  },
}
