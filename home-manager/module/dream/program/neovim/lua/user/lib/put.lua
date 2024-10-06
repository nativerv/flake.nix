local M = {}

-- Puts time after cursor
function M.time(format)
  return function()
    --vim.cmd ([[ execute "norm! a" . strftime("%s") ]]):format(format)
    vim.cmd.norm {
      ("a%s"):format(vim.fn.strftime(format)),
      bang = true,
    }
  end
end

return M
