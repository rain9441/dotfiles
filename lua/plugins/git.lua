local M = {
  -- retired, moved to gitsigns.nvim (lua focused)
  -- { 'airblade/vim-gitgutter',  event = 'VeryLazy' },
  {
    'NeogitOrg/neogit',
    cmd = 'Neogit',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('neogit').setup({
        use_default_keymaps = false,
        -- signs = {
        --   -- { CLOSED, OPENED }
        --   hunk = { "", "" },
        --   item = { ">", "v" },
        --   section = { ">", "v" },
        -- },
        -- Each Integration is auto-detected through plugin presence, however, it can be disabled by setting to `false`
        integrations = {
          telescope = nil,
          diffview = nil,
        },
        mappings = {
          commit_editor = {
            ["q"] = "Close",
            ["<c-c><c-c>"] = "Submit",
            ["<c-c><c-k>"] = "Abort",
            ["<m-p>"] = "PrevMessage",
            ["<m-n>"] = "NextMessage",
            ["<m-r>"] = "ResetMessage",
          },
          rebase_editor = {
            ["p"] = "Pick",
            ["r"] = "Reword",
            ["e"] = "Edit",
            ["s"] = "Squash",
            ["f"] = "Fixup",
            ["x"] = "Execute",
            ["d"] = "Drop",
            ["b"] = "Break",
            ["q"] = "Close",
            ["<cr>"] = "OpenCommit",
            ["gk"] = "MoveUp",
            ["gj"] = "MoveDown",
            ["<c-c><c-c>"] = "Submit",
            ["<c-c><c-k>"] = "Abort",
          },
          finder = {
            ["<cr>"] = "Select",
            ["<c-c>"] = "Close",
            ["<esc>"] = "Close",
            ["<c-n>"] = "Next",
            ["<c-p>"] = "Previous",
            ["<down>"] = "Next",
            ["<up>"] = "Previous",
            ["<tab>"] = "MultiselectToggleNext",
            ["<s-tab>"] = "MultiselectTogglePrevious",
            ["<c-j>"] = "NOP",
          },
          popup = {
            ["?"] = "HelpPopup",
            ["A"] = "CherryPickPopup",
            ["d"] = "DiffPopup",
            ["M"] = "RemotePopup",
            ["P"] = "PushPopup",
            ["X"] = "ResetPopup",
            ["Z"] = "StashPopup",
            ["i"] = "IgnorePopup",
            ["t"] = "TagPopup",
            ["b"] = "BranchPopup",
            ["w"] = "WorktreePopup",
            ["c"] = "CommitPopup",
            ["f"] = "FetchPopup",
            ["l"] = "LogPopup",
            ["m"] = "MergePopup",
            ["p"] = "PullPopup",
            ["r"] = "RebasePopup",
            ["v"] = "RevertPopup",
          },
          status = {
            ["q"] = "Close",
            ["I"] = "InitRepo",
            -- ["1"] = "Depth1",
            -- ["2"] = "Depth2",
            -- ["3"] = "Depth3",
            -- ["4"] = "Depth4",
            ["<tab>"] = "Toggle",
            ["x"] = "Discard",
            ["s"] = "Stage",
            ["S"] = "StageUnstaged",
            ["<c-s>"] = "StageAll",
            ["u"] = "Unstage",
            ["U"] = "UnstageStaged",
            ["$"] = "CommandHistory",
            ["#"] = "Console",
            ["Y"] = "YankSelected",
            ["<c-r>"] = "RefreshBuffer",
            ["<enter>"] = "GoToFile",
            ["<c-v>"] = "VSplitOpen",
            ["<c-x>"] = "SplitOpen",
            ["<c-t>"] = "TabOpen",
            ["{"] = "GoToPreviousHunkHeader",
            ["}"] = "GoToNextHunkHeader",
          },
        },

      })
    end,
  },
  -- { 'tpope/vim-fugitive' },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewFileHistory', 'DiffviewOpen' },
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
        _signs_staged_enable = true,
      })
    end,
  },
  {
    'FabijanZulj/blame.nvim',
    cmd = 'BlameToggle',
    config = function()
      require('blame').setup({})
    end,
  },
}

return M
