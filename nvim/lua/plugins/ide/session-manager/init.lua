return {
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

    -- session_manager.utils.save_session force-deletes every non-file
    -- buffer (Neo-tree included) *before* it fires the `SessionSavePre`
    -- User autocmd, so hooking that event is too late to catch Neo-tree's
    -- window while its buffer still carries the tell-tale filetype. Wrap
    -- the save function itself so Neo-tree gets closed first, covering
    -- both manual saves and the VimLeavePre autosave.
    local session_utils = require('session_manager.utils')
    local save_session = session_utils.save_session
    session_utils.save_session = function(filename)
      require('custom/neotree-safe').close_before_session_save()
      save_session(filename)
    end
  end,
}
