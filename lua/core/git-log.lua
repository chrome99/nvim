local M = {}
local git_log_buf = nil
local git_log_win = nil

function M.toggle_git_log()
  if git_log_win and vim.api.nvim_win_is_valid(git_log_win) then
    vim.api.nvim_win_close(git_log_win, true)
    git_log_win = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.7)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  git_log_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(git_log_buf, "bufhidden", "hide")
  vim.api.nvim_buf_set_option(git_log_buf, "filetype", "git")
  vim.api.nvim_buf_set_option(git_log_buf, "buftype", "nofile")

  vim.api.nvim_set_hl(0, "GitLogBorder", { fg = "#89b4fa", bg = "NONE" })
  vim.api.nvim_set_hl(0, "GitLogTitle", { fg = "#a6e3a1", bg = "NONE", bold = true })

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

  vim.fn.termopen("git --no-pager l --color=always", {
    buffer = git_log_buf,
    on_exit = function()
      vim.cmd("stopinsert")
    end,
  })
  vim.cmd("startinsert")

  vim.api.nvim_buf_set_keymap(git_log_buf, "t", "q", "<C-\\><C-n><cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(git_log_buf, "t", "<Esc>", "<C-\\><C-n><cmd>close<cr>", { noremap = true, silent = true })

  vim.api.nvim_buf_set_keymap(git_log_buf, "n", "q", "<cmd>close<cr>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(git_log_buf, "n", "<Esc>", "<cmd>close<cr>", { noremap = true, silent = true })
end

return M
