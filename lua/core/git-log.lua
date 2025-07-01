local M = {}

local state = {
  win = nil,
  buf = nil,
  commits = {},
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
  },
  git_command = "git log --pretty=format:'%h|%d|%s|%cr' --abbrev-commit --date=relative",
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
