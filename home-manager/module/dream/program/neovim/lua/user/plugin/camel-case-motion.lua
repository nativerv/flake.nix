local M = {}

M.mappings = {
  forward = {
    keys = { '<leader>w'},
    opts = { desc = 'Forward word (camel case)' },
    { { 'n', 'v', 's', 'o' }, '<plug>CamelCaseMotion_w' },
  },
  forward_end = {
    keys = { '<leader>e' },
    opts = { desc = 'End of word (camel case)' },
    { { 'n', 'v', 's', 'o' }, '<plug>CamelCaseMotion_e', },
  },
  back = {
    keys = { '<leader>b' },
    opts = { desc = 'Previous word (camel case)' },
    { { 'n', 'v', 's', 'o' }, '<plug>CamelCaseMotion_b', },
  }, 
}

M.setup = function()
  -- This will enable the default mappings:
  vim.g.camelcasemotion_key = '<leader>'
  -- vim.cmd [[ camelcasemotion#CreateMotionMappings('<leader>') ]]
  -- vim.cmd [[
  --   map <silent> <leader>w <Plug>CamelCaseMotion_w
  --   map <silent> <leader>b <Plug>CamelCaseMotion_b
  --   map <silent> <leader>e <Plug>CamelCaseMotion_e
  --   map <silent> <leader>ge <Plug>CamelCaseMotion_ge
  -- ]]
end

return M
