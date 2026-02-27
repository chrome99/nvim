-- Setup Catppuccin
require("catppuccin").setup({
  flavour = "macchiato",
  transparent_background = false,
  custom_highlights = function(colors)
    return {
      Folded = { fg = colors.overlay1, bg = "NONE", style = { "italic" } },
    }
  end,
})

vim.cmd.colorscheme("catppuccin")
