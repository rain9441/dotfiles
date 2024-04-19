local M = {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'nvim-neotest/nvim-nio' },
      {
        'mxsdev/nvim-dap-vscode-js',
        config = function()
          require('dap-vscode-js').setup({
            debugger_path = 'c:/projects/vscode-js-debug', -- Path to vscode-js-debug installation.
            adapters = { 'pwa-node' },
          })
          require('dap.ext.vscode').type_to_filetypes = { ['pwa-node'] = { 'javascript', 'typescript' } }
          require('dap.ext.vscode').json_decode = require('overseer.json').decode
        end,
      },
    },
    config = function()
      for _, language in ipairs({ 'typescript', 'javascript' }) do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Auto Attach',
            cwd = vim.fn.getcwd(),
            protocol = 'inspector',
          },
        }
      end
      vim.cmd('augroup Dap | autocmd FileType dap-repl set nobl | augroup END')
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      {
        'nvim-telescope/telescope-dap.nvim',
        config = function() require('telescope').load_extension('dap') end,
      },
    },
    config = function()
      require('dapui').setup({
        force_buffers = true,
        layouts = {
          {
            elements = {
              {
                id = 'console',
                size = 0.90,
              },
              {
                id = 'repl',
                size = 0.10,
              },
            },
            position = 'bottom',
            size = 10,
          },
          {
            elements = {
              {
                id = 'breakpoints',
                size = 0.10,
              },
              {
                id = 'scopes',
                size = 0.50,
              },
              {
                id = 'stacks',
                size = 0.30,
              },
              {
                id = 'watches',
                size = 0.10,
              },
            },
            position = 'left',
            size = 0.20,
          },
        },
      })
      vim.cmd('augroup DapUI | autocmd FileType dapui-console set nobl | augroup END')
    end,
  },
  {
    'Weissle/persistent-breakpoints.nvim',
    event = 'BufReadPre',
    config = function() require('persistent-breakpoints').setup({ load_breakpoints_event = { 'BufReadPost' } }) end,
  },
}

return M
