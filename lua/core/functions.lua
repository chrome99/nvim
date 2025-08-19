-- Replace leading '*' with '- [ ]' in the current visual selection
function _G.StarToCheckbox()
  local s = vim.fn.getpos("'<")[2]
  local e = vim.fn.getpos("'>")[2]
  vim.cmd(("%d,%ds/\\v^(\\s*)\\*/\\1- [ ]/ge"):format(s, e))
end

vim.api.nvim_create_user_command("StarToCheckbox", StarToCheckbox, { range = true })
