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

-- Diagnostics
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
  virtual_text = {
    prefix = "",
    spacing = 2,
    format = function(d)
      local icons = { ERROR = "", WARN = "", INFO = "", HINT = "" }
      return string.format("%s %s", icons[vim.diagnostic.severity[d.severity]], d.message)
    end,
  },
  float = {
    border = "rounded",
    source = true,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Auto-show diagnostic float on cursor hold
vim.o.updatetime = 500
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false })
  end,
})

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
