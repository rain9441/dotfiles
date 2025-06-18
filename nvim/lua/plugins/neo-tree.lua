local M = {
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = 'Neotree',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({
        source_selector = {
          winbar = true,
          statusline = false,
          padding = 0, -- can be int or table
          -- padding = { left = 2, right = 0 },
        },
        use_default_mappings = false,
        default_component_configs = {
          container = {
            enable_character_fade = true,
            width = '100%',
            right_padding = 1,
          },
          indent = {
            indent_size = 3,
            padding = 0,
          },
        },
        commands = {
          oil = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              require('oil').open_float(node.path)
            else
              require('oil').open_float(node._parent_id)
            end
          end,
        },
        window = {
          mapping_options = {
            noremap = true,
            nowait = true,
          },
          position = 'right',
          width = 60,
          mappings = {
            ['O'] = 'oil',
            ['<space>'] = { 'toggle_node' },
            ['<2-LeftMouse>'] = 'open_with_window_picker',
            ['<cr>'] = { 'open_with_window_picker', config = { expand_nested_files = true } }, -- expand nested file takes precedence
            -- ["<esc>"] = "cancel", -- close preview or floating neo-tree window
            ['P'] = { 'toggle_preview', config = { use_float = true, use_image_nvim = false } },
            ['S'] = 'split_with_window_picker',
            ['s'] = 'vsplit_with_window_picker',
            ['t'] = 'open_tabnew',
            ['Z'] = 'close_all_nodes',
            -- ['z'] = 'expand_all_nodes',
            ['R'] = 'refresh',
            ['a'] = 'add',
            ['d'] = 'delete',
            ['r'] = 'rename',
            ['y'] = 'copy_to_clipboard',
            ['x'] = 'cut_to_clipboard',
            ['p'] = 'paste_from_clipboard',
            ['e'] = 'toggle_auto_expand_width',
            ['?'] = 'show_help',
            ['<'] = 'prev_source',
            ['>'] = 'next_source',
          },
        },
        filesystem = {
          use_libuv_file_watcher = false,
          window = {
            mappings = {
              ['H'] = 'toggle_hidden',
              -- ["f"] = "fuzzy_finder",
              -- ["F"] = "fuzzy_finder_directory",
              -- ["/"] = "filter_as_you_type", -- this was the default until v1.28
              -- ["D"] = "fuzzy_sorter_directory",
              -- ["D"] = "fuzzy_sorter_directory",
              -- ["f"] = "filter_on_submit",
              -- ["<C-x>"] = "clear_filter",
              ['-'] = 'navigate_up',
              ['C'] = 'set_root',
              ['[g'] = 'prev_git_modified',
              [']g'] = 'next_git_modified',
            },
            fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
              ['<down>'] = 'move_cursor_down',
              ['<C-n>'] = 'move_cursor_down',
              ['<up>'] = 'move_cursor_up',
              ['<C-p>'] = 'move_cursor_up',
            },
          },
          filtered_items = {
            visible = false, -- when true, they will just be displayed differently than normal items
            hide_dotfiles = false,
            hide_gitignored = false,
            hide_hidden = false,
            hide_by_name = {},
            hide_by_pattern = {},
            always_show = {},
            never_show = {},
            never_show_by_pattern = {},
          },
          hijack_netrw_behavior = 'disabled',
        },
        buffers = {
          window = {
            mappings = {
              ['<C-u>'] = 'navigate_up',
              ['C'] = 'set_root',
              ['bd'] = 'buffer_delete',
            },
          },
        },
        git_status = {
          window = {
            mappings = {},
          },
        },
        nesting_rules = {
          ['Dockerfile'] = {
            pattern = '^Dockerfile$',
            files = { '.dockerignore' },
          },
          ['project.json'] = {
            pattern = 'project.json$',
            files = {
              'tsconfig*',
              '*package*.json',
              'jest.*.ts',
              'jest.*.js',
              '.prettier*',
              '.eslint*',
              'webpack.config.js',
              'dist',
            },
          },
          ['package.json'] = {
            pattern = 'package.json$',
            files = {
              'tsconfig*',
              'nx.json',
              'package-lock.json',
              'jest.*.ts',
              'jest.*.js',
              '.prettier*',
              '.eslint*',
              'webpack.config.js',
              'dist',
              'node_modules',
              '.vscode',
              '.vs',
              '.angular',
              'coverage',
            },
          },
        },
      })
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    config = function()
      require('window-picker').setup({
        filter_rules = {
          bo = {
            buftype = { 'terminal', 'nofile', 'quickfix', 'prompt', 'help' },
          }
        },
      });
    end,
  }
}

return M
