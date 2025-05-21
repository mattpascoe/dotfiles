return {
  -- Setup a debugger
  -- TODO: this stuff is not yet fully working. more to do with dap and php
  --
  --{ 'rcarriga/nvim-dap-ui', dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' } },
  {
    --'rcarriga/nvim-dap-ui',
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
        args = { '/Users/mpascoe/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js' },
      }

      dap.configurations.php = {
        {
          type = 'php',
          request = 'launch',
          name = 'Listen for Xdebug',
          hostname = '127.0.0.1',
          pathMappings = {
            ['/opt/trader'] = '/Users/mpascoe/data/workrepos/xdt6000',
          },
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
