require("codediff").setup({
  diff = {
    layout = "inline",
  },
  explorer = {
    width = 27, -- 2/3 of default (40)
  },
})

-- CodeDiff keymaps (fugitive's own git commands live in after/plugin/fugitive.lua)
vim.keymap.set("n", "<leader>gd", "<Cmd>CodeDiff<CR>", { desc = "Diff (all changes, changeset view)" })
vim.keymap.set("n", "<leader>gf", "<Cmd>CodeDiff history HEAD~50 %<CR>", { desc = "File history" })
vim.keymap.set("n", "<leader>gh", "<Cmd>CodeDiff history<CR>", { desc = "[G]it [H]istory (repo commits)" })

-- PR-style compare: interactive prompt for branches/commits
vim.keymap.set("n", "<leader>gC", function()
  local input = vim.fn.input("Compare (e.g., main, main..., commit-sha): ")
  if input ~= "" then
    vim.cmd("CodeDiff " .. input)
  end
end, { desc = "[G]it [C]ompare (prompt)" })

-- PR-style compare against main/master (merge-base, your commits only)
vim.keymap.set("n", "<leader>gm", function()
  local branch = "main"
  if vim.fn.system("git show-ref --verify --quiet refs/heads/master 2>/dev/null; echo $?"):match("^0") then
    branch = "master"
  end
  vim.cmd("CodeDiff " .. branch .. "...")
end, { desc = "[G]it [M]ain (diff against main/master)" })
