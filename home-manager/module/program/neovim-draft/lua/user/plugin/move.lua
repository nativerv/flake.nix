local M = {}

M.mappings = {
  move_left = {
    -- TODO: terminal that supports cyrillic modkey escape codes
    keys = { '<M-C-h>' --[[, '<M-C-р>' ]] },
    opts = {},
    { 
      { 'n' }, 
      function() vim.cmd.MoveHChar(-1) end, 
      { desc = 'Move char left' } 
    },
    { 
      { 'v' }, 
      function() vim.cmd.MoveHBlock(-1) end, 
      { desc = "Move selection left" }
    },
  },
  move_bottom = {
    -- TODO: terminal that supports cyrillic modkey escape codes
    keys = { '<M-C-j>' --[[, '<M-C-о>' ]] },
    opts = {},
    { 
      { 'n' }, 
      function() vim.cmd.MoveLine(1) end, 
      { desc = 'Move char bottom' } 
    },
    { 
      { 'v' }, 
      function() vim.cmd.MoveBlock(1) end, 
      { desc = "Move selection bottom" }
    },
  },
  move_top = {
    -- TODO: terminal that supports cyrillic modkey escape codes
    keys = { '<M-C-k>' --[[, '<M-C-л>' ]] },
    opts = {},
    { 
      { 'n' }, 
      function() vim.cmd.MoveLine(-1) end, 
      { desc = 'Move char up' } 
    },
    { 
      { 'v' }, 
      function() vim.cmd.MoveBlock(-1) end, 
      { desc = "Move selection up" }
    },
  },
  move_right = {
    -- TODO: terminal that supports cyrillic modkey escape codes
    keys = { '<M-C-l>' --[[, '<M-C-д>' ]] },
    opts = {},
    { 
      { 'n' }, 
      function() vim.cmd.MoveHChar(1) end, 
      { desc = 'Move char right' } 
    },
    { 
      { 'v' }, 
      function() vim.cmd.MoveHBlock(1) end, 
      { desc = "Move selection right" }
    },
  },
}

M.setup = function()
  -- require'user.lib.plugin-management'.apply_module_mappings(M.mappings)
  require('move').setup({
    line = {
      enable = true,  -- Enables line movement
      indent = true,  -- Toggles indentation
    },
    block = {
      enable = true, -- Enables block movement
      indent = true, -- Toggles indentation
    },
    word = {
      enable = true, -- Enables word movement
    },
    char = {
      enable = true, -- Enables char movement
    }
  })
end

return M
