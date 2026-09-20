--- nvim-treesitter `main` always compiles parsers from source (no prebuilt
--- binaries). Skip auto-install on hosts without a C compiler / tree-sitter CLI
--- so startup stays quiet; Neovim 0.12 still ships c/lua/markdown*/query/vim/vimdoc.
local function has_c_compiler()
  for _, c in ipairs { 'cc', 'gcc', 'clang', 'cl', 'zig' } do
    if vim.fn.executable(c) == 1 then
      return true
    end
  end
  return false
end

local function has_tree_sitter_cli()
  if vim.fn.executable('tree-sitter') == 1 then
    return true
  end
  -- treesitter loads lazy=false; Mason may not have put its bin on PATH yet.
  local mason_cli = vim.fs.joinpath(vim.fn.stdpath('data'), 'mason', 'bin', 'tree-sitter')
  return vim.uv.fs_stat(mason_cli) ~= nil
end

local function has_parser_build_tools()
  return has_c_compiler() and has_tree_sitter_cli()
end

local function install_parsers()
  if not has_parser_build_tools() then
    return
  end

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
  require('nvim-treesitter').install(ensure_installed)
end

return {
  {
    -- Neovim 0.12+ requires the rewrite on `main` (master is frozen at 0.11).
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = function()
      -- Lazy runs this after clone/update; only compile when tools exist.
      install_parsers()
    end,
    config = function()
      local ts = require('nvim-treesitter')

      -- Default install_dir is stdpath('data')/site — fine for most setups.
      ts.setup {}

      -- Best-effort async install when a compiler is available. No-op (and no
      -- error spam) on locked-down hosts without cc/tree-sitter.
      install_parsers()

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
