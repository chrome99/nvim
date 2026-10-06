vim.api.nvim_create_user_command("Msgs", function()
  vim.cmd("new | put=execute('messages')")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
end, {})
