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
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'saadparwaiz1/cmp_luasnip',
      'onsails/lspkind.nvim',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup({
        enabled = function()
          -- Disable completion entirely when in context of a comment
          return not require('cmp.config.context').in_treesitter_capture('comment')
        end,
        formatting = {
          format = require('lspkind').cmp_format(),
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
    cmd = 'Trouble',
    config = function() require('trouble').setup({}) end,
  },
  {
    'Shatur/neovim-session-manager',
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
  -- {
  --   'rest-nvim/rest.nvim',
  --   event = 'VeryLazy',
  --   config = function()
  --     require('rest-nvim').setup({
  --       -- Open request results in a horizontal split
  --       result_split_horizontal = true,
  --       -- Keep the http file buffer above|left when split horizontal|vertical
  --       result_split_in_place = false,
  --       -- Skip SSL verification, useful for unknown certificates
  --       skip_ssl_verification = false,
  --       -- Encode URL before making request
  --       encode_url = true,
  --       result = {
  --         -- toggle showing URL, HTTP info, headers at top the of result window
  --         show_url = true,
  --         show_http_info = true,
  --         show_headers = true,
  --         -- executables or functions for formatting response body [optional]
  --         -- set them to false if you want to disable them
  --         formatters = {
  --           json = false,
  --           html = false,
  --         },
  --       },
  --       -- Jump to request line on run
  --       jump_to_request = false,
  --       env_file = '.env',
  --       custom_dynamic_variables = {},
  --       yank_dry_run = true,
  --     })
  --   end,
  -- },
  -- { 'jlanzarotta/bufexplorer', branch = '7.4.24' },
  -- 'nvim-neotest/neotest',
  -- 'nvim-neotest/neotest-jest',
  -- 'andythigpen/nvim-coverage',
  -- { 'neoclide/coc.nvim',       branch = 'release' },
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && npm install && git restore .',
    init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
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
      require("telescope").extensions.aerial.aerial()
    end,
  },
}

return M
