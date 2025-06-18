-- Indent with 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.opt.expandtab = true

-- Line wrap
vim.opt.wrap = false
vim.o.linebreak = true

-- Cursor wrap behavior
vim.opt.whichwrap:append("<,>,h,l")

-- Line numbers
vim.opt.number = true
vim.wo.relativenumber = true

-- Sync clipboard
vim.o.clipboard = "unnamedplus"

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
