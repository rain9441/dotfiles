local M = {
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip').setup({
        update_events = { 'TextChanged', 'TextChangedI' },
        enable_autosnippets = true,
      })

      require('luasnip.loaders.from_vscode').load()
      require('luasnip.loaders.from_snipmate').load()
    end,
  },
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    config = function() require('trouble').setup({}) end,
  },
  {
    'Shatur/neovim-session-manager',
    dependencies = { 'nvim-lua/plenary.nvim' },
    lazy = false,
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
  {
    'chrisgrieser/nvim-puppeteer',
    ft = { 'javascript', 'typescript', 'js', 'ts' },
    init = function() vim.g.puppeteer_js_quotation_mark = "'" end,
  },
  {
    'folke/todo-comments.nvim',
    cmd = { 'TodoQuickFix', 'TodoTelescope', 'TodoTrouble', 'TodoLocList' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('todo-comments').setup() end,
  },
  {
    'LudoPinelli/comment-box.nvim',
    event = 'VeryLazy',
    config = function()
      require('comment-box').setup({
        comment_style = 'line',
        doc_width = 120, -- width of the document
        box_width = 100, -- width of the boxes
        line_width = 96, -- width of the lines
      })
    end,
  },
  {
    'stevearc/aerial.nvim',
    cmd = 'AerialToggle',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({})
      require('telescope').extensions.aerial.aerial()
    end,
  },
  {
    'tpope/vim-dadbod',
    cmd = { 'DB' },
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    dependencies = {
      { 'tpope/vim-dadbod' },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_use_nvim_notify = 1
      vim.g.db_ui_hide_schemas = { 'pg_catalog', 'pg_toast', 'information_schema' }
      vim.cmd(
        "autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })"
      )
      vim.cmd('augroup DBUI | autocmd FileType dbui set nobl | augroup END')
    end,
  },
  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    event = { 'VeryLazy' },
    config = function() require('multicursor-nvim').setup() end,
  },
  {
    'Eandrju/cellular-automaton.nvim',
    event = { 'VeryLazy' },
    cmd = { 'CellularAutomaton' },
  },
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '*',
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_next()
            end
          end,
          'snippet_forward',
          'fallback',
        },
        ['<S-Tab>'] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_backward()
            else
              return cmp.select_prev()
            end
          end,
          'snippet_backward',
          'fallback',
        },
        ['<Esc>'] = {
          function(cmp)
            cmp.cancel()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
          end,
          'fallback',
        },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = function(ctx)
          -- Disable in treesitter capture 'Comment' -- pulled from nvim-cmp source
          local buf = vim.api.nvim_get_current_buf()
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          row = row - 1
          if vim.api.nvim_get_mode().mode == 'i' then
            col = col - 1
          end

          local captures_at_cursor = vim.tbl_map(
            function(x) return x.capture end,
            require('vim.treesitter').get_captures_at_pos(buf, row, col)
          )

          if vim.tbl_contains(captures_at_cursor, 'comment') then
            return {}
          end

          return {
            'lsp',
            'path',
            'snippets',
            'buffer',
          }
        end,
        per_filetype = {
          codecompanion = { 'codecompanion' },
        },
      },
      completion = {
        list = {
          selection = {
            preselect = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 0,
          window = {
            border = 'padded',
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown', 'codecompanion' },
  },
}

return M
