-- Key bindings - don't switch focus to the opened file

for _, key in ipairs({ "<CR>", "<2-LeftMouse>", "o" }) do
	vim.keymap.set("n", key, function()
		if vim.tbl_isempty(vim.fn.getqflist()) then
			return
		end
		vim.cmd(".cc")
		vim.cmd("wincmd p")
	end, { desc = "Open hovered item", buffer = 0 })
end
for _, key in ipairs({ "<C-CR>", "O" }) do
	vim.keymap.set("n", key, function()
		if vim.tbl_isempty(vim.fn.getqflist()) then
			return
		end
		vim.cmd(".cc")
	end, { desc = "Open hovered item and focus the window", buffer = 0 })
end

local removed_items = {} -- Stack to store removed items and their original positions

local remove_hovered_item = function()
  -- Get the current line number which corresponds to the item's index in the qflist (lua is base 1)
  local idx = vim.fn.line('.')
  local qflist = vim.fn.getqflist() -- Get the current quickfix list
  if idx > 0 and idx <= #qflist then
    local item = table.remove(qflist, idx) -- Remove and get the item
    table.insert(removed_items, {item = item, idx = idx}) -- Store the removed item and its index
    vim.fn.setqflist({}, 'r', {items = qflist}) -- Update the quickfix list
  end
end

local undo_remove = function()
  if #removed_items > 0 then
    local last_removed = table.remove(removed_items) -- Get the last removed item
    local qflist = vim.fn.getqflist() -- Get the current quickfix list
    table.insert(qflist, last_removed.idx, last_removed.item) -- Reinsert the item at its original position
    vim.fn.setqflist({}, 'r', {items = qflist}) -- Update the quickfix list
  end
end

vim.keymap.set("n", 'd', remove_hovered_item, {
  desc = "Remove item from QuickFix list",
  remap = true,
  buffer = 0,
})
vim.keymap.set("n", 'u', undo_remove, {
  desc = "Undo removing item from QuickFix list",
  remap = true,
  buffer = 0,
})
