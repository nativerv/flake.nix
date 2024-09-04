local M = {}

M.setup = function()
  local gitsigns_icon_change = '│'
  local gitsigns_icon_remove = ''
  require('gitsigns').setup {
    signs = {
      add = { text = gitsigns_icon_change, },
      change = { text = gitsigns_icon_change, },
      changedelete = { text = gitsigns_icon_change, },
      delete = { text = gitsigns_icon_remove, },
      topdelete = { text = gitsigns_icon_remove, },
    },
    -- Passed directly to `nvim_open_win`:
    preview_config = {
      border = 'rounded',
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1,
    },
  }
  -- Keymaps
  -- Cycle hunks
  vim.keymap.set({ 'n' }, '<leader>g[', function()
    require('gitsigns').prev_hunk()
  end, { desc = 'Go to previous hunk' })

  vim.keymap.set({ 'n' }, '<leader>g]', function()
    require('gitsigns').next_hunk()
  end, { desc = 'Go to next hunk' })

  -- Stage hunk
  vim.keymap.set({ 'n' }, '<leader>gs', function()
    require('gitsigns').stage_hunk()
  end, { desc = 'Stage hunk under cursor' })

  vim.keymap.set({ 'v' }, '<leader>gs', function()
    require('gitsigns').stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'Stage hunks under VISUAL selection' })

  -- Undo last staged hunk
  vim.keymap.set({ 'n' }, '<leader>gu', function()
    require('gitsigns').undo_stage_hunk()
  end, { desc = 'Unstage last staged hunk' })

  -- Reset hunk
  vim.keymap.set({ 'n' }, '<leader>gr', function()
    require('gitsigns').reset_hunk()
  end, { desc = 'Reset hunk under cursor' })

  vim.keymap.set({ 'v' }, '<leader>gr', function()
    require('gitsigns').reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
  end, { desc = 'Reset hunks under VISUAL selection' })

  -- Preview hunk
  vim.keymap.set({ 'n', 'v' }, '<leader>gd', function()
    require('gitsigns').preview_hunk()
  end, { desc = 'Preview hunk under cursor in a float' })

  -- Blame hunk
  vim.keymap.set({ 'n' }, '<leader>gb', function()
    require('gitsigns').blame_line {
      full = true,
      ignore_whitespace = true,
    }
  end, { desc = 'Open blame for the line under cursor in a float' })

  -- Textobjects
  -- Select hunk (if you try to translate it to lua it
  -- wouldn't work because of <C-U> magic)
  vim.keymap.set(
    { 'x', 'o', 'v' },
    'ih',
    ':<C-U>lua require"gitsigns".select_hunk()<cr>',
    { desc = 'Inside git hunk' }
  )

  -- Which-Key descriptions
  if pcall(require, 'which-key') then
    require('which-key').register {
      ['<leader>'] = {
        g = { name = 'Git...' },
      },
    }
  end
end

return M
