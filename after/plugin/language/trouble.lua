local ok, trouble = pcall(require, "trouble")
if not ok then return end

trouble.setup()

-- Trouble diagnostics
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (workspace)" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Diagnostics (buffer)" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", { desc = "Quickfix" })
vim.keymap.set("n", "<leader>xr", "<cmd>Trouble lsp_references toggle<CR>", { desc = "References" })
