-- Status
vim.keymap.set("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status" })

-- Commit / log
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gL", "<cmd>Git log -- %<CR>", { desc = "Git log (current file)" })

-- Diff (staged vs HEAD, whole changeset, one unified-diff buffer)
vim.keymap.set("n", "<leader>gD", "<cmd>Git diff --cached<CR>", { desc = "Diff staged (unified, one window)" })

-- Blame
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Blame" })
