local function folder_at_cursor(tree)
  local node = tree:get_node()
  if node.type ~= "directory" then
    return (tree:get_node(node:get_parent_id()))
  end
  return node
end

local function expand_next_level(state)
  local tree = state.tree
  local level = { folder_at_cursor(tree) }
  local closed = {}
  while #level > 0 and #closed == 0 do
    local next_level = {}
    for _, n in ipairs(level) do
      if n.loaded == false or not n:is_expanded() then
        table.insert(closed, n:get_id())
      else
        for _, child in ipairs(tree:get_nodes(n:get_id())) do
          if child.type == "directory" then
            table.insert(next_level, child)
          end
        end
      end
    end
    level = next_level
  end

  require("plenary.async").run(function()
    state.explicitly_opened_nodes = state.explicitly_opened_nodes or {}
    for _, id in ipairs(closed) do
      if state.tree:get_node(id).loaded == false then
        require("neo-tree.sources.filesystem.lib.fs_scan").get_dir_items_async(state, id, false)
      end
      state.tree:get_node(id):expand()
      state.explicitly_opened_nodes[id] = true
    end
  end, function()
    require("neo-tree.ui.renderer").redraw(state)
  end)
end

local function collapse_deepest_level(state)
  local tree = state.tree
  local root_id = tree:get_nodes()[1]:get_id()
  local deepest, depth = {}, 0
  local function visit(n)
    if n.type ~= "directory" or not n:is_expanded() then
      return
    end
    if n:get_id() ~= root_id then
      if n:get_depth() > depth then
        deepest, depth = {}, n:get_depth()
      end
      if n:get_depth() == depth then
        table.insert(deepest, n)
      end
    end
    for _, child in ipairs(tree:get_nodes(n:get_id())) do
      visit(child)
    end
  end
  visit(folder_at_cursor(tree))

  state.explicitly_opened_nodes = state.explicitly_opened_nodes or {}
  for _, n in ipairs(deepest) do
    n:collapse()
    state.explicitly_opened_nodes[n:get_id()] = false
  end
  require("neo-tree.ui.renderer").redraw(state)
end

local function expand_all_levels(state)
  require("neo-tree.sources.filesystem.commands").expand_all_nodes(state, folder_at_cursor(state.tree))
end

require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    bind_to_cwd = true,
    follow_current_file = {
      enabled = true,
    },
  },
  window = {
    width = 30,
    mappings = {
      ["z"] = "none",
      ["zr"] = expand_next_level,
      ["zm"] = collapse_deepest_level,
      ["zR"] = expand_all_levels,
      ["zM"] = "close_all_nodes",
      ["P"] = {
        "toggle_preview",
        config = {
          use_float = false,
        },
      },
    },
  },
  event_handlers = {
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        vim.opt_local.relativenumber = true
        vim.opt_local.statusline = " "
      end,
    },
  },
})

-- Toggle Neotree
vim.keymap.set("n", "<leader>e", function()
  if vim.bo.buftype ~= "" then
    vim.cmd("Neotree toggle reveal=false")
  else
    vim.cmd("Neotree toggle")
  end
end, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      return
    end
    vim.cmd("Neotree show")
  end,
})
