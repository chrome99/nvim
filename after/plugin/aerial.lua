require("aerial").setup({
  -- Open aerial on the right
  layout = {
    default_direction = "right",
    placement = "edge",
    width = 35,
  },

  -- Auto-close aerial when jumping to a symbol
  close_on_select = false,

  -- Show box-drawing chars for tree structure
  show_guides = true,

  -- Attach to these sources in order of preference
  backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
  ignore = {
    filetypes = { "sql", "mysql", "plsql" },
  },

  filter_kind = {
    "Class",
    "Constructor",
    "Enum",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Struct",
    "Type",
    "Variable",
  },
})


vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { desc = "Toggle [A]erial outline" })
-- Jump between symbols with { and }
vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { desc = "Prev symbol" })
vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { desc = "Next symbol" })
