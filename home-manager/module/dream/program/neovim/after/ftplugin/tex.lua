vim.opt_local.wrap = true -- set wrap
vim.opt_local.shiftwidth = 2 -- ? something with setting spaces/tabs to 4 spaces
vim.opt_local.tabstop = 2 -- ? something with setting spaces/tabs to 4 spaces
vim.opt_local.softtabstop = 2 -- ? something with setting spaces/tabs to 4 spaces
vim.opt_local.spell = true -- enable spellcheck
vim.opt_local.spelllang = 'en,ru' -- spellcheck languages

local ok = pcall(require, 'nvim-surround')
if ok then
  local strong = {
    add = { "\\textbf{", "}" },
    find = "\\textbf{.-}",
    delete = "^(\\textbf{?)().-(}?)()$",
    change = {
      target = "^(\\textbf{?)().-(}?)()$",
    },
  }
  local emphasis = {
    add = { "\\emph{", "}" },
    find = "\\emph{.-}",
    delete = "^(\\emph{?)().-(}?)()$",
    change = {
      target = "^(\\emph{?)().-(}?)()$",
    },
  }
  require("nvim-surround").setup({
    move_cursor = false,
    surrounds = {
      ["s"] = strong,
      ["S"] = strong,
      ["e"] = emphasis,
      ["E"] = emphasis,
      -- ["x"] = strike,
      -- ["X"] = strike,
    },
  })
end
