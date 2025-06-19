local M = {
  {
    'tpope/vim-dadbod',
    cmd = { 'DB' },
    opts = {},
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
}

return M
