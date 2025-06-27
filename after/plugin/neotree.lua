require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    bind_to_cwd = true,
    follow_current_file = {
      enabled = false,
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
vim.api.nvim_set_keymap("n", "<leader>e", ":Neotree toggle<CR>", { noremap = true, silent = true })
