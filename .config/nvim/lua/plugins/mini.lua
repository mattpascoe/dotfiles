return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Mini-files
      require('mini.files').setup {
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 80,
        },
        mappings = {
          close = '<Esc>',
          go_out = 'H',
          go_out_plus = 'h',
        },
      }
      vim.keymap.set('n', '<leader>tf', ':lua MiniFiles.open()<CR>', { desc = '[F]ile browser', noremap = true })

      local tabline = require 'mini.tabline'
      tabline.setup {
        -- Set the background color all the way across
        vim.cmd([[highlight MiniTablineFill guibg=#181825]]),
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        -- Get the current cursor position percentage
        local current_line = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)
        local percentage = string.format(' [%d%%%%] ', math.floor((current_line / total_lines) * 100))
        -- Get the last modified time of the current file
        local file = vim.fn.expand('%')
        local lastm = file ~= '' and vim.fn.getftime(file) or -1
        local last_mtime = (file ~= '' and lastm ~= -1) and os.date('%y-%m-%d %H:%M', lastm) or ''

        -- Return the status line with a percentage
        return ''
          .. last_mtime -- last modified time
          .. percentage -- percentage of the current line
          .. '%2l:%-2v' -- line:column
          .. "%{codeium#GetStatusString() ==# ' ON' ? ' ' : ''}" -- AI (codeium) status
          .. "%{&paste ? ' ρ' : ''}" -- PASTE status
          .. "%{&spell ? ' Ꞩ' : ''}" -- SPELL status
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
