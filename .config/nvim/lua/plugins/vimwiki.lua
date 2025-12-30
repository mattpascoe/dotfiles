return {
  {
    enabled = false,
    'vimwiki/vimwiki',
    init = function()
      vim.g.vimwiki_list = {
        {
          -- personal
          path = '~/data/SYNC/wiki/',
          syntax = 'markdown',
          ext = '.md',
        },
        {
          -- work
          path = '~/data/workwiki/',
          syntax = 'markdown',
          ext = '.md',
        },
      }

      vim.g.vimwiki_listsyms = ' ○◐●✓'
      vim.g.vimwiki_global_ext = 0
      vim.g.vimwiki_key_mappings = { table_mappings = 0 }
    end,
    config = function()
      -- vim.keymap.set(
      --   'n',
      --   '<leader>tl',
      --   ':VimwikiToggleListItem<cr>',
      --   { desc = 'Vimwiki [L]istitem', noremap = true, silent = true }
      -- )
    end,
  },
}
