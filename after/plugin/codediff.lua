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

-- Open history with nothing selected. Upstream's create selects the first
-- commit's first file whenever the list it is handed has a commit in it, so
-- hand it an empty list and fill the tree in afterwards.
do
  local history = require("codediff.ui.history")
  local render = require("codediff.ui.history.render")
  local create = history.create

  history.create = function(data, tabpage, width)
    local hist = create(vim.tbl_extend("force", data, { commits = {} }), tabpage, width)
    hist.data = data
    hist.tree:set_nodes(render.build_tree_nodes(data.commits, data.git_root, data.opts))
    hist.tree:render()
    return hist
  end
end

-- Fix ]f/[f in repo history mode.
--
-- Upstream's history navigate_next/navigate_prev build their file list from
-- `get_all_files`, which only collects direct children of *expanded* commit
-- nodes. A freshly opened history view has exactly one commit expanded, so the
-- list holds that commit's files and nothing else: ]f cycles within the one
-- commit (usually a single file) and looks dead. It also misses files nested
-- under directory nodes in `history.view_mode = "tree"`.
--
-- Replace both with a walk over every commit, loading a collapsed commit's
-- files on demand when navigation crosses into it. Overrides the module table
-- rather than the plugin source so a PackerUpdate doesn't undo it.
do
  local history = require("codediff.ui.history")
  local codediff_config = require("codediff.config")

  -- File nodes under a commit, in panel order, descending through the
  -- directory nodes that tree view mode inserts.
  local function commit_files(tree, commit_node)
    local files = {}
    local function walk(node)
      if not node:has_children() then
        return
      end
      for _, child_id in ipairs(node:get_child_ids() or {}) do
        local child = tree:get_node(child_id)
        if child and child.data then
          if child.data.type == "file" then
            table.insert(files, child)
          elseif child.data.type == "directory" then
            walk(child)
          end
        end
      end
    end
    walk(commit_node)
    return files
  end

  local function commit_nodes(hist)
    local commits = {}
    for _, node in ipairs(hist.tree:get_nodes() or {}) do
      if node.data and node.data.type == "commit" then
        table.insert(commits, node)
      end
    end
    return commits
  end

  -- Move the panel cursor onto the node and open its diff, leaving focus where
  -- it was (]f is usually pressed from the diff pane, not the panel).
  local function select_file(hist, node)
    local current_win = vim.api.nvim_get_current_win()
    if hist.winid and vim.api.nvim_win_is_valid(hist.winid) then
      vim.api.nvim_set_current_win(hist.winid)
      pcall(vim.api.nvim_win_set_cursor, hist.winid, { node._line or 1, 0 })
      if vim.api.nvim_win_is_valid(current_win) then
        vim.api.nvim_set_current_win(current_win)
      end
    end
    hist.on_file_select(node.data)
  end

  -- Walk to the next/previous commit that has files and land on its first or
  -- last one, loading files for commits that were never expanded.
  local function step_commit(hist, commits, index, direction)
    local cycle = codediff_config.options.diff.cycle_next_file
    local visited = 0

    local function attempt(from)
      visited = visited + 1
      if visited > #commits then
        return
      end

      local target = from + direction
      if target < 1 or target > #commits then
        if not cycle then
          local msg = direction > 0 and string.format("Last file (commit %d of %d)", #commits, #commits) or "First file (commit 1)"
          vim.api.nvim_echo({ { msg, "WarningMsg" } }, false, {})
          return
        end
        target = (target - 1) % #commits + 1
      end

      local node = commits[target]
      local function land()
        local files = commit_files(hist.tree, node)
        if #files == 0 then
          return attempt(target)
        end
        node:expand()
        hist.tree:render()
        select_file(hist, direction > 0 and files[1] or files[#files])
      end

      if node.data.files_loaded then
        land()
      elseif hist._load_commit_files then
        hist._load_commit_files(node, land)
      else
        attempt(target)
      end
    end

    attempt(index)
  end

  local function navigate(hist, direction)
    if not (hist and hist.tree) then
      return
    end

    local commits = commit_nodes(hist)
    if #commits == 0 then
      vim.notify("No commits in history", vim.log.levels.WARN)
      return
    end

    -- Nothing selected yet: enter from the near end of the history.
    local current_index
    for i, node in ipairs(commits) do
      if node.data.hash == hist.current_commit then
        current_index = i
        break
      end
    end
    if not current_index or not hist.current_file then
      step_commit(hist, commits, direction > 0 and 0 or #commits + 1, direction)
      return
    end

    local files = commit_files(hist.tree, commits[current_index])
    local file_index
    for i, node in ipairs(files) do
      if node.data.path == hist.current_file then
        file_index = i
        break
      end
    end

    local next_file = file_index and files[file_index + direction]
    if next_file then
      vim.api.nvim_echo({}, false, {})
      select_file(hist, next_file)
      return
    end

    step_commit(hist, commits, current_index, direction)
  end

  history.navigate_next = function(hist)
    navigate(hist, 1)
  end

  history.navigate_prev = function(hist)
    navigate(hist, -1)
  end
end
