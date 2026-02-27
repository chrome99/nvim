local state = {
  floating = {
    buf = -1,
    win = -1,
  },
  help_win = -1,
  watcher = nil,
  saving = false,
  save_id = 0,
}

-- Create persistent todo file path
local todo_file = vim.fn.stdpath("state") .. "/todo.md"

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.7)
  local height = opts.height or math.floor(vim.o.lines * 0.7)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = state.floating.buf
  if not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_buf_set_option(buf, "buflisted", false)
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
  end

  vim.api.nvim_set_hl(0, "TodoBorder", { fg = "#89b4fa", bg = "NONE" })
  vim.api.nvim_set_hl(0, "TodoTitle", { fg = "#a6e3a1", bg = "NONE", bold = true })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    title = " 📝 Todo List ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "winhl", "FloatBorder:TodoBorder,FloatTitle:TodoTitle")
  vim.api.nvim_win_set_option(win, "conceallevel", 2)
  vim.api.nvim_win_set_option(win, "concealcursor", "niv")
  vim.api.nvim_win_set_option(win, "number", true)
  vim.api.nvim_win_set_option(win, "relativenumber", true)
  vim.api.nvim_win_set_option(win, "wrap", true)

  -- Set indent to 2 spaces for this buffer
  vim.api.nvim_buf_set_option(buf, "shiftwidth", 2)
  vim.api.nvim_buf_set_option(buf, "tabstop", 2)
  vim.api.nvim_buf_set_option(buf, "softtabstop", 2)
  vim.api.nvim_buf_set_option(buf, "expandtab", true)

  return { buf = buf, win = win }
end

local function load_todo_file(buf)
  -- Ensure buffer is modifiable
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  -- Create the state directory if it doesn't exist
  local state_dir = vim.fn.stdpath("state")
  vim.fn.mkdir(state_dir, "p")

  -- Load todo file content if it exists
  if vim.fn.filereadable(todo_file) == 1 then
    local lines = vim.fn.readfile(todo_file)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  else
    local initial_content = {
      "# 📋 My Todo List",
      "",
      "## 🎯 Today's Tasks",
      "- [ ] Add your important tasks here",
      "- [ ] Use `<space>+Enter` to toggle completion",
      "- [x] ✨ Example completed task",
      "",
      "## 💡 Ideas & Notes",
      "- [ ] Brainstorm new features",
      "- [ ] Review code improvements",
      "",
      "## 📅 This Week",
      "- [ ] Plan upcoming projects",
      "- [ ] Schedule team meetings",
      "",
      "---",
      "*Tip: Use markdown formatting for better organization!*",
    }
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_content)
  end

  -- Set buffer as unmodified initially
  vim.api.nvim_buf_set_option(buf, "modified", false)
end

local function save_todo_file(buf)
  state.saving = true
  state.save_id = state.save_id + 1
  local id = state.save_id
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.fn.writefile(lines, todo_file)
  vim.api.nvim_buf_set_option(buf, "modified", false)
  vim.defer_fn(function()
    if state.save_id == id then
      state.saving = false
    end
  end, 200)
end

local function start_file_watcher()
  if state.watcher then return end
  state.watcher = vim.loop.new_fs_event()
  if not state.watcher then return end
  state.watcher:start(todo_file, {}, vim.schedule_wrap(function(err, _, _)
    if err or state.saving then return end
    if not vim.api.nvim_buf_is_valid(state.floating.buf) then return end
    load_todo_file(state.floating.buf)
    if vim.api.nvim_win_is_valid(state.floating.win) then
      vim.notify("Todo reloaded from disk", vim.log.levels.INFO)
    end
  end))
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    if state.watcher then
      state.watcher:stop()
    end
  end,
})

local function toggle_checkbox()
  local line = vim.api.nvim_get_current_line()
  local row = vim.api.nvim_win_get_cursor(0)[1]

  if line:match("^%s*-%s%[%s%]") then
    local new_line = line:gsub("^(%s*-%s)%[%s%](.*)$", "%1[x]%2")
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  elseif line:match("^%s*-%s%[x%]") then
    local new_line = line:gsub("^(%s*-%s)%[x%](.*)$", "%1[ ]%2")
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  end
end

local function toggle_checkbox_range()
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
    local modified_line

    if line:match("^%s*-%s%[%s%]") then
      modified_line = line:gsub("^(%s*-%s)%[%s%](.*)$", "%1[x]%2")
    elseif line:match("^%s*-%s%[x%]") then
      modified_line = line:gsub("^(%s*-%s)%[x%](.*)$", "%1[ ]%2")
    else
      modified_line = line
    end

    if modified_line ~= line then
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { modified_line })
    end
  end
end

local function setup_todo_keymaps(buf)
  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "<C-q>", function()
    save_todo_file(buf)
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    end
    vim.api.nvim_win_hide(state.floating.win)
  end, vim.tbl_extend("force", opts, { desc = "Close todo window" }))

  vim.keymap.set("n", "<cr>", toggle_checkbox, vim.tbl_extend("force", opts, { desc = "Toggle todo checkbox" }))
  vim.keymap.set(
    "v",
    "<cr>",
    toggle_checkbox_range,
    vim.tbl_extend("force", opts, { desc = "Toggle multiple todo checkboxes" })
  )


  local function go_to_file(split_cmd)
    -- Get the current line and cursor position
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]

    -- Find the word under cursor that might contain file:line format
    local start_pos = col
    local end_pos = col

    -- Find start of word (go back until we hit whitespace or start of line)
    while start_pos > 0 and line:sub(start_pos, start_pos):match("[%S]") do
      start_pos = start_pos - 1
    end
    start_pos = start_pos + 1

    -- Find end of word (go forward until we hit whitespace or end of line)
    while end_pos < #line and line:sub(end_pos + 1, end_pos + 1):match("[%S]") do
      end_pos = end_pos + 1
    end

    local filename = line:sub(start_pos, end_pos)

    if filename == "" then
      vim.notify("No file name under cursor", vim.log.levels.WARN)
      return
    end

    -- Parse file:line or file:line:col format
    local file_part, line_part, col_part = filename:match("^(.+):(%d+):?(%d*)$")
    if not file_part then
      file_part = filename
      line_part = nil
      col_part = nil
    end

    save_todo_file(buf)
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    end
    vim.api.nvim_win_hide(state.floating.win)

    vim.cmd(split_cmd .. " " .. vim.fn.fnameescape(file_part))

    -- Jump to line and column if specified
    if line_part then
      local line_num = tonumber(line_part)
      local col_num = col_part and tonumber(col_part) or 1
      vim.api.nvim_win_set_cursor(0, { line_num, col_num - 1 })
    end
  end

  vim.keymap.set("n", "gf", function()
    go_to_file("edit")
  end, vim.tbl_extend("force", opts, { desc = "Close todo and go to file" }))

  vim.keymap.set("n", "gF", function()
    go_to_file("tabedit")
  end, vim.tbl_extend("force", opts, { desc = "Close todo and go to file in new tab" }))

  vim.keymap.set("n", "?", function()
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    else
      local help_buf = vim.api.nvim_create_buf(false, true)
      local help_content = {
        "Keymaps:",
        "<Enter> - Toggle checkbox",
        "V + <Enter> - Toggle multiple todos",
        "<Ctrl-q> - Close todo",
        "gf - Close todo and go to file",
        "gF - Close todo and go to file in new tab",
        "? - Toggle this help",
      }
      vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_content)

      local help_width = 38
      local help_height = 7
      local help_row = math.floor((vim.o.lines - help_height) / 2)
      local help_col = math.floor((vim.o.columns - help_width) / 2)

      state.help_win = vim.api.nvim_open_win(help_buf, true, {
        relative = "editor",
        width = help_width,
        height = help_height,
        row = help_row,
        col = help_col,
        style = "minimal",
        border = "single",
        zindex = 200,
      })

      vim.api.nvim_win_set_option(state.help_win, "winhl", "FloatBorder:TodoBorder")

      vim.keymap.set("n", "?", function()
        if vim.api.nvim_win_is_valid(state.help_win) then
          vim.api.nvim_win_close(state.help_win, true)
          state.help_win = -1
        end
      end, { buffer = help_buf, silent = true })
    end
  end, vim.tbl_extend("force", opts, { desc = "Toggle help" }))
end

local function toggle_todo()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window()
    load_todo_file(state.floating.buf)
    setup_todo_keymaps(state.floating.buf)

    vim.api.nvim_create_autocmd({ "BufWriteCmd", "BufLeave", "WinClosed" }, {
      buffer = state.floating.buf,
      callback = function()
        save_todo_file(state.floating.buf)
        if vim.api.nvim_win_is_valid(state.help_win) then
          vim.api.nvim_win_close(state.help_win, true)
          state.help_win = -1
        end
      end,
    })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      buffer = state.floating.buf,
      callback = function()
        save_todo_file(state.floating.buf)
      end,
    })

    start_file_watcher()
  else
    save_todo_file(state.floating.buf)
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    end
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command("Todo", toggle_todo, {})
vim.keymap.set("n", "<space>td", toggle_todo, { desc = "Toggle todo window" })

-- Yank current file path with line number
vim.keymap.set("n", "<leader>yf", function()
  local file_path = vim.fn.expand("%")
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  local result
  if git_root and git_root ~= "" then
    local relative_path = vim.fn.fnamemodify(file_path, ":p"):gsub("^" .. git_root .. "/", "")
    result = relative_path .. ":" .. line_num
  else
    result = vim.fn.fnamemodify(file_path, ":p") .. ":" .. line_num
  end

  vim.fn.setreg("+", result)
  vim.notify("Yanked: " .. result)
end, { desc = "Yank file path with line number" })
