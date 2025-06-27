-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)

-- Quit file
vim.keymap.set("n", "<C-q>", "<cmd> q <CR>", opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>bd", ":BufDel<CR>", { desc = "[B]uffer [D]elete" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "[B]uffer [N]ew" })
-- vim.keymap.set("n", "<leader>bp", ":BufferLinePick<CR>", { desc = "[B]uffer [P]ick" })
vim.keymap.set("n", "<leader>j", ":BufferLinePick<CR>", { desc = "Jump Buffers" })
vim.keymap.set("n", "<leader>bD", ":BufDelOther<CR>", { desc = "[B]uffer [D]elete all others" })

-- Resize with arrows
vim.keymap.set("n", "<Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<Right>", ":vertical resize +2<CR>", opts)

-- Window management
vim.keymap.set("n", "<leader>v", "<C-w>v", opts) -- split window vertically
vim.keymap.set("n", "<leader>h", "<C-w>s", opts) -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", opts) -- make split windows equal width & height
vim.keymap.set("n", "<leader>xs", ":close<CR>", opts) -- close current split window

-- Navigate between splits
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", opts)
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", opts)
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", opts)
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", opts)

-- Tabs
vim.keymap.set("n", "<leader>to", ":tabnew<CR>", opts) -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>", opts) -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", opts) --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", opts) --  go to previous tab

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Clear search highlight with <leader>c
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Don't yank on delete (use leader + d)
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- Select all text in buffer
vim.keymap.set("n", "<C-a>", "ggVG")

-- Move to start/end of line easier
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "g_")

-- Git log floating window
vim.keymap.set("n", "<leader>l", function()
  require("core.git-log").toggle_git_log()
end, { desc = "Toggle git log in floating window" })

vim.keymap.set("t", "<leader>l", function()
  require("core.git-log").toggle_git_log()
end, { desc = "Toggle git log in floating window" })
