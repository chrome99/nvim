-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Save file
vim.keymap.set("n", "<C-s>", "<cmd> w <CR>", opts)

-- Write the buffer first when it is backed by a real file; use :q!/:bd! to discard
local function save_if_named()
	if vim.bo.modified and vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
		vim.cmd("write")
		return true
	end
	return false
end

-- Nothing on disk to write to, so keep the contents reachable before discarding
local function stash_unsaved()
	if vim.bo.modified then
		vim.fn.setreg("+", table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
		vim.api.nvim_echo({ { "Unsaved buffer copied to clipboard", "None" } }, false, {})
	end
end

-- Quit file
vim.keymap.set("n", "<C-q>", function()
	if save_if_named() then
		vim.cmd("quit")
	else
		stash_unsaved()
		vim.cmd("quit!")
	end
end, opts)

-- Find and center
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- Buffers
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)
vim.keymap.set("n", "<leader>bd", function()
	if not save_if_named() then
		stash_unsaved()
	end
	vim.cmd("BufDel!")
end, { desc = "[B]uffer [D]elete" })
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "[B]uffer [N]ew" })
-- vim.keymap.set("n", "<leader>bp", ":BufferLinePick<CR>", { desc = "[B]uffer [P]ick" })
vim.keymap.set("n", "<leader>j", ":BufferLinePick<CR>", { desc = "Jump Buffers" })
vim.keymap.set("n", "<leader>bD", ":BufDelOther!<CR>", { desc = "[B]uffer [D]elete all others" })

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
vim.keymap.set("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Diagnostic float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- Clear search highlight with <leader>c
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- Don't yank on delete (use leader + d)
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- Move to start/end of line easier
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "g_")

-- Toggle "- [ ]" / "- [x]" checkboxes with Enter, anywhere (falls back to
-- normal <CR> behavior when the line isn't a checkbox)
local checkbox = require("core.checkbox")
vim.keymap.set("n", "<CR>", function()
	if not checkbox.toggle_checkbox() then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
	end
end, { desc = "Toggle markdown checkbox" })
vim.keymap.set("v", "<CR>", checkbox.toggle_checkbox_range, { desc = "Toggle checkboxes in selection" })

-- Git log floating window
vim.keymap.set("n", "<leader>gl", function()
	require("core.git-log").toggle_git_log()
end, { desc = "Toggle git log in floating window" })

-- Focus floating window
vim.keymap.set("n", "<leader>ff", "<C-w>w", { desc = "Cycle to next window" })

-- Trouble diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (workspace)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (buffer)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Quickfix" })
vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", { desc = "References" })

-- Copy file itself to clipboard (paste as file in Finder/etc)
vim.keymap.set("n", "<leader>ya", function()
	local path = vim.fn.expand("%:p")
	if path == "" then
		vim.notify("No file", vim.log.levels.WARN)
		return
	end
	vim.fn.system({ "osascript", "-e", 'set the clipboard to (POSIX file "' .. path .. '")' })
	vim.notify("Copied file: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
end, { desc = "Copy file to clipboard" })

-- Yank diagnostic message on current line
vim.keymap.set("n", "<leader>yx", function()
	local diags = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
	if #diags == 0 then
		vim.notify("No diagnostics on this line", vim.log.levels.INFO)
		return
	end
	local msg = table.concat(
		vim.tbl_map(function(d)
			return d.message
		end, diags),
		"\n"
	)
	vim.fn.setreg("+", msg)
	vim.notify("Yanked: " .. msg, vim.log.levels.INFO)
end, { desc = "Yank diagnostic" })

vim.keymap.set("n", "<leader>r", function()
	local cmd = vim.fn.input("cmd: ")
	if cmd == "" then
		return
	end

	local output = vim.fn.system(cmd):gsub("\n", "")
	vim.api.nvim_put({ output }, "c", true, true)
end)

vim.keymap.set("n", "<leader>fp", function()
	local query = vim.fn.input("fp: ")
	if query == "" then
		return
	end

	local output = vim.fn.system("fp " .. vim.fn.shellescape(query)):gsub("\n", "")
	vim.api.nvim_put({ output }, "c", true, true)
end, { desc = "Find path" })
