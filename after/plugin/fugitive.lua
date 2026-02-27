-- Status
vim.keymap.set("n", "<leader>gg", "<cmd>Git<CR>", { desc = "Git status" })

-- Diffs
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Diff (unstaged vs staged)" })
vim.keymap.set("n", "<leader>gD", "<cmd>Gdiffsplit --cached<CR>", { desc = "Diff (staged vs HEAD)" })

-- Blame / logs
vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Blame" })
vim.keymap.set("n", "<leader>gL", "<cmd>Git log -- %<CR>", { desc = "File log" })
