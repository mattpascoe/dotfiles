return {
  -- Setup a debugger
  {
    'mfussenegger/nvim-dap',
    dependencies = { 'rcarriga/nvim-dap-ui', 'nvim-neotest/nvim-nio' },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'
      require('dapui').setup()
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      dap.adapters.php = {
        type = 'executable',
        command = 'node',
        args = { vim.fn.expand('~/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js') },
      }

      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug',
          hostname = '127.0.0.1',
          -- pathMappings = {
          --   ['/opt/trader'] = vim.fn.expand('~/data/workrepos/xdt6000'),
          -- },
          port = 9009,
        },
      }

      --require 'nvim-dap-virtual-text'
      vim.fn.sign_define(
        'DapBreakpoint',
        { text = '󰀩', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' }
      )

      -- Debugger
      vim.keymap.set('n', '<leader>dt', dapui.toggle, { desc = 'Debugger UI [T]oggle', noremap = true })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debugger [B]reakpoint', noremap = true })
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debugger [C]ontinue', noremap = true })
      vim.keymap.set('n', '<leader>dn', ':DapNew<CR>', { desc = 'Debugger [S]tart', noremap = true })
      vim.keymap.set('n', '<leader>dd', dap.disconnect, { desc = 'Debugger [D]isconnect', noremap = true })
      vim.keymap.set(
        'n',
        '<leader>dr',
        ":lua require('dapui').open({reset = true})<CR>",
        { desc = 'Debugger [R]eset', noremap = true }
      )
      --vim.keymap.set("n", "<leader>ht", ":lua require('harpoon.ui').toggle_quick_menu()<CR>", {noremap=true})
    end,
  },
  'theHamsta/nvim-dap-virtual-text',
  --'leoluz/nvim-dap-go',
}
