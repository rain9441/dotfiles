local M = {
  {
    'NeogitOrg/neogit',
    commit = '9bb1e73c534f767607e0a888f3de4c942825c501',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup({
        use_default_keymaps = false,
        filewatcher = {
          interval = 1000,
          enabled = true
        },
        graph_style = "unicode",
        commit_editor = {
          kind = "vsplit",
        },
        mappings = {
          commit_editor = {
            ['q'] = 'Close',
            ['<c-c><c-c>'] = 'Submit',
            ['<c-c><c-k>'] = 'Abort',
            ['<m-p>'] = 'PrevMessage',
            ['<m-n>'] = 'NextMessage',
            ['<m-r>'] = 'ResetMessage',
          },
          commit_editor_I = {
            ['<c-c><c-c>'] = 'Submit',
            ['<c-c><c-k>'] = 'Abort',
          },
          rebase_editor = {
            ['p'] = 'Pick',
            ['r'] = 'Reword',
            ['e'] = 'Edit',
            ['s'] = 'Squash',
            ['f'] = 'Fixup',
            ['x'] = 'Execute',
            ['d'] = 'Drop',
            ['b'] = 'Break',
            ['q'] = 'Close',
            ['<cr>'] = 'OpenCommit',
            ['gk'] = 'MoveUp',
            ['gj'] = 'MoveDown',
            -- ['gl'] = 'OpenTree',
            ['<c-c><c-c>'] = 'Submit',
            ['<c-c><c-k>'] = 'Abort',
            -- ['[c'] = 'OpenOrScrollUp',
            -- [']c'] = 'OpenOrScrollDown',
          },
          rebase_editor_I = {
            ['<c-c><c-c>'] = 'Submit',
            ['<c-c><c-k>'] = 'Abort',
          },
          finder = {
            ['<cr>'] = 'Select',
            ['<c-c>'] = 'Close',
            ['<esc>'] = 'Close',
            ['<c-n>'] = 'Next',
            ['<c-p>'] = 'Previous',
            ['<down>'] = 'Next',
            ['<up>'] = 'Previous',
            ['<tab>'] = 'MultiselectToggleNext',
            ['<s-tab>'] = 'MultiselectTogglePrevious',
            ['<c-j>'] = 'NOP',
          },
          popup = {
            ['?'] = 'HelpPopup',
            ['A'] = 'CherryPickPopup',
            ['d'] = 'DiffPopup',
            ['M'] = 'RemotePopup',
            ['P'] = 'PushPopup',
            ['X'] = 'ResetPopup',
            ['Z'] = 'StashPopup',
            ['i'] = 'IgnorePopup',
            ['t'] = 'TagPopup',
            ['b'] = 'BranchPopup',
            ['c'] = 'CommitPopup',
            ['f'] = 'FetchPopup',
            ['l'] = 'LogPopup',
            ['m'] = 'MergePopup',
            ['p'] = 'PullPopup',
            ['r'] = 'RebasePopup',
            ['v'] = 'RevertPopup',
            ['w'] = 'WorktreePopup',
          },
          status = {
            ['q'] = 'Close',
            ['I'] = 'InitRepo',
            -- Neogit blows up if you unbind, so bind to completely arbitrary random keys
            -- ["<c-f8>1"] = "Depth1",
            -- ["<c-f8>2"] = "Depth2",
            -- ["<c-f8>3"] = "Depth3",
            -- ["<c-f8>4"] = "Depth4",
            -- ["<c-f8>5"] = "ShowRefs",
            ['<tab>'] = 'Toggle',
            ['x'] = 'Discard',
            ['s'] = 'Stage',
            ['S'] = 'StageUnstaged',
            ['<c-s>'] = 'StageAll',
            -- ['K'] = 'Untrack',
            ['u'] = 'Unstage',
            ['U'] = 'UnstageStaged',
            ['$'] = 'CommandHistory',
            ['Y'] = 'YankSelected',
            ['<c-r>'] = 'RefreshBuffer',
            ['<enter>'] = 'GoToFile',
            ['<c-v>'] = 'VSplitOpen',
            ['<c-x>'] = 'SplitOpen',
            ['<c-t>'] = 'TabOpen',
            ['[f'] = 'GoToPreviousHunkHeader',
            [']f'] = 'GoToNextHunkHeader',
            -- ['[c'] = 'OpenOrScrollUp',
            -- [']c'] = 'OpenOrScrollDown',
          },
        },
      })
    end,
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewFileHistory', 'DiffviewOpen' },
    opts = {
      enhanced_diff_hl = true,
    }
  },
  {
    'linrongbin16/gitlinker.nvim',
    cmd = 'GitLink',
    config = function()
      require('gitlinker').setup({
        command = { name = 'GitLink' },
      })
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    commit = 'ce5e1b5ae3455316364ac1c96c2787d7925a2914',
    event = 'VeryLazy',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '-' },
          topdelete = { text = '‾' },
          changedelete = { text = 'x' },
          untracked = { text = '?' },
        },
        signs_staged_enable = true,
      })
    end,
  },
  {
    'FabijanZulj/blame.nvim',
    cmd = 'BlameToggle',
    config = function() require('blame').setup({}) end,
  },
}

return M
