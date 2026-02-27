local builtin = require("telescope.builtin")
require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
    },
  },
  pickers = {
    find_files = {
      file_ignore_patterns = { "node_modules", ".git", ".venv" },
      hidden = true,
    },
    live_grep = {
      file_ignore_patterns = { "node_modules", ".git", ".venv" },
      additional_args = function(_)
        return { "--hidden" }
      end,
    },
  },
})

require("telescope").load_extension("fzf")
require("telescope").load_extension("live_grep_args")

vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sp", "<cmd>Telescope projects<CR>", { desc = "[S]earch [P]rojects" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope").extensions.live_grep_args.live_grep_args, { desc = "[S]earch by [G]rep (args)" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch [.]Recent Files" })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
vim.keymap.set("n", "<leader>sy", "<cmd>Telescope yank_history<CR>", { desc = "[S]earch [Y]ank history" })
vim.keymap.set("n", "<leader>sq", function()
  require("telescope.builtin").find_files({
    prompt_title = "SQL / DB Files",
    find_command = { "rg", "--files", "--glob", "*.sql", "--glob", "*.db", "--glob", "*.sqlite", "--glob", "*.sqlite3", "--hidden" },
  })
end, { desc = "[S]earch [Q]uery/DB files" })
