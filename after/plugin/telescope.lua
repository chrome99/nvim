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
-- Turn `git status --porcelain` lines into a list of grep-able file paths.
-- Each line looks like: "XY path" where X/Y are status codes, e.g.
--   " M lua/foo.lua"   (unstaged modified)
--   "A  lua/bar.lua"   (staged add)
--   "?? scratch.txt"   (untracked)
--   "R  old.lua -> new.lua"  (rename)
-- Turn `git status --porcelain` lines into a list of file paths (repo-root
-- relative). Each line is "XY path", e.g. " M lua/foo.lua", "?? new.txt",
-- "R  old.lua -> new.lua". We skip deletions (nothing on disk to open) and
-- keep the NEW path for renames.
local function parse_porcelain(lines)
  local files = {}
  for _, line in ipairs(lines) do
    if line ~= "" then
      local x, y = line:sub(1, 1), line:sub(2, 2)
      if x ~= "D" and y ~= "D" then
        local path = line:sub(4)
        local arrow = path:find(" -> ", 1, true)
        if arrow then
          path = path:sub(arrow + 4)
        end
        path = path:gsub('^"(.*)"$', "%1") -- porcelain quotes paths with odd chars
        table.insert(files, path)
      end
    end
  end
  return files
end

vim.keymap.set("n", "<leader>ss", function()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not a git repo", vim.log.levels.WARN)
    return
  end
  local files = parse_porcelain(vim.fn.systemlist("git status --porcelain"))
  if #files == 0 then
    vim.notify("No modified files", vim.log.levels.INFO)
    return
  end
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local make_entry = require("telescope.make_entry")
  local conf = require("telescope.config").values
  pickers.new({}, {
    prompt_title = "Modified Files",
    finder = finders.new_table({
      results = files,
      entry_maker = make_entry.gen_from_file({ cwd = root }),
    }),
    sorter = conf.file_sorter({}),
    previewer = conf.file_previewer({ cwd = root }),
  }):find()
end, { desc = "[S]earch Modified (open)" })
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
