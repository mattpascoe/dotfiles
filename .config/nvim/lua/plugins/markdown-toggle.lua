return {
  {
    'roodolv/markdown-toggle.nvim',
    config = function()
      require('markdown-toggle').setup({
        -- for some reason I cant get this towork.. its not vimwiki plugin
        enable_autolist = true,
      })

      vim.api.nvim_create_autocmd('FileType', {
        desc = 'markdown-toggle.nvim keymaps',
        pattern = { 'markdown', 'markdown.mdx' },
        callback = function(args)
          local opts = { silent = true, noremap = true, buffer = args.buf }
          local toggle = require('markdown-toggle')

          -- Helper function to set keymaps with a description
          local function map_key(mode, key, action, desc)
            opts.desc = desc
            vim.keymap.set(mode, key, action, opts)
          end

          -- Define keymaps with descriptions using the helper function
          opts.expr = true -- required for dot-repeat in Normal mode
          map_key('n', '<Leader>tq', toggle.quote_dot, 'Markdown [Q]uote')
          map_key('n', '<Leader>td', toggle.list_dot, 'Markdown List')
          map_key('n', '<Leader>tD', toggle.list_cycle_dot, 'Markdown List Cycle')
          map_key('n', '<Leader>to', toggle.olist_dot, 'Markdown [O]rdered List')
          map_key('n', '<Leader>tl', toggle.checkbox_dot, 'Markdown Checkbox')
          map_key('n', '<Leader>tL', toggle.checkbox_cycle_dot, 'Markdown Checkbox Cycle')
          map_key('n', '<Leader>th', toggle.heading_dot, 'Markdown [H]eading')

          -- opts.expr = false -- required for Visual mode
          -- vim.keymap.set('x', '<Leader>tq', toggle.quote, opts)
          -- vim.keymap.set('x', '<Leader>td', toggle.list, opts)
          -- vim.keymap.set('x', '<Leader>tD', toggle.list_cycle, opts)
          -- vim.keymap.set('x', '<Leader>to', toggle.olist, opts)
          -- vim.keymap.set('x', '<Leader>tl', toggle.checkbox, opts)
          -- vim.keymap.set('x', '<Leader>tL', toggle.checkbox_cycle, opts)
          -- vim.keymap.set('x', '<Leader>th', toggle.heading, opts)
        end,
      })
    end,
  },
}
