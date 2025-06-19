local M = {
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerToggle', 'OverseerInfo', 'OverseerBuild', 'OverseerRun' },
    config = function()
      require('overseer').setup({
        actions = {
          ['attach'] = {
            desc = 'Attach (nvim-dap)',
            condition = function(task)
              if task.strategy and task.strategy.chan_id then
                return true
              end
              return false
            end,
            run = function(task)
              -- Nothing
              if task.strategy.chan_id then
                local pid = vim.fn.jobpid(task.strategy.chan_id)

                local adapters = {}
                for adapterName, adapter in pairs(require('dap').adapters) do
                  table.insert(adapters, { adapter = adapter, name = adapterName, pid = pid })
                end
                vim.ui.select(adapters, {
                  prompt = 'Select an Adapter',
                  format_item = function(x) return x.name end,
                }, function(adapterAndPid)
                  if adapterAndPid then
                    local customConfig = {
                      type = adapterAndPid.name,
                      request = 'attach',
                      name = string.format('Attach to %s', adapterAndPid.pid),
                      processId = adapterAndPid.pid,
                      cwd = task.cwd,
                    }
                    require('dap').run(customConfig)
                  end
                end)
              end
            end,
          },
        },
        task_list = {
          bindings = {
            ['?'] = 'ShowHelp',
            ['g?'] = 'ShowHelp',
            ['<CR>'] = 'RunAction',
            ['<C-e>'] = 'Edit',
            ['o'] = 'Open',
            ['<C-v>'] = 'OpenVsplit',
            ['<C-s>'] = 'OpenSplit',
            ['<C-f>'] = 'OpenFloat',
            ['<C-q>'] = 'OpenQuickFix',
            ['p'] = 'TogglePreview',
            ['<M-l>'] = 'IncreaseDetail',
            ['<M-h>'] = 'DecreaseDetail',
            ['L'] = 'IncreaseAllDetail',
            ['H'] = 'DecreaseAllDetail',
            ['<M-[>'] = 'DecreaseWidth',
            ['<M-]>'] = 'IncreaseWidth',
            ['{'] = 'PrevTask',
            ['}'] = 'NextTask',
            ['<M-k>'] = 'ScrollOutputUp',
            ['<M-j>'] = 'ScrollOutputDown',
            ['<C-o>'] = 'Nop',
            ['<C-S-o>'] = 'Nop',
            ['ss'] = '<CMD>OverseerQuickAction start<CR>',
            ['rs'] = '<CMD>OverseerQuickAction restart<CR>',
            ['x'] = '<CMD>OverseerQuickAction stop<CR>',
            ['dd'] = '<CMD>OverseerQuickAction dispose<CR>',
            ['a'] = '<CMD>OverseerQuickAction attach<CR>',
          },
        },
        task_launcher = {
          bindings = {
            n = {
              ['<ESC>'] = 'Cancel',
            },
          },
        },
        task_editor = {
          -- Set keymap to false to remove default behavior
          -- You can add custom keymaps here as well (anything vim.keymap.set accepts)
          bindings = {
            n = {
              ['<ESC>'] = 'Cancel',
            },
          },
        },
      })
      vim.cmd('augroup OverseerNlbl | autocmd FileType OverseerList set nobl | augroup END')
    end,
  },
}

return M
