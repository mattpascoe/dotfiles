-- return {
--   'MeanderingProgrammer/render-markdown.nvim',
--   dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
--   ---@module 'render-markdown'
--   ---@type render.md.UserConfig
--   opts = {},
-- }

-- from https://github.com/linkarzu/dotfiles-latest/blob/main/neovim/neobean/lua/plugins/render-markdown.lua
--
-- https://github.com/MeanderingProgrammer/markdown.nvim
--
-- When I hover over markdown headings, this plugins goes away, so I need to
-- edit the default highlights
-- I tried adding this as an autocommand, in the options.lua
-- file, also in the markdownl.lua file, but the highlights kept being overriden
-- so the only way I was able to make it work was loading it
-- after the config.lazy in the init.lua file lamw25wmal

-- Require the colors.lua module and access the colors directly without
-- additional file reads
--local colors = require("config.colors")

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
  enabled = true,
  init = function()
    vim.keymap.set('n', '<leader>tm', ':RenderMarkdown buf_toggle<cr>', { desc = '[M]arkdown Rendering' })
  end,
  -- Moved highlight creation out of opts as suggested by plugin maintainer
  -- There was no issue, but it was creating unnecessary noise when ran
  -- :checkhealth render-markdown
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim/issues/138#issuecomment-2295422741
  -- init = function()
  -- local colorInline_bg = colors["linkarzu_color02"]
  -- local color_fg = colors["linkarzu_color26"]
  -- -- local color_sign = "#ebfafa"
  -- if vim.g.md_heading_bg == "transparent" then
  --   -- Define color variables
  --   local color1_bg = colors["linkarzu_color04"]
  --   local color2_bg = colors["linkarzu_color02"]
  --   local color3_bg = colors["linkarzu_color03"]
  --   local color4_bg = colors["linkarzu_color01"]
  --   local color5_bg = colors["linkarzu_color05"]
  --   local color6_bg = colors["linkarzu_color08"]
  --   local color_fg1 = colors["linkarzu_color18"]
  --   local color_fg2 = colors["linkarzu_color19"]
  --   local color_fg3 = colors["linkarzu_color20"]
  --   local color_fg4 = colors["linkarzu_color21"]
  --   local color_fg5 = colors["linkarzu_color22"]
  --   local color_fg6 = colors["linkarzu_color23"]
  --
  --   -- Heading colors (when not hovered over), extends through the entire line
  --   vim.cmd(string.format([[highlight Headline1Bg guibg=%s guifg=%s ]], color_fg1, color1_bg))
  --   vim.cmd(string.format([[highlight Headline2Bg guibg=%s guifg=%s ]], color_fg2, color2_bg))
  --   vim.cmd(string.format([[highlight Headline3Bg guibg=%s guifg=%s ]], color_fg3, color3_bg))
  --   vim.cmd(string.format([[highlight Headline4Bg guibg=%s guifg=%s ]], color_fg4, color4_bg))
  --   vim.cmd(string.format([[highlight Headline5Bg guibg=%s guifg=%s ]], color_fg5, color5_bg))
  --   vim.cmd(string.format([[highlight Headline6Bg guibg=%s guifg=%s ]], color_fg6, color6_bg))
  --   -- Define inline code highlight for markdown
  --   vim.cmd(string.format([[highlight RenderMarkdownCodeInline guifg=%s guibg=%s]], colorInline_bg, color_fg))
  --   -- vim.cmd(string.format([[highlight RenderMarkdownCodeInline guifg=%s]], colorInline_bg))
  --
  --   -- Highlight for the heading and sign icons (symbol on the left)
  --   -- I have the sign disabled for now, so this makes no effect
  --   vim.cmd(string.format([[highlight Headline1Fg cterm=bold gui=bold guifg=%s]], color1_bg))
  --   vim.cmd(string.format([[highlight Headline2Fg cterm=bold gui=bold guifg=%s]], color2_bg))
  --   vim.cmd(string.format([[highlight Headline3Fg cterm=bold gui=bold guifg=%s]], color3_bg))
  --   vim.cmd(string.format([[highlight Headline4Fg cterm=bold gui=bold guifg=%s]], color4_bg))
  --   vim.cmd(string.format([[highlight Headline5Fg cterm=bold gui=bold guifg=%s]], color5_bg))
  --   vim.cmd(string.format([[highlight Headline6Fg cterm=bold gui=bold guifg=%s]], color6_bg))
  -- else
  --   local color1_bg = colors["linkarzu_color18"]
  --   local color2_bg = colors["linkarzu_color19"]
  --   local color3_bg = colors["linkarzu_color20"]
  --   local color4_bg = colors["linkarzu_color21"]
  --   local color5_bg = colors["linkarzu_color22"]
  --   local color6_bg = colors["linkarzu_color23"]
  --   vim.cmd(string.format([[highlight Headline1Bg guifg=%s guibg=%s]], color_fg, color1_bg))
  --   vim.cmd(string.format([[highlight Headline2Bg guifg=%s guibg=%s]], color_fg, color2_bg))
  --   vim.cmd(string.format([[highlight Headline3Bg guifg=%s guibg=%s]], color_fg, color3_bg))
  --   vim.cmd(string.format([[highlight Headline4Bg guifg=%s guibg=%s]], color_fg, color4_bg))
  --   vim.cmd(string.format([[highlight Headline5Bg guifg=%s guibg=%s]], color_fg, color5_bg))
  --   vim.cmd(string.format([[highlight Headline6Bg guifg=%s guibg=%s]], color_fg, color6_bg))
  -- end
  --  end,

  opts = {
    --  This causes us to be rendered even in insert mode
    render_modes = true,
    bullet = {
      enabled = true,
    },
    checkbox = {
      enabled = true,
      checked = {
        scope_highlight = '@markup.strikethrough',
      },
      custom = {
        important = {
          raw = '[~]',
          rendered = '󰓎 ',
          highlight = 'DiagnosticWarn',
        },
      },
    },
    html = {
      enabled = true,
      comment = {
        conceal = false,
      },
    },
    -- Add custom icons
    link = {
      custom = {
        youtu = { pattern = 'youtu%.be', icon = '󰗃 ' },
      },
    },
    code = {
      width = 'block',
      position = 'right',
      -- dont add extra highlight for inline code
      highlight_inline = '',
    },
    sign = {
      enabled = true,
      highlight = 'RenderMarkdownSign',
    },
    heading = {
      width = 'block',
      -- border = true,
      icons = { '󰎤 ', '󰎧 ', '󰎪 ', '󰎭 ', '󰎱 ', '󰎳 ' },
      -- backgrounds = {
      --   'Headline1Bg',
      --   'Headline2Bg',
      --   'Headline3Bg',
      --   'Headline4Bg',
      --   'Headline5Bg',
      --   'Headline6Bg',
      -- },
      -- foregrounds = {
      --   'Headline1Fg',
      --   'Headline2Fg',
      --   'Headline3Fg',
      --   'Headline4Fg',
      --   'Headline5Fg',
      --   'Headline6Fg',
      -- },
    },
    -- TODO: I like it but it seems that the other indentation plugin is getting in its way... maybe disable that one on MD files??
    -- indent = {
    --   enabled = true,
    --   skip_heading = true,
    -- },
  },
}
