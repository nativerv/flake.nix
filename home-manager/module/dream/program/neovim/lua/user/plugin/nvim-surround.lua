local M = {}

M.mappings = {
  {
    keys = { 'S' },
    { { 'n' }, 'ysiw' },
    opts = {
      remap = true,
      silent = true,
      desc = 'Add a surrounding pair around a word',
    },
  },
  {
    keys = { 'S' },
    { { 'v' } },
    opts = { desc = 'Add a surrounding pair around a selection', },
  },
  {
    keys = { 'ys' },
    { 'n' },
    opts = { desc = 'Add a surrounding pair around a motion' },
  },
  {
    keys = { 'cs' },
    { 'n' },
    opts = { desc = 'Change the surrounding pair' },
  },
  {
    keys = { 'ds' },
    { 'n' },
    opts = { desc = 'Delete the surrounding pair' },
  },
}

M.setup = function()
	local strong = {
		add = { "**", "**" },
		find = "%*%*.-%*%*",
		delete = "^(%*%*?)().-(%*%*?)()$",
		change = {
			target = "^(%*%*?)().-(%*%*?)()$",
		},
	}
	local emphasis = {
		add = { "*", "*" },
		find = "%*.-%*",
		delete = "^(%*?)().-(%*?)()$",
		change = {
			target = "^(%*?)().-(%*?)()$",
		},
	}
  local strike = {
    add = { "~~", "~~" },
    find = "~~.-~~",
    delete = "^(~~?)().-(~~?)()$",
    change = {
      target = "^(~~?)().-(~~?)()$",
    },
  }
	require("nvim-surround").setup({
		move_cursor = false,
		surrounds = {
			["s"] = strong,
			["S"] = strong,
			["e"] = emphasis,
			["E"] = emphasis,
			["x"] = strike,
			["X"] = strike,
		},
	})
	require("user.lib.plugin-management").apply_module_mappings(M.mappings)
end

return M
