local M = {}

local SELECTION_READ_TIMEOUT_MS = 1000

local function running_x11_with_xclip()
  return vim.fn.has("linux") == 1
    and (vim.env.DISPLAY or "") ~= ""
    and vim.fn.executable("xclip") == 1
end

local function read_selection_or_give_up(selection)
  local xclip = vim.system({ "xclip", "-o", "-selection", selection }, { text = true })
  local finished, result = pcall(xclip.wait, xclip, SELECTION_READ_TIMEOUT_MS)
  if not finished or result.code ~= 0 then
    return {}
  end
  return vim.split(result.stdout, "\n")
end

local function hold_selection_until_replaced(selection)
  return { "xclip", "-quiet", "-i", "-selection", selection }
end

function M.setup()
  if not running_x11_with_xclip() then
    return
  end

  vim.g.clipboard = {
    name = "xclip-with-read-timeout",
    copy = {
      ["+"] = hold_selection_until_replaced("clipboard"),
      ["*"] = hold_selection_until_replaced("primary"),
    },
    paste = {
      ["+"] = function()
        return read_selection_or_give_up("clipboard")
      end,
      ["*"] = function()
        return read_selection_or_give_up("primary")
      end,
    },
    cache_enabled = 1,
  }
end

return M
