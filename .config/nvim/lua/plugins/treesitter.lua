return {
  {
    -- Neovim 0.12+ requires the rewrite on `main` (master is frozen at 0.11).
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require('nvim-treesitter')

      -- Default install_dir is stdpath('data')/site — fine for most setups.
      ts.setup {}

      -- Parsers used across this config / daily editing.
      -- Bundled with nvim 0.12 already: c, lua, markdown, markdown_inline, query, vim, vimdoc.
      -- Still listed so :TSUpdate keeps them current when desired.
      local ensure_installed = {
        'bash',
        'c',
        'css',
        'csv',
        'diff',
        'dockerfile',
        'git_config',
        'gitcommit',
        'gitignore',
        'html',
        'javascript',
        'json',
        'lua',
        'make',
        'markdown',
        'markdown_inline',
        'php',
        'python',
        'query',
        'ruby',
        'sql',
        'toml',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      }
      ts.install(ensure_installed)

      -- Enable treesitter features per buffer (highlighting is not automatic on main).
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          if not pcall(vim.treesitter.start) then
            return
          end
          -- Markdown folding is overridden separately in init.lua.
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
    event = 'BufReadPost',
    config = function()
      require('treesitter-context').setup {
        enable = true,
        max_lines = 3,
        trim_scope = 'inner',
        min_window_height = 10,
        mode = 'cursor',
      }
      vim.keymap.set('n', '<leader>tx', ':TSContext toggle<CR>', { desc = 'Treesitter Conte[x]t', noremap = true })
    end,
  },
}
