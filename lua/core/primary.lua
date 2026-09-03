-- Copy-on-select for the PRIMARY selection.
--
-- Ghostty mirrors any terminal selection into X11's PRIMARY as soon as you
-- release the mouse, which is what makes `prefix + R` (terminal-tts) work in
-- every other pane. Neovim is the exception: it grabs the mouse itself
-- (`mouse=nvi`) and keeps visual selections in its own registers, so PRIMARY
-- is never touched and the reader picks up whatever stale text was there.
--
-- This mirrors the live visual selection into PRIMARY (`*`), matching the rest
-- of the terminal. Yanks are untouched -- `clipboard=unnamedplus` still routes
-- those to CLIPBOARD (`+`) as before.

local M = {}

local DEBOUNCE_MS = 120
local MAX_BYTES = 100 * 1024 -- don't shove a whole buffer through xclip

local timer = nil
local last = nil

local VISUAL = { v = true, V = true, ["\22"] = true } -- \22 = CTRL-V, blockwise

local function selection()
  local mode = vim.fn.mode()
  if not VISUAL[mode] then
    return nil
  end
  local ok, lines = pcall(vim.fn.getregion, vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  if not ok or type(lines) ~= "table" or #lines == 0 then
    return nil
  end
  local text = table.concat(lines, "\n")
  if mode == "V" then
    text = text .. "\n"
  end
  if #text == 0 or #text > MAX_BYTES then
    return nil
  end
  return text
end

local function flush()
  local text = selection()
  if text == nil or text == last then
    return
  end
  last = text
  -- setreg on '*' shells out to the clipboard provider; failures here should
  -- never interrupt editing.
  pcall(vim.fn.setreg, "*", text)
end

local function schedule()
  if timer then
    timer:stop()
    timer:close()
  end
  timer = vim.uv.new_timer()
  timer:start(DEBOUNCE_MS, 0, function()
    if timer then
      timer:stop()
      timer:close()
      timer = nil
    end
    vim.schedule(flush)
  end)
end

function M.setup()
  if vim.fn.executable("xclip") == 0 and vim.fn.executable("wl-copy") == 0 then
    return
  end

  local group = vim.api.nvim_create_augroup("PrimaryCopyOnSelect", { clear = true })

  -- Entering or changing visual mode, and every cursor move while in it.
  vim.api.nvim_create_autocmd({ "ModeChanged", "CursorMoved" }, {
    group = group,
    callback = function()
      if VISUAL[vim.fn.mode()] then
        schedule()
      end
    end,
  })
end

return M
