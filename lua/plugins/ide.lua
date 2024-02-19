local M = {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    },
    event = 'VeryLazy',
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup({
        formatting = {
          format = lspkind.cmp_format(),
        },
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        window = {
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered()
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              end
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'nvim_lua' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'cmdline' },
        }, {
          { name = 'buffer' },
        }),
      })

      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        }),
      })

      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })
    end,
  },
  {
    'folke/trouble.nvim',
    event = 'VeryLazy',
    config = function() require('trouble').setup({}) end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    event = 'VeryLazy',
    config = function()
      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        local nvimTreeMappings = {
          -- BEGIN_DEFAULT_ON_ATTACH
          ['<C-]>'] = { api.tree.change_root_to_node, 'CD' },
          --['<C-e>'] = { api.node.open.replace_tree_buffer, 'Open: In Place' },
          ['<C-k>'] = { api.node.show_info_popup, 'Info' },
          ['<C-r>'] = { api.fs.rename_sub, 'Rename: Omit Filename' },
          ['<C-t>'] = { api.node.open.tab, 'Open: New Tab' },
          ['<C-v>'] = { api.node.open.vertical, 'Open: Vertical Split' },
          ['<C-x>'] = { api.node.open.horizontal, 'Open: Horizontal Split' },
          ['<BS>'] = { api.node.navigate.parent_close, 'Close Directory' },
          -- ['<CR>'] = { api.node.open.edit, 'Open' },
          ['<Tab>'] = { api.node.open.preview, 'Open Preview' },
          ['>'] = { api.node.navigate.sibling.next, 'Next Sibling' },
          ['<'] = { api.node.navigate.sibling.prev, 'Previous Sibling' },
          ['.'] = { api.node.run.cmd, 'Run Command' },
          ['-'] = { api.tree.change_root_to_parent, 'Up' },
          ['a'] = { api.fs.create, 'Create' },
          ['bmv'] = { api.marks.bulk.move, 'Move Bookmarked' },
          ['B'] = { api.tree.toggle_no_buffer_filter, 'Toggle No Buffer' },
          ['c'] = { api.fs.copy.node, 'Copy' },
          --['C'] = { api.tree.toggle_git_clean_filter, 'Toggle Git Clean' },
          ['[c'] = { api.node.navigate.git.prev, 'Prev Git' },
          [']c'] = { api.node.navigate.git.next, 'Next Git' },
          ['d'] = { api.fs.remove, 'Delete' },
          ['D'] = { api.fs.trash, 'Trash' },
          ['E'] = { api.tree.expand_all, 'Expand All' },
          ['e'] = { api.fs.rename_basename, 'Rename: Basename' },
          [']e'] = { api.node.navigate.diagnostics.next, 'Next Diagnostic' },
          ['[e'] = { api.node.navigate.diagnostics.prev, 'Prev Diagnostic' },
          ['F'] = { api.live_filter.clear, 'Clean Filter' },
          ['f'] = { api.live_filter.start, 'Filter' },
          ['?'] = { api.tree.toggle_help, 'Help' },
          ['gy'] = { api.fs.copy.absolute_path, 'Copy Absolute Path' },
          ['I'] = { api.tree.toggle_hidden_filter, 'Toggle Dotfiles' },
          ['O'] = { api.tree.toggle_gitignore_filter, 'Toggle Git Ignore' },
          ['J'] = { api.node.navigate.sibling.last, 'Last Sibling' },
          ['K'] = { api.node.navigate.sibling.first, 'First Sibling' },
          ['m'] = { api.marks.toggle, 'Toggle Bookmark' },
          ['o'] = { api.node.open.edit, 'Open' },
          --['O'] = { api.node.open.no_window_picker, 'Open: No Window Picker' },
          ['p'] = { api.fs.paste, 'Paste' },
          ['P'] = { api.node.navigate.parent, 'Parent Directory' },
          ['q'] = { api.tree.close, 'Close' },
          ['r'] = { api.fs.rename, 'Rename' },
          ['R'] = { api.tree.reload, 'Refresh' },
          ['s'] = { api.node.run.system, 'Run System' },
          ['S'] = { api.tree.search_node, 'Search' },
          ['U'] = { api.tree.toggle_custom_filter, 'Toggle Hidden' },
          ['W'] = { api.tree.collapse_all, 'Collapse' },
          ['x'] = { api.fs.cut, 'Cut' },
          ['y'] = { api.fs.copy.filename, 'Copy Name' },
          ['Y'] = { api.fs.copy.relative_path, 'Copy Relative Path' },
          ['<2-LeftMouse>'] = { api.node.open.edit, 'Open' },
          ['<2-RightMouse>'] = { api.tree.change_root_to_node, 'CD' },
          -- END_DEFAULT_ON_ATTACH

          -- Mappings migrated from view.mappings.list
          --['l'] = { api.node.open.edit, 'Open' },
          ['<CR>'] = { api.node.open.edit, 'Open' },
          --['h'] = { api.node.navigate.parent_close, 'Close Directory' },
          ['v'] = { api.node.open.vertical, 'Open: Vertical Split' },
          ['C'] = { api.tree.change_root_to_node, 'CD' },
          ['<C-o>'] = { function() end, 'Nop' },
          ['<C-S-O>'] = { function() end, 'Nop' },
        }

        for keys, mapping in pairs(nvimTreeMappings) do
          vim.keymap.set('n', keys, mapping[1], opts(mapping[2]))
        end
      end

      require('nvim-tree').setup({
        on_attach = on_attach,
        update_focused_file = { update_cwd = false },
        git = { timeout = 8000 },
        hijack_cursor = true,
        sort_by = 'case_sensitive',
        view = { width = 54, side = 'right' },
        renderer = {
          special_files = {},
          indent_width = 3,
          highlight_git = true,
          indent_markers = { enable = true },
          icons = { show = { folder_arrow = false, git = false } },
        },
        filters = {
          dotfiles = false,
          custom = {
            '.eslintrc.json',
            'README.md',
            'jest.config.ts',
            'package.json',
            'project.json',
            'tsconfig.*.json',
            'webpack.config.js',
          },
        },
        actions = {
          change_dir = { global = true, restrict_above_cwd = false },
          open_file = {
            window_picker = {
              exclude = {
                filetype = {
                  'notify',
                  'packer',
                  'qf',
                  'diff',
                  'fugitive',
                  'fugitiveblame',
                  'dapui_console',
                  'dapui_watches',
                  'dap-repl',
                },
              },
            },
          },
          remove_file = {
            close_window = false,
          },
        },
        live_filter = { always_show_folders = false },
      })
    end,
  },
  {
    'Shatur/neovim-session-manager',
    event = 'VeryLazy',
    config = function()
      require('session_manager').setup({
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
        -- autosave_last_session = false,
        autosave_only_in_session = true,
        autosave_ignore_buftypes = { 'nofile' },
      })
    end,
  },
  {
    'stevearc/overseer.nvim',
    event = 'VeryLazy',
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
  {
    'rest-nvim/rest.nvim',
    event = 'VeryLazy',
    config = function()
      require('rest-nvim').setup({
        -- Open request results in a horizontal split
        result_split_horizontal = true,
        -- Keep the http file buffer above|left when split horizontal|vertical
        result_split_in_place = false,
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = false,
        -- Encode URL before making request
        encode_url = true,
        result = {
          -- toggle showing URL, HTTP info, headers at top the of result window
          show_url = true,
          show_http_info = true,
          show_headers = true,
          -- executables or functions for formatting response body [optional]
          -- set them to false if you want to disable them
          formatters = {
            json = false,
            html = false,
          },
        },
        -- Jump to request line on run
        jump_to_request = false,
        env_file = '.env',
        custom_dynamic_variables = {},
        yank_dry_run = true,
      })
    end,
  },
  -- { 'jlanzarotta/bufexplorer', branch = '7.4.24' },
  -- 'nvim-neotest/neotest',
  -- 'nvim-neotest/neotest-jest',
  -- 'andythigpen/nvim-coverage',
  -- { 'neoclide/coc.nvim',       branch = 'release' },
}

return M
