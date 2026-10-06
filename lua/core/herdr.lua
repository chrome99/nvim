-- Registers nvim with herdr so a restored session reopens it instead of a bare shell.
local pane = vim.env.HERDR_PANE_ID
if vim.env.HERDR_ENV ~= "1" or not pane then
  return
end

local herdr = vim.env.HERDR_BIN_PATH or "herdr"

local function report(action, ...)
  local t = vim.uv.clock_gettime("realtime")
  local seq = tostring(t.sec * 1000 + math.floor(t.nsec / 1e6))
  return vim.system({ herdr, "pane", action, pane, "--source", "nvim", "--agent", "nvim", "--seq", seq, ... })
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    report("report-agent", "--state", "idle", "--", "nvim", "+ReviewHistory")
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    report("release-agent"):wait(500)
  end,
})
