return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- Ensure common parsers used by markdown code fences / injections.
      require('nvim-treesitter').install {
        'markdown',
        'markdown_inline',
      }

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          if not pcall(vim.treesitter.start) then
            return
          end

          -- Markdown uses a custom heading-only foldexpr in init.lua.
          -- Treesitter folds fenced_code_block nodes, which with foldlevel=1 and
          -- foldtext='' makes untyped code blocks appear as blank lines
          -- (opening ``` is conceal_lines'd by render-markdown border='hide').
          local ft = ev.match
          if ft ~= 'markdown' then
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          end

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
