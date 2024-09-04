--     _____   ____________   __    __  _____
--    /  _/ | / /  _/_  __/  / /   / / / /   |
--    / //  |/ // /  / /    / /   / / / / /| |
--  _/ // /|  // /  / /  _ / /___/ /_/ / ___ |
-- /___/_/ |_/___/ /_/  (_)_____/\____/_/  |_|
--
-- Description: A NeoVim configuration written in Lua
-- Author: nrv
-- URL: https://github.com/nativerv/dotfiles

local SUPPORTED_VERSION = 10
vim.g.bad_message = ''

-- This file contains only `xpcall` calls and this function,
-- so the errored modules can be ignored and warned about,
-- but the rest can still be run.
function yell(...)
  vim.g.bad_message = 'ERROR: most likely you broke something in the config or your Neovim updated to a new version. Parts of your config will not work.'
  --vim.notify(debug.traceback(...), vim.log.levels.OFF)
  --vim.notify(
  --  'Something went horribly wrong, most likely you broke something or your Neovim updated to a new version. Parts of your config will not work.', 
  --  vim.log.levels.OFF
  --)
end

-- Customize built-in nvim settings
xpcall(require, yell, 'user.options')

-- Set mappings for built-in stuff
xpcall(require, yell, 'user.mappings')

-- Autocmds that do different handy things, 
-- all still only using built-in nvim stuff 
xpcall(require, yell, 'user.autocmds')

-- Colorscheme - fallback for the following guard
xpcall(require, yell, 'user.colorscheme')

-- Guard on nvim version -- has to be as specified by SUPPORTED_VERSION for the rest to work
if not (vim.version().major == 0 and vim.version().minor == SUPPORTED_VERSION) then
  --vim.notify(
  --  'You neovim must be of version 0.9. The config will not work, falling back to default.', 
  --  vim.log.levels.OFF
  --)
  vim.g.bad_message = 'ERROR: You neovim must be of version 0.9. Plugins will not work, falling back to vanilla.'
  return
end

-- Bootstrap (download if not present) `lazy.nvim` plugin manager
xpcall(require, yell, 'user.bootstrap')

-- Install and configure plugins with `lazy.nvim`, options, mappings and
-- autocmds for plugins all required from there
xpcall(require, yell, 'user.plugins')

-- Call my scratchpad ('Run Commands')
-- Stuff from there eventually belong in their separate place, like a custom plugin.
xpcall(require, yell, 'user.rc')

-- Colorscheme when used with plugins also need to go last
xpcall(require, yell, 'user.colorscheme')
