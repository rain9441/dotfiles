local M = {
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = { 'rafamadriz/friendly-snippets', 'milanglacier/minuet-ai.nvim' },
    version = '*',
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<A-a>'] = {
          function(cmp)
            require('minuet')
            cmp.show({ providers = { 'minuet' } })
          end,
        },
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
          -- Instead of 'cancel', use cancel with exit-insert mode and also fallback (because cancel doesn't fallback normally)
          function(cmp)
            if cmp.is_active() and cmp.is_visible() then
              cmp.cancel({ callback = function() vim.cmd('stopinsert') end })
              return true
            end
          end,
          'fallback'
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
            'buffer',
            -- 'minuet',
          }
        end,
        per_filetype = {
          codecompanion = { 'codecompanion' },
        },
        providers = {
          minuet = {
            name = 'minuet',
            module = 'minuet.blink',
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000,
            score_offset = 50, -- Gives minuet higher priority among suggestions
          },
        },
      },
      completion = {
        trigger = { prefetch_on_insert = false },
        accept = { auto_brackets = { enabled = false } },
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
}

return M
