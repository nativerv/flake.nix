local lazypath = vim.fn.stdpath("data") .. "/lazy"
local lazy_plugin_path = lazypath .. "/lazy.nvim"

if not vim.loop.fs_stat(lazy_plugin_path) then
  -- vim.fn.system({
  --   "git",
  --   "clone",
  --   "--filter=blob:none",
  --   "https://github.com/folke/lazy.nvim.git",
  --   "--branch=stable", -- latest stable release
  --   lazypath,
  -- })
end

vim.opt.runtimepath:prepend(lazy_plugin_path)
