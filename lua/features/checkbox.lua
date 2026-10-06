local M = {}

local function toggle_line(line)
  if line:match("^%s*-%s%[%s%]") then
    return line:gsub("^(%s*-%s)%[%s%](.*)$", "%1[x]%2")
  elseif line:match("^%s*-%s%[x%]") then
    return line:gsub("^(%s*-%s)%[x%](.*)$", "%1[ ]%2")
  end
  return nil
end

-- Toggles the checkbox on the current line. Returns true if it toggled one,
-- false if the line wasn't a checkbox (so callers can fall back to default behavior).
function M.toggle_checkbox()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  local new_line = toggle_line(line)
  if not new_line then
    return false
  end
  vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  return true
end

function M.toggle_checkbox_range()
  local start_row, end_row
  local mode = vim.api.nvim_get_mode().mode

  if mode == "V" or mode == "v" then
    local start_pos = vim.fn.getpos("v")
    local end_pos = vim.fn.getpos(".")
    start_row = math.min(start_pos[2], end_pos[2])
    end_row = math.max(start_pos[2], end_pos[2])
  else
    start_row = vim.api.nvim_win_get_cursor(0)[1]
    end_row = start_row
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  for row = start_row, end_row do
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local new_line = toggle_line(line)
    if new_line then
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
    end
  end
end

return M
