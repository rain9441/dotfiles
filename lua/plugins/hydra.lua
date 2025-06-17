local M = {
  {
    'nvimtools/hydra.nvim',
    config = function()
      local Hydra = require("hydra")
      Hydra({})
    end,
  },
}

return M
