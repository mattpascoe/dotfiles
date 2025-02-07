return {
  -- Preview markdown live in web browser
  -- NOTE: had to do a ':Lazy build markdown-preview.nvim' the first time
  {
    'iamcco/markdown-preview.nvim',
    cond = function()
      return not vim.g.has_unraid -- not yet tested, should not install on unraid
    end,
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    ft = { 'markdown' },
    init = function()
      vim.keymap.set('n', '<leader>tm', ':MarkdownPreviewToggle<cr>', { desc = '[M]arkdown Preview' })
      vim.g.mkdp_filetypes = { 'markdown' }
      vim.g.mkdp_browser = { 'safari' }
      vim.g.mkdp_combine_preview = 1
    end,
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  },
}
