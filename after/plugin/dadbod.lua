-- Auto-connect to all .sqlite and .db files in data/ folder
local dbs = {}
local data_dir = vim.fn.getcwd() .. "/data"
local sqlite_files = vim.fn.glob(data_dir .. "/*.sqlite", false, true)
local db_files = vim.fn.glob(data_dir .. "/*.db", false, true)

-- Combine both file lists
local all_files = vim.list_extend(sqlite_files, db_files)

for _, file in ipairs(all_files) do
  local name = vim.fn.fnamemodify(file, ":t:r") -- Get filename without extension
  table.insert(dbs, { name = name, url = "sqlite:" .. file })
end

vim.g.dbs = dbs

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
