local M = {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      { 'nvim-neotest/nvim-nio' }
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
        }
      end
      vim.cmd('augroup Dap | autocmd FileType dap-repl set nobl | augroup END')
    end,
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    event = 'VeryLazy',
    config = function()
      require('dap-vscode-js').setup({
        debugger_path = 'c:/projects/vscode-js-debug', -- Path to vscode-js-debug installation.
        adapters = { 'pwa-node' },
      })
      require('dap.ext.vscode').type_to_filetypes = { ['pwa-node'] = { 'javascript', 'typescript' } }
      require('dap.ext.vscode').json_decode = require('overseer.json').decode
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
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
    'nvim-telescope/telescope-dap.nvim',
    event = 'VeryLazy',
    requires = { 'nvim-telescope/telescope.nvim' },
    config = function() require('telescope').load_extension('dap') end,
  },
  {
    'Weissle/persistent-breakpoints.nvim',
    config = function() require('persistent-breakpoints').setup({ load_breakpoints_event = { 'BufReadPost' } }) end,
  },
}

return M
