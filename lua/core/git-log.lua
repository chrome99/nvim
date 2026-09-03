local M = {}

local state = {
  win = nil,
  buf = nil,
  commits = {},
  preview_win = nil,
  preview_buf = nil,
}

local config = {
  window = {
    width_ratio = 0.8,
    height_ratio = 0.7,
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    title = " 󰊢 Git Log ",
  },
  highlights = {
    border = { fg = "#89b4fa" },
    title = { fg = "#a6e3a1", bold = true },
    branch = { fg = "#8aadf4" },
    date = { fg = "#a6da95" },
    yank = { bg = "#45475A", fg = "#CDD6F4", bold = true },
  },
  keymaps = {
    close = { "q", "<Esc>" },
    yank_message = "ym",
    yank_hash = "yh",
    preview = "<CR>",
    read = "r",
    stop_reading = "s",
  },
  git_command = "git log --pretty=format:'%h|%d|%s|%cr' --abbrev-commit --date=relative",
  -- Read the commit aloud (terminal-tts). Voice/speed live in
  -- ~/.config/terminal-tts/config; these are just the commands.
  tts = {
    read_cmd = vim.fn.expand("~/.local/bin/read-text"),
    stop_cmd = vim.fn.expand("~/.local/bin/stop-reading"),
  },
}

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
end

local function highlight_line_briefly(lnum)
  local ns = vim.api.nvim_create_namespace("git_log_yank")
  vim.api.nvim_set_hl(0, "GitLogYank", config.highlights.yank)
  vim.api.nvim_buf_add_highlight(state.buf, ns, "GitLogYank", lnum - 1, 0, -1)
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(state.buf, ns, 0, -1)
  end, 300)
end

local function yank(what)
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local commit = state.commits[lnum]
  if not commit or not commit[what] then
    return
  end

  local content = commit[what]
  highlight_line_briefly(lnum)
  vim.fn.setreg("+", content)
  vim.notify("󰅍 Yanked " .. what .. ": " .. content, vim.log.levels.INFO, { timeout = 2000 })
end

-- Full commit message for a hash: subject, body, and a short attribution
-- header. Deliberately no diff -- this view is for reading, not reviewing.
local function commit_message(hash)
  local out = vim.fn.systemlist({
    "git", "show", "-s", "--format=%s%n%n%b", hash,
  })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  -- Trim trailing blank lines left by commits with no body.
  while #out > 0 and out[#out]:match("^%s*$") do
    table.remove(out)
  end
  return out
end

-- Author plus both readings of the commit time: relative ("2 hours ago") for
-- the sense of when, absolute with the clock time for the record.
local function commit_meta(hash)
  local out = vim.fn.systemlist({
    "git", "show", "-s", "--format=%an|%ar|%ad", "--date=format:%-d %b %Y %H:%M", hash,
  })
  local author, rel, abs = (out[1] or ""):match("^(.-)|(.-)|(.*)$")
  return author or "", rel or "", abs or ""
end

-- Body only -- not the subject, and not the hash, author or date. All of those
-- are already on screen in front of you; the body is the part worth hearing.
local function spoken_commit(commit)
  local out = vim.fn.systemlist({ "git", "show", "-s", "--format=%b", commit.hash })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  while #out > 0 and out[#out]:match("^%s*$") do
    table.remove(out)
  end
  if #out == 0 then
    return nil -- a subject-only commit has nothing to read
  end
  return table.concat(out, "\n")
end

local function read_commit()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local commit = state.commits[lnum]
  if not commit then
    return
  end
  local text = spoken_commit(commit)
  if not text then
    vim.notify("Failed to read commit", vim.log.levels.ERROR)
    return
  end
  highlight_line_briefly(lnum)
  vim.system({ config.tts.read_cmd }, { stdin = text })
end

local function stop_reading()
  vim.system({ config.tts.stop_cmd })
end

local function show_commit_preview()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local commit = state.commits[lnum]
  if not commit then
    return
  end

  if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
    vim.api.nvim_win_close(state.preview_win, true)
    state.preview_win = nil
  end

  local message = commit_message(commit.hash)
  if not message then
    vim.notify("Failed to get commit details", vim.log.levels.ERROR)
    return
  end

  local author, rel, abs = commit_meta(commit.hash)
  local output = { author .. "  ·  " .. rel .. "  ·  " .. abs, "" }
  vim.list_extend(output, message)

  -- Narrower than the log window: prose is easier to follow in a short measure.
  local width = math.min(math.floor(vim.o.columns * 0.6), 80)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.preview_buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.preview_buf].bufhidden = "wipe"
  vim.bo[state.preview_buf].buftype = "nofile"
  vim.bo[state.preview_buf].filetype = "gitcommit"

  vim.api.nvim_buf_set_lines(state.preview_buf, 0, -1, false, output)
  vim.bo[state.preview_buf].modifiable = false

  local ns = vim.api.nvim_create_namespace("git_show_preview")
  vim.api.nvim_set_hl(0, "GitShowAuthor", { fg = "#8aadf4" })
  vim.api.nvim_set_hl(0, "GitShowSubject", { fg = "#eed49f", bold = true })
  vim.api.nvim_buf_add_highlight(state.preview_buf, ns, "GitShowAuthor", 0, 0, -1)
  vim.api.nvim_buf_add_highlight(state.preview_buf, ns, "GitShowSubject", 2, 0, -1)

  state.preview_win = vim.api.nvim_open_win(state.preview_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.window.border,
    title = " 󰊢 " .. commit.hash .. " ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(state.preview_win, "winhl", "FloatBorder:GitLogBorder,FloatTitle:GitLogTitle")
  -- Wrapped prose, no line numbers: this is something to read, not to navigate.
  vim.wo[state.preview_win].wrap = true
  vim.wo[state.preview_win].linebreak = true
  vim.wo[state.preview_win].breakindent = true
  vim.wo[state.preview_win].number = false
  vim.wo[state.preview_win].relativenumber = false

  local function close_preview()
    if state.preview_win and vim.api.nvim_win_is_valid(state.preview_win) then
      vim.api.nvim_win_close(state.preview_win, true)
      state.preview_win = nil
    end
  end

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, close_preview, { buffer = state.preview_buf, silent = true })
  end

  -- Same read/stop keys as the log list, so the muscle memory carries over.
  vim.keymap.set("n", config.keymaps.read, function()
    local text = spoken_commit(commit)
    if text then
      vim.system({ config.tts.read_cmd }, { stdin = text })
    end
  end, { buffer = state.preview_buf, silent = true, desc = "Read commit aloud" })

  vim.keymap.set("n", config.keymaps.stop_reading, stop_reading,
    { buffer = state.preview_buf, silent = true, desc = "Stop reading" })
end

local function setup_keymaps()
  local map = function(keys, func, desc)
    if type(keys) == "table" then
      for _, key in ipairs(keys) do
        vim.keymap.set("n", key, func, { buffer = state.buf, silent = true, desc = desc })
      end
    else
      vim.keymap.set("n", keys, func, { buffer = state.buf, silent = true, desc = desc })
    end
  end

  map(config.keymaps.close, "<cmd>close<cr>", "Close git log")
  map(config.keymaps.yank_message, function()
    yank("message")
  end, "Yank commit message")
  map(config.keymaps.yank_hash, function()
    yank("hash")
  end, "Yank commit hash")
  map(config.keymaps.preview, show_commit_preview, "Show commit message")
  map(config.keymaps.read, read_commit, "Read commit aloud")
  map(config.keymaps.stop_reading, stop_reading, "Stop reading")
end

local function fetch_and_display_log()
  state.commits = {}
  local ns = vim.api.nvim_create_namespace("git_log")

  local lines = vim.fn.systemlist(config.git_command)
  local display_lines = {}

  for i, line in ipairs(lines) do
    local parts = vim.split(line, "|", { plain = true })
    if #parts >= 4 then
      local hash, branch, subject, date = parts[1], parts[2], parts[3], parts[4]

      state.commits[i] = { hash = hash, branch = branch, message = subject, date = date }

      local display_line = (branch .. " " .. subject .. " (" .. date .. ")"):gsub("^%s*", "")
      table.insert(display_lines, display_line)
    end
  end

  vim.api.nvim_buf_set_option(state.buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, display_lines)
  vim.api.nvim_buf_set_option(state.buf, "modifiable", false)

  for i, line in ipairs(display_lines) do
    local commit = state.commits[i]
    if commit then
      local trimmed_branch = commit.branch:gsub("^%s*", "")
      if #trimmed_branch > 0 then
        vim.api.nvim_buf_add_highlight(state.buf, ns, "GitLogBranch", i - 1, 0, #trimmed_branch)
      end
      vim.api.nvim_buf_add_highlight(state.buf, ns, "GitLogDate", i - 1, #line - (#commit.date + 2), -1)
    end
  end

  vim.api.nvim_win_set_cursor(state.win, { 1, 0 })
end

local function create_window_and_buffer()
  local width = math.floor(vim.o.columns * config.window.width_ratio)
  local height = math.floor(vim.o.lines * config.window.height_ratio)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(state.buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(state.buf, "buftype", "nofile")

  vim.api.nvim_set_hl(0, "GitLogBorder", config.highlights.border)
  vim.api.nvim_set_hl(0, "GitLogTitle", config.highlights.title)
  vim.api.nvim_set_hl(0, "GitLogBranch", config.highlights.branch)
  vim.api.nvim_set_hl(0, "GitLogDate", config.highlights.date)

  state.win = vim.api.nvim_open_win(state.buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.window.border,
    title = config.window.title,
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(state.win, "winhl", "FloatBorder:GitLogBorder,FloatTitle:GitLogTitle")
  vim.api.nvim_win_set_option(state.win, "relativenumber", true)
end

function M.toggle_git_log()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
    state.win = nil
    return
  end

  if vim.fn.system("git rev-parse --is-inside-work-tree") ~= "true\n" then
    vim.notify("Not a git repository.", vim.log.levels.ERROR)
    return
  end

  create_window_and_buffer()
  setup_keymaps()
  fetch_and_display_log()
end

return M
