return {
  {
    'zk-org/zk-nvim',
    init = function()
      local opts = { noremap = true, silent = false }

      -- Create a new note after asking for its title.
      opts.desc = '[Z]ettlekasten notes'
      vim.api.nvim_set_keymap('n', '<leader>j', '', opts)
      opts.desc = 'Create a [N]ew note'
      vim.api.nvim_set_keymap('n', '<leader>jn', "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", opts)
      opts.desc = 'Create a new [J]ournal'
      vim.api.nvim_set_keymap('n', '<leader>jj', '<Cmd>ZkNew { dir = "journal" }<CR>', opts)
      opts.desc = '[W]ork items'
      vim.api.nvim_set_keymap('n', '<leader>jw', '', opts)
      opts.desc = 'Work [J]ournal'
      vim.api.nvim_set_keymap('n', '<leader>jwj', '<Cmd>ZkNew { dir = "work/journal" }<CR>', opts)
      opts.desc = 'Work [N]ew note'
      vim.api.nvim_set_keymap(
        'n',
        '<leader>jwn',
        "<Cmd>ZkNew { dir = 'work', title = vim.fn.input('Title: ') }<CR>",
        opts
      )

      -- Open notes.
      opts.desc = '[O]pen notes'
      vim.api.nvim_set_keymap('n', '<leader>jo', "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
      opts.desc = 'Open note by [T]ags'
      -- Open notes associated with the selected tags.
      vim.api.nvim_set_keymap('n', '<leader>jt', '<Cmd>ZkTags<CR>', opts)

      opts.desc = '[I]nsert link'
      vim.api.nvim_set_keymap('n', '<leader>ji', '<Cmd>ZkInsertLink<CR>', opts)

      -- Search for the notes matching a given query.
      -- opts.desc = '[S]earch notes'
      -- vim.api.nvim_set_keymap('n', '<leader>js', "<Cmd>ZkNotes { sort = { 'modified' }, match = vim.fn.input('Search: ') }<CR>", opts)
      -- Search for the notes matching the current visual selection.
      vim.api.nvim_set_keymap('v', '<leader>js', ":'<,'>ZkMatch<CR>", opts)
    end,
    config = function()
      require('zk').setup({
        picker = 'telescope',
      })
    end,
  },
}
