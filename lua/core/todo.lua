local state = {
  floating = {
    buf = -1,
    win = -1,
  },
  help_win = -1,
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
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.fn.writefile(lines, todo_file)
  vim.api.nvim_buf_set_option(buf, "modified", false)
end

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

local function setup_todo_keymaps(buf)
  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "q", function()
    save_todo_file(buf)
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    end
    vim.api.nvim_win_hide(state.floating.win)
  end, vim.tbl_extend("force", opts, { desc = "Close todo window" }))

  vim.keymap.set("n", "<cr>", toggle_checkbox, vim.tbl_extend("force", opts, { desc = "Toggle todo checkbox" }))

  vim.keymap.set("n", "<C-s>", function()
    save_todo_file(buf)
    vim.notify("Todo saved!", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Save todo" }))

  vim.keymap.set("n", "o", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(buf, row, row, false, { "- [ ] " })
    vim.api.nvim_win_set_cursor(0, { row + 1, 6 })
    vim.cmd("startinsert!")
  end, vim.tbl_extend("force", opts, { desc = "Add new todo below" }))

  vim.keymap.set("n", "?", function()
    if vim.api.nvim_win_is_valid(state.help_win) then
      vim.api.nvim_win_close(state.help_win, true)
      state.help_win = -1
    else
      local help_buf = vim.api.nvim_create_buf(false, true)
      local help_content = {
        "Keymaps:",
        "o - Add new todo below",
        "<Enter> - Toggle checkbox",
        "<Ctrl-s> - Save todo",
        "q - Close todo",
        "? - Toggle this help",
      }
      vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_content)

      local help_width = 25
      local help_height = 6
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

    vim.api.nvim_create_autocmd("TextChanged", {
      buffer = state.floating.buf,
      callback = function()
        vim.api.nvim_buf_set_option(state.floating.buf, "modified", true)
      end,
    })
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
