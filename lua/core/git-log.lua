local M = {}

local git_log_buf = nil
local git_log_win = nil
local line_to_commit_message = {}
local line_to_hash = {}

local function highlight_line_briefly(lnum)
  local ns = vim.api.nvim_create_namespace("git_log_yank")
  vim.api.nvim_set_hl(0, "GitLogYank", { bg = "#45475A", fg = "#CDD6F4", bold = true })
  vim.api.nvim_buf_add_highlight(git_log_buf, ns, "GitLogYank", lnum - 1, 0, -1)
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(git_log_buf, ns, 0, -1)
  end, 300)
end

local function yank_commit_message()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local message = line_to_commit_message[lnum]
  if message then
    highlight_line_briefly(lnum)
    vim.fn.setreg("+", message)
    vim.notify("󰅍 Yanked message: " .. message, vim.log.levels.INFO, {
      timeout = 2000,
    })
  end
end

local function yank_hash()
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local hash = line_to_hash[lnum]
  if hash then
    highlight_line_briefly(lnum)
    vim.fn.setreg("+", hash)
    vim.notify("󰌷 Yanked hash: " .. hash, vim.log.levels.INFO, {
      timeout = 2000,
    })
  end
end

function M.toggle_git_log()
  if git_log_win and vim.api.nvim_win_is_valid(git_log_win) then
    vim.api.nvim_win_close(git_log_win, true)
    git_log_win = nil
    return
  end

  line_to_commit_message = {}
  line_to_hash = {}

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  git_log_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(git_log_buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(git_log_buf, "buftype", "nofile")

  vim.api.nvim_set_hl(0, "GitLogBorder", { fg = "#89b4fa", bg = "NONE" })
  vim.api.nvim_set_hl(0, "GitLogTitle", { fg = "#a6e3a1", bg = "NONE", bold = true })
  vim.api.nvim_set_hl(0, "GitLogBranch", { fg = "#8aadf4", bg = "NONE" })
  vim.api.nvim_set_hl(0, "GitLogDate", { fg = "#a6da95", bg = "NONE" })

  git_log_win = vim.api.nvim_open_win(git_log_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    title = " 󰊢 Git Log ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(git_log_win, "winhl", "FloatBorder:GitLogBorder,FloatTitle:GitLogTitle")

  local git_cmd = "git log --pretty=format:'%h|%d|%s|%cr' --abbrev-commit --date=relative"
  local lines = vim.fn.systemlist(git_cmd)
  local ns = vim.api.nvim_create_namespace("git_log")
  for i, line in ipairs(lines) do
    local parts = vim.split(line, "|", { plain = true })
    if #parts >= 4 then
      local hash = parts[1]
      local branch = parts[2]
      local subject = parts[3]
      local date = parts[4]

      line_to_commit_message[i] = subject
      line_to_hash[i] = hash

      local display_line = (branch .. " " .. subject .. " (" .. date .. ")"):gsub("^%s*", "")
      vim.api.nvim_buf_set_lines(git_log_buf, i - 1, i - 1, false, { display_line })

      local trimmed_branch = branch:gsub("^%s*", "")
      vim.api.nvim_buf_add_highlight(git_log_buf, ns, "GitLogBranch", i - 1, 0, #trimmed_branch)
      vim.api.nvim_buf_add_highlight(git_log_buf, ns, "GitLogDate", i - 1, #display_line - (#date + 2), -1)
    end
  end

  vim.api.nvim_buf_set_option(git_log_buf, "modifiable", false)
  vim.api.nvim_win_set_option(git_log_win, "relativenumber", true)
  vim.api.nvim_win_set_cursor(git_log_win, { 1, 0 })

  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = git_log_buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = git_log_buf, silent = true })
  vim.keymap.set("n", "ym", yank_commit_message, { buffer = git_log_buf, silent = true, desc = "Yank commit message" })
  vim.keymap.set("n", "yh", yank_hash, { buffer = git_log_buf, silent = true, desc = "Yank hash" })
end

return M
