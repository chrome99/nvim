require("lsp_signature").setup({
  bind = true,
  handler_opts = {
    border = "rounded",
  },
  hint_enable = false,      -- no inline virtual text hint, just the popup
  floating_window = true,
  auto_close_after = nil,   -- keep open until cursor moves off args
  toggle_key = "<C-k>",     -- toggle signature popup manually
  select_signature_key = "<M-n>", -- cycle through overloads (alt+n)
})
