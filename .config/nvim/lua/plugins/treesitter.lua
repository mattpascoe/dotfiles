return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    -- `main` is a full rewrite (Nvim 0.12+). `master` is frozen for 0.11.
    branch = 'main',
    lazy = false, -- this plugin does not support lazy-loading
    build = ':TSUpdate',
    -- mason.setup() prepends mason/bin to PATH so `tree-sitter` is found
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      -- Optional: only needed to change the parser install directory.
      -- require('nvim-treesitter').setup { install_dir = vim.fn.stdpath('data') .. '/site' }

      -- Baseline parsers (same set as the old ensure_installed).
      -- markdown_inline is an injection parser, not a filetype, so keep it here.
      local ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      }

      local function has_tree_sitter_cli()
        return vim.fn.executable('tree-sitter') == 1
      end

      -- Compiling parsers needs tree-sitter-cli (installed via Mason).
      -- On first launch Mason may still be downloading it, so wait.
      local function install_parsers()
        if not has_tree_sitter_cli() then
          return false
        end
        require('nvim-treesitter').install(ensure_installed)
        return true
      end

      if not install_parsers() then
        vim.api.nvim_create_autocmd('User', {
          pattern = 'MasonToolsUpdateCompleted',
          callback = function()
            vim.schedule(install_parsers)
          end,
        })
      end

      -- Highlighting / indent are no longer enabled by nvim-treesitter itself.
      -- Attach Neovim's treesitter features when a parser is available.
      ---@param buf integer
      ---@param language string
      local function treesitter_attach(buf, language)
        if not vim.treesitter.language.add(language) then
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        vim.treesitter.start(buf, language)

        --        -- Old additional_vim_regex_highlighting = { 'ruby' }
        --        -- vim.treesitter.start() disables regex syntax; turn it back on for Ruby.
        --        if language == 'ruby' then
        --          vim.bo[buf].syntax = 'on'
        --        end
        --
        --        -- Old indent = { enable = true, disable = { 'ruby' } }
        --        if language ~= 'ruby' and vim.treesitter.query.get(language, 'indents') ~= nil then
        --          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        --        end
      end

      -- Auto-install missing parsers on FileType (replaces auto_install = true).
      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-attach', { clear = true }),
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end

          local installed = require('nvim-treesitter').get_installed('parsers')
          if vim.tbl_contains(installed, language) then
            treesitter_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            if not has_tree_sitter_cli() then
              return
            end
            require('nvim-treesitter').install(language):await(function()
              treesitter_attach(buf, language)
            end)
          else
            treesitter_attach(buf, language)
          end
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection is now built into Neovim: see `:help vim.treesitter.incrementalselection`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects (also has a `main` branch)
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
