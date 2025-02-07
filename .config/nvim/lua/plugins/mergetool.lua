return {
  {
    'samoshkin/vim-mergetool',
    init = function()
      vim.g.mergetool_layout = 'mr'
      vim.g.mergetool_prefer = 'local'
      vim.keymap.set('n', '<leader>mt', ':MergetoolToggle<cr>', { desc = 'Merge Tool' })
      vim.keymap.set('n', '<leader>ml', ':MergetoolExchangeLeft<cr>', { desc = 'Merge to Left' })
      vim.keymap.set('n', '<leader>mr', ':MergetoolExchangeRight<cr>', { desc = 'Merge to Right' })
      vim.keymap.set('n', '<leader>mc', ':MergetoolStop<cr>', { desc = 'Merge Complete' })
    end,
  },
}
