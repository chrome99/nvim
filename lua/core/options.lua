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

-- Automatically reload file if changed by another program
vim.o.autoread = true

-- Save undo history
vim.o.undofile = true

-- Don't create annoying swap files
vim.o.swapfile = false

-- Scroll margin
vim.o.scrolloff = 5

-- Case insensitive search
vim.o.ignorecase = true

-- Diff: use a space for filler lines (instead of "----------")
vim.opt.fillchars:append({ diff = " " })

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "diff",
  callback = function()
    if vim.wo.diff then
      vim.cmd("normal! zR")
    end
  end,
})
