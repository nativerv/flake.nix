local M = {}

M.mappings = {
  forward_search = {
    keys = { '*', --[[ '<M-р>' ]] },
    opts = { desc = 'Search word forwards' },
    {
      { 'n', 'v', 'x', 'o' },
    },
  },
  backward_search = {
    keys = { '#', --[[ '<M-р>' ]] },
    opts = { desc = 'Search word backwards' },
    {
      { 'n', 'v', 'x', 'o' },
    },
  },
}

return M
