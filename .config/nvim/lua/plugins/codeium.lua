return {
  {
    -- Was 'Exafunction/codeium.vim',
    'Exafunction/windsurf.vim',
    event = 'BufEnter',
    -- Run before the plugin loads so BufEnter does not start the language
    -- server (which echoms "No API key found" when unauthenticated).
    init = function()
      local data_dir = vim.env.XDG_DATA_HOME
      if not data_dir or data_dir == '' then
        data_dir = vim.fn.expand '~/.codeium'
      else
        data_dir = data_dir .. '/.codeium'
      end
      local config_path = data_dir .. '/config.json'

      local has_key = false
      if vim.fn.filereadable(config_path) == 1 then
        local ok, cfg = pcall(function()
          return vim.json.decode(table.concat(vim.fn.readfile(config_path), '\n'))
        end)
        has_key = ok and type(cfg) == 'table' and type(cfg.apiKey) == 'string' and cfg.apiKey ~= ''
      end

      if not has_key then
        vim.g.codeium_enabled = false
      end
    end,
    config = function()
      vim.keymap.set('n', '<leader>ta', ':CodeiumToggle<cr>', { desc = '[A]I helper', noremap = true, silent = true })
      -- vim.keymap.set('i', '<C-g>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-j>', function()
        return vim.fn['codeium#CycleCompletions'](1)
      end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-o>', function()
        return vim.fn['codeium#CycleCompletions'](-1)
      end, { expr = true, silent = true })
      vim.keymap.set('i', '<C-x>', function()
        return vim.fn['codeium#Clear']()
      end, { expr = true, silent = true })
    end,
  },
}
