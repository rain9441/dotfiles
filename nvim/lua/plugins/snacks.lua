local M = {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      animate = { enabled = false },
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      indent = {
        enabled = false,
        only_scope = true,
        only_current = true,
        animate = {
          enabled = false,
        },
        scope = {
          underline = true,
        },
      },
      input = { enabled = true },
      picker = {
        enabled = true,
        actions = {
          git_log_delete_force = function(picker, item)
            if not (item and item.branch) then
              Snacks.notify.warn('No branch or commit found', { title = 'Snacks Picker' })
            end

            local branch = item.branch
            Snacks.picker.util.cmd({ 'git', 'rev-parse', '--abbrev-ref', 'HEAD' }, function(data)
              -- Check if we are on the same branch
              if data[1]:match(branch) ~= nil then
                Snacks.notify.error('Cannot delete the current branch.', { title = 'Snacks Picker' })
                return
              end

              Snacks.picker.select(
                { 'Yes', 'No', 'Force' },
                { prompt = ('Delete branch %q?'):format(branch) },
                function(_, idx)
                  if idx == 1 then
                    -- Proceed with deletion
                    Snacks.picker.util.cmd({ 'git', 'branch', '-d', branch }, function()
                      Snacks.notify('Deleted Branch `' .. branch .. '`', { title = 'Snacks Picker' })
                      vim.cmd.checktime()
                      picker.list:set_selected()
                      picker.list:set_target()
                      picker:find()
                    end, { cwd = picker:cwd() })
                  end
                  if idx == 3 then
                    -- Proceed with deletion
                    Snacks.picker.util.cmd({ 'git', 'branch', '-D', branch }, function()
                      Snacks.notify('Force Deleted Branch `' .. branch .. '`', { title = 'Snacks Picker' })
                      vim.cmd.checktime()
                      picker.list:set_selected()
                      picker.list:set_target()
                      picker:find()
                    end, { cwd = picker:cwd() })
                  end
                end
              )
            end, { cwd = picker:cwd() })
          end,

        },
        win = {
          preview = {
            wo = {
              relativenumber = false,
            },
          },
          list = {
            keys = {
              -- ["/"] = false,
              ["<Esc>"] = false,
              ["0G"] = "list_bottom",
              ["1G"] = "list_top",
            },
          },
          input = {
            keys = {
              -- ["/"] = false,
              ['<Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<C-Tab>'] = { 'list_down', mode = { 'i', 'n' } },
              ['<S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
              ['<C-S-Tab>'] = { 'list_up', mode = { 'i', 'n' } },
            },
          },
        },
        sources = {
          explorer = {
            layout = {
              preset = "sidebar",
              layout = {
                position = "right",
                preview = false,
                width = 50,
                min_width = 50,
              },
              cycle = false,
            },
            follow_file = false,
            watch = false,
          },
          buffers = {
            formatters = { file = { filename_only = true } },
            layout = 'vscode',
            show_empty = true,
            current = false,
          },
          recent = {
            formatters = { file = { filename_only = true } },
            layout = 'vscode',
            show_empty = true,
          },
          files = {
            cmd = 'rg',
            formatters = { file = { truncate = 160 } },
            layout = { preset = 'bottom', preview = false },
            on_show = function()
              vim.api.nvim_command('cclose')
            end,
          },
          grep = {
            formatters = { file = { truncate = 160 } },
            layout = { preset = 'bottom', preview = false },
            on_show = function()
              vim.api.nvim_command('cclose')
            end,
          },
          git_branches = {
            format = function(item, picker)
              local a = Snacks.picker.util.align
              local ret = {}
              if item.current then
                ret[#ret + 1] = { a('', 2), 'SnacksPickerGitBranchCurrent' }
              else
                ret[#ret + 1] = { a('', 2) }
              end
              if item.detached then
                ret[#ret + 1] = { a('(detached HEAD)', 60, { truncate = true }), 'SnacksPickerGitDetached' }
              else
                ret[#ret + 1] = { a(item.branch, 60, { truncate = true }), 'SnacksPickerGitBranch' }
              end
              ret[#ret + 1] = { ' ' }
              local offset = Snacks.picker.highlight.offset(ret)
              local log = Snacks.picker.format.git_log(item, picker)
              Snacks.picker.highlight.fix_offset(log, offset)
              vim.list_extend(ret, log)
              return ret
            end,
            layout = { preview = false },
            win = {
              list = {
                keys = {
                  ['<c-x>'] = { 'git_log_delete_force', mode = { 'n', 'i' } },
                }
              },
              input = {
                keys = {
                  ['<c-x>'] = { 'git_log_delete_force', mode = { 'n', 'i' } },
                },
              },
            },
          },
        },
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = {
        enabled = true,
        debounce = 0,
      },
    },
  },
}

return M
