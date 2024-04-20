local M = {
  {
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
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
        filesystem_watchers = {
          ignore_dirs = { 'node_modules', 'dist' },
        },
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
}

return M
