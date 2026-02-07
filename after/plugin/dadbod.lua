local function dbui_redraw()
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "dbui" then
        vim.api.nvim_set_current_win(win)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("R", true, false, true), "m", false) -- mapped R
        return
      end
    end
  end)
end

local function add_dbui_sqlite_env(filepath)
  local abs = vim.fn.fnamemodify(filepath, ":p")
  local url = "sqlite:" .. abs
  local base = vim.fn.fnamemodify(abs, ":t")
  local stem = base:gsub("%.[^.]+$", "")
  local key = stem:gsub("[^%w]", "_"):upper()

  local var = "DB_UI_" .. key
  local i = 2
  while vim.env[var] and vim.env[var] ~= url do
    var = ("DB_UI_%s_%d"):format(key, i)
    i = i + 1
  end

  vim.env[var] = url
end

vim.api.nvim_create_autocmd("BufReadCmd", {
  pattern = { "*.db", "*.sqlite", "*.sqlite3" },
  callback = function(args)
    add_dbui_sqlite_env(args.file)
    vim.cmd("silent! DBUI")
    dbui_redraw()
    vim.cmd("silent! bwipeout! " .. args.buf)
  end,
})

-- Custom mappings for dadbod-ui
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dbui",
  callback = function()
    -- Remap parent/child navigation from C-n/C-p to J/K
    vim.keymap.set("n", "K", "<Plug>(DBUI_GotoParentNode)", { buffer = true })
    vim.keymap.set("n", "J", "<Plug>(DBUI_GotoChildNode)", { buffer = true })

    -- Enable relative line numbers in DBUI drawer
    vim.opt_local.number = true
    vim.opt_local.relativenumber = true
  end,
})
