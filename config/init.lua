---@diagnostic disable: undefined-global
--
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Core libraries
  { 'nvim-lua/plenary.nvim',       lazy = false },

  -- UI stuff
  {
    'Mofiqul/dracula.nvim',
    lazy = true,
    config = function()
      local colors = {
        bg = '#101116',
        fg = '#F8F8F2',
        fgdark = '#D8D8D2',
        cursorline = '#303137',
        selection = '#44475A',
        comment = '#6272A4',
        red = '#FF5555',
        orange = '#FFB86C',
        yellow = '#F1FA8C',
        green = '#50fa7b',
        purple = '#BD93F9',
        cyan = '#8BE9FD',
        pink = '#FF79C6',
        bright_red = '#FF6E6E',
        bright_green = '#69FF94',
        bright_yellow = '#FFFFA5',
        bright_blue = '#D6ACFF',
        bright_magenta = '#FF92DF',
        bright_cyan = '#A4FFFF',
        bright_white = '#FFFFFF',
        menu = '#21222C',
        visual = '#3E4452',
        gutter_fg = '#4B5263',
        nontext = '#3B4048',
      };

      require('dracula').setup({
        colors = colors,
        overrides = {
          CursorLine = { bg = colors.cursorline },
          VertSplit = { fg = '#808080' },

          ['@variable.builtin'] = { fg = colors.orange },
          ['@property'] = { fg = colors.fgdark },

          NvimTreeRootFolder = { fg = colors.bg, bg = colors.yellow, bold = true, },
          NvimTreeCursorLine = { bg = colors.cursorline, },
          NvimTreeVertSplit = { fg = '#808080' },
          NvimTreeNormal = { bg = colors.bg },
          NvimTreeGitDirty = { fg = colors.orange, },
          NvimTreeGitNew = { fg = colors.green, },

          TelescopeSelection = { bg = colors.cursorline, },
          TelescopeMultiSelection = { bg = colors.cursorline, },
        },
      })
    end
  },

  -- Basics
  { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },
  { 'ryanoasis/vim-devicons',      event = 'VeryLazy' },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = true,
    config = function()
      require('nvim-treesitter.install').compilers = { 'clang' }
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true },
        ensure_installed = { 'html', 'typescript', 'javascript', 'json', 'http', 'vim', 'vimdoc', 'query', 'bash',
          'dockerfile', 'git_config', 'graphql', 'jsdoc', 'lua', 'regex', 'sql', 'terraform', 'yaml', 'c_sharp' },
      }
    end
  },
  { 'nvim-treesitter/playground', event = 'VeryLazy' },
  { 'jremmen/vim-ripgrep' },
  --'tpope/vim-sleuth',

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    config = function()
      require('telescope').setup({
        file_ignore_patterns = { 'node_modules' },
        defaults = vim.tbl_extend(
          'force',
          require('telescope.themes').get_ivy(),
          {
            sorting_strategy = 'ascending',
            layout_config = {
              prompt_position = 'top',
            },
            mappings = {
              i = {
                ['<C-k>'] = require('telescope.actions').move_selection_previous,
                ['<C-j>'] = require('telescope.actions').move_selection_next,
                ['<C-u>'] = require('telescope.actions').results_scrolling_up,
                ['<C-d>'] = require('telescope.actions').results_scrolling_down,
                ['<C-P>'] = require('telescope.actions').cycle_history_prev,
                ['<C-N>'] = require('telescope.actions').cycle_history_next,
                ['<C-Tab>'] = require('telescope.actions').toggle_selection,
                ['<C-S-Tab>'] = require('telescope.actions').toggle_selection,
              },
            },
          }
        ),
        pickers = {
          buffers = {
            path_display = { 'smart', 'shorten' },
            ignore_current_buffer = true,
            sort_mru = true,
            sorting_strategy = 'ascending',
            layout_config = {
              prompt_position = 'top',
            },
            mappings = {
              i = {
                ['<C-S-Tab>'] = require('telescope.actions').move_selection_previous,
                ['<C-Tab>'] = require('telescope.actions').move_selection_next,
              },
            },
          }
        }
      })
    end,
  },

  -- Pretty
  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    config = function()
      require('dressing').setup({})
    end
  },

  -- Git stuff
  { 'airblade/vim-gitgutter' }, -- Show git diff of lines edited
  { 'tpope/vim-fugitive' },     -- :Gblame
  { 'sindrets/diffview.nvim' },

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    config = function()
      for _, language in ipairs({ 'typescript', 'javascript' }) do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          }
        }
      end
      vim.cmd('augroup Dap | autocmd FileType dap-repl set nobl | augroup END')
    end
  },
  {
    'mxsdev/nvim-dap-vscode-js',
    event = 'VeryLazy',
    config = function()
      require('dap-vscode-js').setup({
        debugger_path = 'c:/projects/vscode-js-debug', -- Path to vscode-js-debug installation.
        adapters = { 'pwa-node' },
      })
      require('dap.ext.vscode').type_to_filetypes = { ['pwa-node'] = { 'javascript', 'typescript' }}
      require('dap.ext.vscode').json_decode = require('overseer.json').decode
    end
  },
  {
    'rcarriga/nvim-dap-ui',
    event = 'VeryLazy',
    config = function()
      require('dapui').setup({
        force_buffers = true,
        layouts = { {
          elements = { {
            id = 'console',
            size = 0.90
          }, {
            id = 'repl',
            size = 0.10
          } },
          position = 'bottom',
          size = 10
        }, {
          elements = { {
            id = 'breakpoints',
            size = 0.10
          }, {
            id = 'scopes',
            size = 0.50
          }, {
            id = 'stacks',
            size = 0.30
          }, {
            id = 'watches',
            size = 0.10
          }
          },
          position = 'left',
          size = 0.20
        }, },
      });
      vim.cmd('augroup DapUI | autocmd FileType dapui-console set nobl | augroup END')
    end
  },
  {
    'nvim-telescope/telescope-dap.nvim',
    event = 'VeryLazy',
    config = function()
      require('telescope').load_extension('dap')
    end
  },
  {
    'Weissle/persistent-breakpoints.nvim',
    event = 'VeryLazy',
    config = function()
      require('persistent-breakpoints').setup({ load_breakpoints_event = { 'BufReadPost' } })
    end
  },

  -- Flow -- eg tools to help in Vim
  {
    'uga-rosa/ccc.nvim',
    config = function()
      require('ccc').setup({
        -- Your preferred settings
        -- Example: enable highlighter
        highlighter = {
          auto_enable = true,
          lsp = true,
        },
      })
    end
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({})
    end

  },
  {
    'm-demare/hlargs.nvim',
    config = function()
      require('hlargs').setup({ performance = { slow_parse_delay = 5 } })
    end
  },
  { 'RRethy/vim-illuminate',  event = 'VeryLazy' },
  { 'vim-airline/vim-airline' }, -- Vim powerline
  {
    'nvim-tree/nvim-tree.lua',
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
          icons = { show = { folder_arrow = false, git = false } }
        },
        filters = {
          dotfiles = false,
          custom = {
            ".eslintrc.json",
            "README.md",
            "jest.config.ts",
            "package.json",
            "project.json",
            "tsconfig.*.json",
            "webpack.config.js",
          }
        },
        actions = {
          change_dir = { global = true, restrict_above_cwd = false },
          open_file = {
            window_picker = {
              exclude = {
                filetype = {
                  "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame",
                  "dapui_console", "dapui_watches", "dap-repl"
                },
              }
            }
          },
          remove_file = {
            close_window = false
          }
        },
        live_filter = { always_show_folders = false },
      })
    end
  },
  { 'jlanzarotta/bufexplorer', branch = '7.4.24' },
  { 'neoclide/coc.nvim',       branch = 'release' },
  'gennaro-tedesco/nvim-peekup', -- Interact with registers:
  {
    'rest-nvim/rest.nvim',
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
    end

  },

  -- New stuff
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup({
        padding = true,
        sticky = true,
        ignore = nil,
        toggler = {
          line = ',gc',
          block = ',gb',
        },
        opleader = {
          line = ',tc',
          block = ',tb',
        },
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end
  },

  'kevinhwang91/nvim-bqf',
  {
    'Wansmer/treesj',
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
        max_join_length = 150,
      });
      local langs = require('treesj.langs')
      langs.presets['javascript'].array.join.space_in_brackets = false
      langs.presets['typescript'].array.join.space_in_brackets = false
    end

  },
  {
    'danymat/neogen',
    config = function()
      require('neogen').setup({
        enabled = true,
        languages = {
          javascript = {
            template = {
              annotation_convention = 'custom',
              custom = {
                { nil, '/** $1 */',       { no_results = true, type = { 'func', 'class' } } },
                { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
                { nil, '/** $1 */',       { type = { 'class', 'func', 'type' } } },
              }
            }
          },
          typescript = {
            template = {
              annotation_convention = 'custom',
              custom = {
                { nil, '/** $1 */',       { no_results = true, type = { 'func', 'class' } } },
                { nil, '/** @type $1 */', { no_results = true, type = { 'type' } } },
                { nil, '/** $1 */',       { type = { 'class', 'func', 'type' } } },
              }
            }
          }
        }
      })
    end
  },
  {
    'petertriho/nvim-scrollbar',
    config = function()
      require('scrollbar').setup()
    end
  },
  -- 'nvim-neotest/neotest',
  -- 'nvim-neotest/neotest-jest',
  {
    'Shatur/neovim-session-manager',
    config = function()
      require('session_manager').setup({
        autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
        -- autosave_last_session = false,
        autosave_only_in_session = true,
        autosave_ignore_buftypes = { 'nofile' }
      })
    end
  },
  {
    'stevearc/overseer.nvim',
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
                  prompt = "Select an Adapter",
                  format_item = function(x) return x.name end,
                }, function(adapterAndPid)
                  if adapterAndPid then
                    local customConfig = {
                      type = adapterAndPid.name,
                      request = 'attach',
                      name = string.format('Attach to %s', adapterAndPid.pid),
                      processId = adapterAndPid.pid,
                      cwd = task.cwd
                    }
                    require('dap').run(customConfig);
                  end
                end)
              end
            end
          }
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
          }
        },
        task_launcher = {
          bindings = {
            n = {
              ['<ESC>'] = 'Cancel',
            }
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
    end
  },
  {
    'tamton-aquib/duck.nvim',
    config = function()
      require('duck').setup({ speed = 2 });
    end
  },
  {
    'gen740/SmoothCursor.nvim',
    config = function()
      require('smoothcursor').setup({
        fancy = {
          enable = true,
          head = { cursor = '▷', texthl = 'SmoothCursorGreen', linehl = nil },
          body = {
            { cursor = '', texthl = 'SmoothCursorGreen' },
            { cursor = '●', texthl = 'SmoothCursorAqua' },
            { cursor = '•', texthl = 'SmoothCursorAqua' },
            { cursor = '.', texthl = 'SmoothCursorBlue' },
          },
        },
        speed = 20,
        intervals = 8,
        disable_float_win = true,
        disabled_filetypes = { 'OverseerList', 'OverseerForm', 'dapui_*' },
      })
    end
  },
  {
    'fedepujol/move.nvim',
    event = 'VeryLazy'
  },
  {
    'rcarriga/nvim-notify',
    init = function()
      vim.opt.termguicolors = true
    end,
    config = function()
      require('notify').setup()
    end,
  }
  -- 'andythigpen/nvim-coverage',
}, {
  performance = {
    rtp = {
      reset = false
    }
  }
})
