local spectre = require("spectre")

-- Open project-wide panel
vim.keymap.set("n", "<leader>S", spectre.open)

-- Search word under cursor (project)
vim.keymap.set("n", "<leader>Sw", function()
  spectre.open_visual({ select_word = true })
end)

-- Use current visual selection (project)
vim.keymap.set("v", "<leader>Sv", spectre.open_visual)

-- Current file only
vim.keymap.set("n", "<leader>Sf", function()
  spectre.open_file_search({ select_word = true })
end)

spectre.setup({
  default = { find = { cmd = "rg" } },
})
