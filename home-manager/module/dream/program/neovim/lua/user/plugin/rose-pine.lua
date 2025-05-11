local M = {}

M.setup = function()
  require('rose-pine').setup {
    styles = {
      bold = false,
      italic = false,
      transparency = false,
    },
  }
end

return M
