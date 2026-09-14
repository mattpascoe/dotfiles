return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    --    build = ':TSUpdate',
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if not pcall(vim.treesitter.start) then
            return
          end
          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = 'BufReadPost', -- Load when a file is opened
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable the plugin
        max_lines = 3, -- Maximum lines of context to show
        trim_scope = 'inner', -- Show only the innermost scope
        min_window_height = 10, -- Disable if window is smaller than this
        mode = 'cursor', -- "cursor" keeps the function at the top
        -- separator = '─', -- Adds a separator line
      }
      vim.keymap.set('n', '<leader>tx', ':TSContext toggle<CR>', { desc = 'Treesitter Conte[x]t', noremap = true })
    end,
  },
}
