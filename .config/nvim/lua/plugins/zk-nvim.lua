return {
  {
    'zk-org/zk-nvim',
    init = function()
      local opts = { noremap = true, silent = false }

      -- Create a new note after asking for its title.
      opts.desc = '[Z]ettlekasten notes'
      vim.api.nvim_set_keymap('n', '<leader>w', '', opts)
      opts.desc = 'Create a [N]ew note'
      vim.api.nvim_set_keymap('n', '<leader>wn', "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", opts)
      opts.desc = 'Create a new [J]ournal'
      vim.api.nvim_set_keymap('n', '<leader>wj', '<Cmd>ZkNew { dir = "journal" }<CR>', opts)
      opts.desc = '[W]ork items'
      vim.api.nvim_set_keymap('n', '<leader>ww', '', opts)
      opts.desc = 'Work [J]ournal'
      vim.api.nvim_set_keymap('n', '<leader>wwj', '<Cmd>ZkNew { dir = "work/journal" }<CR>', opts)
      opts.desc = 'Work [N]ew note'
      vim.api.nvim_set_keymap(
        'n',
        '<leader>wwn',
        "<Cmd>ZkNew { dir = 'work', title = vim.fn.input('Title: ') }<CR>",
        opts
      )

      -- Open notes.
      opts.desc = '[O]pen notes'
      vim.api.nvim_set_keymap('n', '<leader>wo', "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", opts)
      opts.desc = 'Open note by [T]ags'
      -- Open notes associated with the selected tags.
      vim.api.nvim_set_keymap('n', '<leader>wt', '<Cmd>ZkTags<CR>', opts)

      opts.desc = '[I]nsert link'
      vim.api.nvim_set_keymap('n', '<leader>wi', '<Cmd>ZkInsertLink<CR>', opts)

      -- Search for the notes matching a given query.
      -- opts.desc = '[S]earch notes'
      -- vim.api.nvim_set_keymap('n', '<leader>ws', "<Cmd>ZkNotes { sort = { 'modified' }, match = vim.fn.input('Search: ') }<CR>", opts)
      -- Search for the notes matching the current visual selection.
      vim.api.nvim_set_keymap('v', '<leader>ws', ":'<,'>ZkMatch<CR>", opts)
    end,
    config = function()
      require('zk').setup({
        picker = 'telescope',
      })
    end,
  },
}
