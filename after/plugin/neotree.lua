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
      event = "file_open_requested",
      handler = function()
        vim.cmd("Neotree close")
      end,
    },
    {
      event = "neo_tree_buffer_enter",
      handler = function()
        vim.opt_local.relativenumber = true
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
